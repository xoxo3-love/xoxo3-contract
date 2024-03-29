// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Utils} from "../src/Utils.sol";

contract Xoxo3Test is Test {
  Utils public utils;

  function setUp() public {
    utils = new Utils();
  }

  function test_Increment() public view {
    uint256 result = utils.calcIncome(31536000, 1 ether, 50);
    uint256 count = 5 * (1 ether) / 100;
    assert(result > count * 9 / 10);
    assert(result < count * 11 / 10);
  }
}
