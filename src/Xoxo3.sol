// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/ownable.sol";

import "./IBlast.sol";
import "./IERC20Rebasing.sol";

pragma solidity 0.8.24;

contract Xoxo3 is ERC20, Ownable {
  IBlast public constant BLAST = IBlast(0x4300000000000000000000000000000000000002);
  IERC20Rebasing public constant USDB = IERC20Rebasing(0x4200000000000000000000000000000000000022);
  IERC20Rebasing public constant WETH = IERC20Rebasing(0x4200000000000000000000000000000000000023);

  address public feeAccount;
  address public governor;

  uint256 public txFeeRatio;
  uint256 public burnRatio;

  // constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) Ownable(msg.sender) {
  constructor() ERC20("Xoxo3.love Token", "XOXO3") Ownable(msg.sender) {
    feeAccount = msg.sender;
    txFeeRatio = 1;
    burnRatio = 1;
    _setGovernor(msg.sender);
  }

  function mint(address account, uint256 amount) external onlyOwner {
    _mint(account, amount);
  }

  function burn(address account, uint256 burnAmount) external onlyOwner {
    _burn(account, burnAmount);
  }

  function transfer(address to, uint256 amount) public virtual override returns (bool) {
    //查询余额
    _spendAllowance(msg.sender, to, amount);

    //交易收取手续费
    uint256 txFee = amount * txFeeRatio / 1000;
    //燃烧掉费用
    uint256 burnAmount = amount * burnRatio / 1000;
    //真实金额
    uint256 realAmount = amount - txFee - burnAmount;

    _transfer(msg.sender, to, realAmount);
    if (txFee > 0) {
      _transfer(msg.sender, feeAccount, txFee);
    }
    if (burnAmount > 0) {
      _burn(msg.sender, burnAmount);
    }
    return true;
  }

  //设置地址和交易费比例
  function setFeeAddress(address _feeAccount, uint256 _txFeeRatio, uint256 _burnRatio) external onlyOwner {
    feeAccount = _feeAccount;
    txFeeRatio = _txFeeRatio;
    burnRatio = _burnRatio;
  }

  function setFeeAddress(address _newOwnerAccount) external onlyOwner {
    _transferOwnership(_newOwnerAccount);
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
