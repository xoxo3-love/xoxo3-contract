// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/ownable.sol";

import "./IBlast.sol";
import "./IERC20Rebasing.sol";

pragma solidity 0.8.24;

contract BlastBase is Ownable {
  IBlast public constant BLAST = IBlast(0x4300000000000000000000000000000000000002);
  IERC20Rebasing public constant USDB = IERC20Rebasing(0x4200000000000000000000000000000000000022);
  IERC20Rebasing public constant WETH = IERC20Rebasing(0x4200000000000000000000000000000000000023);

  address public governor;

  constructor() Ownable(msg.sender) {
    _setGovernor(msg.sender);
  }

  function _setGovernor(address _newGovernor) internal virtual {
    governor = _newGovernor;
    BLAST.configureClaimableGas();
    BLAST.configureClaimableYield();

    BLAST.configureGovernor(_newGovernor);
    USDB.configure(YieldMode.CLAIMABLE);
    WETH.configure(YieldMode.CLAIMABLE);
  }

  function setGovernor(address _newGovernor) external onlyOwner {
    _setGovernor(_newGovernor);
  }
}
