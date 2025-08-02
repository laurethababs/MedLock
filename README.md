# MedLock

A decentralized medical records access and audit platform that gives patients sovereign control over their health data, enables secure permissioned sharing with providers, and ensures compliance through transparent on-chain access logs — all built on Clarity smart contracts.

---

## Overview

MedLock consists of ten main smart contracts that form a secure, privacy-preserving, and scalable ecosystem for health data ownership and access control:

1. **Patient Registry Contract** – Registers and verifies patients' identity and links encrypted medical records.
2. **Provider Registry Contract** – Onboards verified hospitals, labs, and care providers.
3. **Access Policy Manager Contract** – Stores encrypted access permissions for patient data.
4. **Request Channel Manager Contract** – Enables state channels for fast, low-cost temporary access.
5. **Access Audit Log Contract** – Logs and rollups all access events for transparency and compliance.
6. **Data Token Contract** – Tokenizes encrypted data as ERC-1155-style health record assets.
7. **Consent NFT Contract** – Represents signed and revocable patient consent as NFTs.
8. **Role Manager Contract** – Assigns verified roles (e.g. caregiver, emergency responder).
9. **Rollup Bridge Contract** – Anchors access logs and permissions via rollup-as-a-service.
10. **Emergency Access Contract** – Allows temporary bypass under strict multi-sig and audit review.

---

## Features

- **Patient-owned data access** with private, encrypted control  
- **Tokenized medical records** using off-chain storage and on-chain permissions  
- **Role-based access control** for doctors, nurses, and emergency staff  
- **State channel integration** for real-time data access and low-latency operations  
- **Audit logging** of all access events with ZK rollup anchoring  
- **Revocable patient consent NFTs** with time-limited access grants  
- **Emergency bypass flow** with multi-party approval and logging  
- **HIPAA/GDPR aligned** data access and transparency model  
- **RaaS-powered scalability** using rollup-as-a-service  
- **Modular, on-chain access policy enforcement**  

---

## Smart Contracts

### Patient Registry Contract
- Registers and verifies patients
- Links encrypted data hash (stored off-chain)
- Stores identity keys and metadata

### Provider Registry Contract
- Registers hospitals, labs, and clinics
- Associates roles and permissions
- Verifies credentials via oracle input

### Access Policy Manager Contract
- Stores encrypted permission conditions
- Updates and revokes access rules
- Integrates with Role Manager

### Request Channel Manager Contract
- Opens state channels for time-limited access
- Supports off-chain access interactions
- Finalizes access via channel settlement

### Access Audit Log Contract
- Logs all access attempts
- Bundled via rollup-as-a-service
- Used for compliance and disputes

### Data Token Contract
- Represents records (e.g. scans, reports) as multi-token (ERC-1155-style) assets
- Transfers and retires access tokens
- Associates data with encrypted hashes

### Consent NFT Contract
- Tokenized patient consent for data usage
- Supports expiration and revocation
- Verifiable and auditable on-chain

### Role Manager Contract
- Assigns roles to providers (e.g. GP, specialist, emergency)
- Role-based permissions for access
- Dynamic reassignment and revocation

### Rollup Bridge Contract
- Anchors access logs and permission updates via zk/optimistic rollups
- Offloads computation and storage to RaaS provider
- Ensures scalable and verifiable audit trails

### Emergency Access Contract
- Multi-sig controlled emergency access
- Auditable override with post-event verification
- Notifies patients post-incident

---

## Installation

1. Install [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
2. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/medlock.git
   ```
3. Run tests:
    ```bash
    npm test
    ```
4. Deploy contracts:
    ```bash
    clarinet deploy
    ```

## Usage

Each contract serves a modular function in the health data permission network. They interoperate through standardized events and interfaces to support a full-circle data sharing ecosystem.

- Patients can grant, revoke, or limit access to their data
- Providers access records via temporary or role-based permissions
- Logs and audits ensure accountability and transparency
- Refer to each contract’s documentation for specific function calls and integration patterns.

## Testing

All smart contracts are tested using Clarinet’s test suite.
Run the following to execute all tests:
```bash
npm test
```

## License

MIT License