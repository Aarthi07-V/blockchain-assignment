# Blockchain-Based Assignment Submission System

A Solidity smart contract where students submit the **hash** of their assignment
and the **submission time is stored on the blockchain**.
Assignment II - Principles of Blockchain and Distributed Technology.

## Features
- Students submit a SHA-256 file hash (bytes32); the file is never stored on-chain
- Automatic timestamp using `block.timestamp`
- One submission per student; the same hash cannot be reused
- Teacher (owner) can open/close submissions and set a deadline
- Owner-only access control (`onlyOwner`)
- Events: AssignmentSubmitted, DeadlineUpdated, SubmissionsStatusChanged, OwnershipTransferred

## How to Run (Remix)
1. Open https://remix.ethereum.org
2. Create `AssignmentSubmission.sol` and paste the code from `contracts/`
3. Compile with Solidity 0.8.20 or higher
4. Deploy & Run -> Environment: Remix VM -> Deploy
5. Use another account to call `submitAssignment` with a bytes32 hash
6. Call `getSubmission(address)` to see the hash and timestamp

## Deployment Details
- Network: Remix VM (Osaka)
- Compiler: 0.8.34
- Contract address: 0xd9145CCE52D386f254917e481eB44e9943F39138
- Deployment tx hash: 0x8d439961f43e50d9470b6144fa64b7f3e0a8c0f602d30cf1e6612797e132daa5
- Deployment gas used: 1152489
- submitAssignment gas used: 162086

## Sample Output
```
submitAssignment(0x9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08)
-> Transaction mined and execution completed
getSubmission(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
-> hash: 0x9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
-> timestamp: 1791176075
Second submit by same student -> revert: "You have already submitted"
Submit while closed -> revert: "Submissions are closed"
Non-owner calls setSubmissionsOpen -> revert: "Only the owner can call this"
```

## Tests run
Valid submission, second student, duplicate submission, duplicate hash,
empty hash, access control, submissions closed.

## Author
Aarthi - 711523bcb002 - kit clg
