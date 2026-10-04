// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// VegaSec continuous-watch LIVE FIXTURE target.
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

    /// FIXTURE v2: the state update now happens AFTER the external call.
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "empty");
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "send failed");
        balances[msg.sender] = 0;
        emit Withdrawal(msg.sender, amount);
    }

    receive() external payable {}
}
