// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface FlashBorrower {
    function flashCallback(bytes calldata data) external;
}

contract FlashLender {
    IERC20 immutable money;

    constructor(IERC20 _money) {
        money = _money;
    }

    function borrow(uint256 amount, bytes calldata data) external {
        uint256 balanceBefore = money.balanceOf(address(this));
        uint256 balanceAfter;

        money.transferFrom(address(this), msg.sender, amount);
        FlashBorrower(msg.sender).flashCallback(data);
        balanceAfter = money.balanceOf(address(this));
        require(balanceBefore == balanceAfter);
    }
}