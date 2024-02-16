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

  // ============ Events ============
  event EventPledgeETH(address account, uint256 amount, uint256 startTimestamp);
  event EventWithdrawalETH(address account, uint256 tokenCount, uint256 totalTime);

  mapping(address => User) ethUserMap;

  function pledgeETH() public payable {
    ethUserMap[msg.sender] = User({amount: msg.value, timestamp: block.timestamp});
    emit EventPledgeETH(msg.sender, msg.value, block.timestamp);
  }

  function calcIncome(uint256 totalTime, uint256 amount, uint256 yield) public pure returns (uint256) {
    return totalTime * 31709792 * yield * amount / (1 ether);
  }

  function queryXOXO3WithPledgeETH() public view returns (uint256, uint256) {
    User memory user = ethUserMap[msg.sender];
    if (user.amount == 0) {
      return (0, 0);
    }

    uint256 totalTime = block.timestamp - user.timestamp;
    // 小于一天，不分红
    // if (totalTime <= 86400) {
    //   return 0;
    // }

    uint256 tokenCount = calcIncome(totalTime, user.amount, 50);
    return (tokenCount, totalTime);
  }

  function withdrawalETH() public virtual returns (uint256, uint256) {
    uint256 tokenCount;
    uint256 totalTime;
    (tokenCount, totalTime) = this.queryXOXO3WithPledgeETH();

    emit EventWithdrawalETH(msg.sender, tokenCount, totalTime);

    User memory user = ethUserMap[msg.sender];
    payable(msg.sender).transfer(user.amount);
    if (tokenCount > 0) {
      _mint(msg.sender, tokenCount);
    }

    return (tokenCount, totalTime);
  }

  // 1 XOXO3 = $1 = 20 USDT/一年。
}
