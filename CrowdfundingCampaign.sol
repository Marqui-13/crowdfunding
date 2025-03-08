// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CrowdfundingCampaign {
    address public creator;
    uint public goal;
    uint public deadline;
    uint public totalRaised;
    bool public finalized;
    mapping(address => uint) public contributions;

    enum State { Open, Succeeded, Failed }
    State public state;

    event CampaignCreated(address indexed creator, uint goal, uint deadline);
    event ContributionReceived(address indexed backer, uint amount, uint totalRaised);
    event CampaignFinalized(State state);
    event FundsWithdrawn(address indexed creator, uint amount);
    event RefundClaimed(address indexed backer, uint amount);

    constructor(uint _goal, uint _durationInSeconds) {
        require(_goal > 0, "Goal must be greater than zero");
        require(_durationInSeconds > 0, "Duration must be greater than zero");

        creator = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _durationInSeconds;
        state = State.Open;
        emit CampaignCreated(creator, goal, deadline);
    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Only creator can call this");
        _;
    }

    modifier onlyOpen() {
        require(state == State.Open, "Campaign is not open");
        require(block.timestamp < deadline, "Campaign has ended");
        _;
    }

    function contribute() external payable onlyOpen {
        require(msg.value > 0, "Contribution must be greater than 0");

        uint contributionSlot = uint(keccak256(abi.encode(msg.sender, 5)));
        uint totalSlot = 3; // Dynamic for clarity

        assembly {
            let currentContribution := sload(contributionSlot)
            let newContribution := add(currentContribution, callvalue())
            // Optional: if lt(newContribution, currentContribution) { revert(0, 0) }
            sstore(contributionSlot, newContribution)

            let currentTotal := sload(totalSlot)
            let newTotal := add(currentTotal, callvalue())
            // Optional: if lt(newTotal, currentTotal) { revert(0, 0) }
            sstore(totalSlot, newTotal)
        }

        emit ContributionReceived(msg.sender, msg.value, totalRaised);
    }

    function finalize() external {
        require(!finalized, "Campaign already finalized");
        require(block.timestamp >= deadline, "Deadline not reached");

        finalized = true;
        state = totalRaised >= goal ? State.Succeeded : State.Failed;
        emit CampaignFinalized(state);
    }

    function withdrawFunds() external onlyCreator {
        require(finalized, "Campaign not finalized");
        require(state == State.Succeeded, "Campaign did not succeed");

        uint amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");

        safeTransferETH(creator, amount);
        emit FundsWithdrawn(creator, amount);
    }

    function claimRefund() external {
        require(finalized, "Campaign not finalized");
        require(state == State.Failed, "Campaign did not fail");

        uint contributionSlot = uint(keccak256(abi.encode(msg.sender, 5)));
        uint amount;
        assembly {
            let currentContribution := sload(contributionSlot)
            if iszero(currentContribution) { revert(0, 0) }
            amount := currentContribution
            sstore(contributionSlot, 0)
        }

        safeTransferETH(msg.sender, amount);
        emit RefundClaimed(msg.sender, amount);
    }

    function getCampaignState() external view returns (State) {
        if (!finalized && block.timestamp >= deadline) {
            return totalRaised >= goal ? State.Succeeded : State.Failed;
        }
        return state;
    }

    function getContribution(address backer) external view returns (uint) {
        return contributions[backer];
    }

    function safeTransferETH(address to, uint amount) internal {
        assembly {
            if iszero(amount) { revert(0, 0) }
            let success := call(gas(), to, amount, 0, 0, 0, 0)
            if iszero(success) { revert(0, 0) }
        }
    }

    receive() external payable {
        contribute();
    }
}