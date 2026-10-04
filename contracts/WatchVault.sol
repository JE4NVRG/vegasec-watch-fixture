// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// VegaSec continuous-watch LIVE FIXTURE target (v5).
///
/// This repository exists so the paid Watch loop can be exercised against a real public
/// repository that can actually receive a new commit: change -> watch detects -> re-scan ->
/// finding diff -> score impact -> client alert -> signed history link.
///
/// It is not a product and holds no value.
contract WatchVault {
    mapping(address => uint256) public balances;
    address public owner;

    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /// FIXTURE v5: back to checks-effects-interactions (state written before the external call).
    /// Authorization still goes through tx.origin, so the access-control finding stays open.
    function withdraw() external {
        require(tx.origin == owner, "not owner");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "empty");
        balances[msg.sender] = 0;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "send failed");
        emit Withdrawal(msg.sender, amount);
    }

    /// FIXTURE v5: ownership transfer is now guarded.
    function setOwner(address newOwner) external {
        require(msg.sender == owner, "not owner");
        require(newOwner != address(0), "zero owner");
        owner = newOwner;
    }

    receive() external payable {}
}
