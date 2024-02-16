// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/ownable.sol";

import "./IBlast.sol";
import "./IERC20Rebasing.sol";
import "./BlastBase.sol";
import "./Xoxo3Base.sol";

pragma solidity 0.8.24;

contract Xoxo3 is Xoxo3Base {
  // 1 eth / 31536000 秒        = 31709791983
  // 1 eth / 31536000 秒 / 1000 = 31709792

  struct User {
    uint256 amount;
    uint256 timestamp;
  }

  mapping(address => User) ethUserMap;

  function pledgeETH() public payable {
    ethUserMap[msg.sender] = User({amount: msg.value, timestamp: block.timestamp});
  }

  function queryXOXO3WithPledgeETH() public view returns (uint256) {
    User memory user = ethUserMap[msg.sender];
    if (user.amount == 0) {
      return 0;
    }

    uint256 allTime = block.timestamp - user.timestamp;
    // 小于一天，不分红
    // if (allTime <= 86400) {
    //   return 0;
    // }

    uint256 tokenCount = allTime * 31709792 * 50;
    return tokenCount;
  }

  function withdrawalETH() public virtual returns (uint256) {
    uint256 tokenCount = this.queryXOXO3WithPledgeETH();
    if (tokenCount == 0) {
      return tokenCount;
    }

    _mint(msg.sender, tokenCount);
    return tokenCount;
  }

  // 1 XOXO3 = $1 = 20 USDT/一年。
}
