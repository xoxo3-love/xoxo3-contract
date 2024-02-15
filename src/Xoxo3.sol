// SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/ownable.sol';
// import '@openzeppelin/contracts/utils/math/SafeMath.sol';

pragma solidity 0.8.24; 

contract Xoxo3 is ERC20, Ownable {
  // using SafeMath for uint256;

  address public feeAccount;

  uint256 public txFeeRatio;
  uint256 public burnRatio;

  // constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) Ownable(msg.sender) {
  constructor() ERC20("Xoxo3.love Token", "XOXO3") Ownable(msg.sender) {
    feeAccount = msg.sender;
    txFeeRatio = 1;
    burnRatio = 1;
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
    uint256 burnAmount = amount* burnRatio / 1000;
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
}