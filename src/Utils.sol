// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Utils {
  function calcIncome(uint256 totalTime, uint256 amount, uint256 yield) public pure returns (uint256) {
    return totalTime * 31709792 * yield * amount / (1 ether);
  }
}
