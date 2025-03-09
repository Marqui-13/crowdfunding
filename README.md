# CrowdfundingCampaign Smart Contract

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

`CrowdfundingCampaign` is a Solidity smart contract for managing a crowdfunding campaign on Ethereum. A creator sets a funding goal and deadline, backers contribute Ether, and funds are either withdrawn if the goal is met or refunded if it fails. This contract demonstrates advanced Solidity and Yul skills, featuring optimized assembly for contribution tracking and Ether transfers.

Built as a GitHub portfolio piece, it showcases secure design, gas efficiency, and low-level EVM control, not intended for production use.

## Features

- **Campaign Setup**: Creator defines a funding goal and deadline.
- **Contributions**: Backers fund the campaign with tracked amounts.
- **State Management**: Transitions to `Succeeded` or `Failed` post-deadline.
- **Withdrawal**: Creator claims funds if successful.
- **Refunds**: Backers reclaim Ether if campaign fails.
- **Yul Optimization**: Assembly enhances contribution updates and refunds.
- **Transparency**: Events log all key actions.

## Contract Details

- **Solidity Version**: `^0.8.13`
- **License**: MIT
- **File**: `CrowdfundingCampaign.sol`

### Key Functions

#### Creator Functions
- `finalize`: Sets campaign state after deadline.
- `withdrawFunds`: Withdraws funds if campaign succeeds.

#### Backer Functions
- `contribute`: Adds Ether with Yul-optimized tracking.
- `claimRefund`: Reclaims Ether if campaign fails, using Yul.

#### View Functions
- `getCampaignState`: Returns current or projected state.
- `getContribution`: Shows a backer’s contribution.

## Setup

### Prerequisites
- [Node.js](https://nodejs.org/)
- [Hardhat](https://hardhat.org/)

### Installation
1. Clone the repo:
   ```bash
   git clone 
   cd crowdfundingcampaign
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Place `CrowdfundingCampaign.sol` in `contracts/`.
   
#### Compilation
     ```bash
     npx hardhat compile
     ```
### Testing Ideas

1. Campaign Creation:
- Deploy with goal and duration, verify event.

2. Contributions:
- Contribute Ether, check totalRaised and contributions.

3.Success Path:
- Meet goal, finalize, and withdraw funds.

4. Failure Path:
- Miss goal, finalize, and claim refunds.

5. Edge Cases:
- Contribute after deadline (should fail).

### Testing with Remix IDE

Test using Remix IDE:

1. Open Remix and create `CrowdfundingCampaign.sol`.

2. Compile with version `0.8.13`.

3. Deploy on JavaScript VM and test contributions, finalization, and refunds.

### Design Choices
- **Yul Assembly**: Optimized `contribute` and `claimRefund` with dynamic slot updates, and `safeTransferETH` with full gas forwarding for efficiency and control.
- **State Logic**: Enum-based states ensure clear transitions.
- **Event-Driven**: Comprehensive events for auditability.
- **Flexible Transfers**: Full gas in `safeTransferETH` supports varied recipients.

### Security Considerations

- **Reentrancy**: Prevented by state updates before Ether transfers.
- **Yul Safety**: Dynamic slot calculations and zero-contribution checks ensure correctness.
- **Fund Tracking**: All Ether via `contribute` is allocated, with `receive` redirecting.

### Limitations

- Relies on honest block timestamps (minor manipulation possible).
- `selfdestruct` funds may disrupt balance (EVM limitation).
- Full gas in `safeTransferETH` may fail with complex recipients.
- Theoretical overflow in Yul (exceeds practical ETH supply).

### License

MIT License - see [![LICENSE][LICENSE.md]