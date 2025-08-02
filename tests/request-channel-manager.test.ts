// test/channel-manager.test.ts
import { describe, it, expect, beforeEach } from "vitest"

interface Channel {
  id: string
  sender: string
  recipient: string
  value: bigint
  expiration: number
  open: boolean
  disputed: boolean
  closed: boolean
  signatures: string[]
}

type MockContractState = {
  admin: string
  blockHeight: number
  channels: Map<string, Channel>
}

const mockState: MockContractState = {
  admin: "STADMIN111111111111111111111111111111111",
  blockHeight: 100,
  channels: new Map(),
}

function resetMockState() {
  mockState.channels = new Map()
  mockState.blockHeight = 100
}

function openChannel(id: string, sender: string, recipient: string, value: bigint, expiration: number): { value?: true, error?: number } {
  if (mockState.channels.has(id)) return { error: 400 } // already exists
  if (expiration <= mockState.blockHeight) return { error: 401 } // expired
  const channel: Channel = {
    id,
    sender,
    recipient,
    value,
    expiration,
    open: true,
    disputed: false,
    closed: false,
    signatures: [],
  }
  mockState.channels.set(id, channel)
  return { value: true }
}

function closeChannel(id: string, caller: string): { value?: true, error?: number } {
  const channel = mockState.channels.get(id)
  if (!channel) return { error: 404 }
  if (!channel.open) return { error: 405 }
  if (channel.sender !== caller && channel.recipient !== caller) return { error: 403 }
  if (channel.disputed) return { error: 406 }
  if (mockState.blockHeight > channel.expiration) return { error: 407 }
  channel.closed = true
  channel.open = false
  return { value: true }
}

function disputeChannel(id: string, caller: string): { value?: true, error?: number } {
  const channel = mockState.channels.get(id)
  if (!channel) return { error: 404 }
  if (channel.closed || !channel.open) return { error: 405 }
  if (caller !== channel.sender && caller !== channel.recipient) return { error: 403 }
  channel.disputed = true
  return { value: true }
}

function verifySignature(id: string, signature: string): { value?: true, error?: number } {
  const channel = mockState.channels.get(id)
  if (!channel) return { error: 404 }
  if (channel.signatures.includes(signature)) return { error: 409 }
  channel.signatures.push(signature)
  return { value: true }
}

describe("Channel Manager", () => {
  beforeEach(() => {
    resetMockState()
  })

  it("should open a new channel", () => {
    const result = openChannel("ch1", "STSENDER1", "STRECIPIENT1", 1000n, 120)
    expect(result).toEqual({ value: true })
  })

  it("should not open a channel with past expiration", () => {
    const result = openChannel("ch2", "STSENDER2", "STRECIPIENT2", 1000n, 99)
    expect(result).toEqual({ error: 401 })
  })

  it("should close a channel by sender", () => {
    openChannel("ch3", "STSENDER3", "STRECIPIENT3", 500n, 130)
    const result = closeChannel("ch3", "STSENDER3")
    expect(result).toEqual({ value: true })
  })

  it("should reject closing if already disputed", () => {
    openChannel("ch4", "STSENDER4", "STRECIPIENT4", 500n, 130)
    disputeChannel("ch4", "STSENDER4")
    const result = closeChannel("ch4", "STSENDER4")
    expect(result).toEqual({ error: 406 })
  })

  it("should dispute a channel by recipient", () => {
    openChannel("ch5", "STSENDER5", "STRECIPIENT5", 700n, 140)
    const result = disputeChannel("ch5", "STRECIPIENT5")
    expect(result).toEqual({ value: true })
  })

  it("should verify unique signatures", () => {
    openChannel("ch6", "STSENDER6", "STRECIPIENT6", 100n, 150)
    const result1 = verifySignature("ch6", "sig1")
    const result2 = verifySignature("ch6", "sig2")
    expect(result1).toEqual({ value: true })
    expect(result2).toEqual({ value: true })
  })

  it("should prevent duplicate signatures", () => {
    openChannel("ch7", "STSENDER7", "STRECIPIENT7", 100n, 150)
    verifySignature("ch7", "sig-dupe")
    const result = verifySignature("ch7", "sig-dupe")
    expect(result).toEqual({ error: 409 })
  })

  it("should prevent closing after expiration", () => {
    openChannel("ch8", "STSENDER8", "STRECIPIENT8", 100n, 105)
    mockState.blockHeight = 110
    const result = closeChannel("ch8", "STSENDER8")
    expect(result).toEqual({ error: 407 })
  })
})
