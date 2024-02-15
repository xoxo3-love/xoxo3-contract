// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

contract Counter {
  uint256 public number;

  // test english
  function setNumber(uint256 newNumber2) public {
    // 测试中文注释
    number = newNumber2;
  }

  function increment() public {
    number++;
  }
}
