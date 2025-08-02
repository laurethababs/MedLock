(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-CHANNEL-NOT-FOUND u101)
(define-constant ERR-ALREADY-OPEN u102)
(define-constant ERR-NOT-PARTICIPANT u103)
(define-constant ERR-INSUFFICIENT-BALANCE u104)
(define-constant ERR-INVALID-AMOUNT u105)
(define-constant ERR-CHANNEL-SETTLED u106)
(define-constant ERR-INVALID-SIGNATURE u107)
(define-constant ERR-CHANNEL-NOT-OPEN u108)

;; Channel struct
(define-map channels
  (tuple (id uint))
  (tuple
    (party-a principal)
    (party-b principal)
    (balance-a uint)
    (balance-b uint)
    (nonce uint)
    (open bool)
    (settled bool)
  )
)

;; Admin and contract controls
(define-data-var admin principal tx-sender)

(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err ERR-NOT-AUTHORIZED))
    (var-set admin new-admin)
    (ok true)
  )
)

;; Create a new channel
(define-public (open-channel (id uint) (party-a principal) (party-b principal))
  (begin
    (asserts! (not (map-get? channels (tuple (id id)))) (err ERR-ALREADY-OPEN))
    (map-set channels (tuple (id id))
      (tuple
        (party-a party-a)
        (party-b party-b)
        (balance-a u0)
        (balance-b u0)
        (nonce u0)
        (open true)
        (settled false)
      )
    )
    (ok true)
  )
)

;; Deposit funds to channel
(define-public (deposit (id uint) (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
    (match (map-get? channels (tuple (id id)))
      channel
        (begin
          (asserts! (not (get settled channel)) (err ERR-CHANNEL-SETTLED))
          (let (
            (party-a (get party-a channel))
            (party-b (get party-b channel))
            (bal-a (get balance-a channel))
            (bal-b (get balance-b channel))
            (sender tx-sender)
          )
            (if (is-eq sender party-a)
              (map-set channels (tuple (id id))
                (merge channel (tuple (balance-a (+ bal-a amount))))
              )
              (if (is-eq sender party-b)
                (map-set channels (tuple (id id))
                  (merge channel (tuple (balance-b (+ bal-b amount))))
                )
                (err ERR-NOT-PARTICIPANT)
              )
            )
            (ok true)
          )
        )
      (err ERR-CHANNEL-NOT-FOUND)
    )
  )
)

;; Off-chain agreed settlement
(define-public (settle (id uint) (new-bal-a uint) (new-bal-b uint) (nonce uint))
  (match (map-get? channels (tuple (id id)))
    channel
      (begin
        (asserts! (not (get settled channel)) (err ERR-CHANNEL-SETTLED))
        (asserts! (>= nonce (get nonce channel)) (err ERR-INVALID-AMOUNT))
        (asserts! (is-eq tx-sender (get party-a channel)) (err ERR-NOT-AUTHORIZED))
        (asserts! (<= (+ new-bal-a new-bal-b) (+ (get balance-a channel) (get balance-b channel))) (err ERR-INVALID-AMOUNT))
        (map-set channels (tuple (id id))
          (merge channel
            (tuple
              (balance-a new-bal-a)
              (balance-b new-bal-b)
              (nonce nonce)
              (open false)
              (settled true)
            )
          )
        )
        (ok true)
      )
    (err ERR-CHANNEL-NOT-FOUND)
  )
)

;; Withdraw funds
(define-public (withdraw (id uint))
  (match (map-get? channels (tuple (id id)))
    channel
      (begin
        (asserts! (get settled channel) (err ERR-CHANNEL-NOT-OPEN))
        (let ((sender tx-sender))
          (if (is-eq sender (get party-a channel))
            (begin
              ;; transfer (get balance-a channel) to party-a
              (ok (get balance-a channel))
            )
            (if (is-eq sender (get party-b channel))
              (ok (get balance-b channel))
              (err ERR-NOT-PARTICIPANT)
            )
          )
        )
      )
    (err ERR-CHANNEL-NOT-FOUND)
  )
)

;; Read-only functions
(define-read-only (get-channel (id uint))
  (match (map-get? channels (tuple (id id)))
    channel (ok channel)
    (err ERR-CHANNEL-NOT-FOUND)
  )
)

(define-read-only (get-admin)
  (ok (var-get admin))
)
