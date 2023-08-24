// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract aGLPVault is ERC20("aGLP", "aGLP"), ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;
  using SafeMath for uint256;
  using Address for address payable;

  IERC20 public stakedGlp;
  uint256 public depositFee = 1; // 0.1%
  uint256 public withdrawFee = 1; // 0.1%
  address payable public feeReceiver;

  EnumerableSet.AddressSet private holders;

  constructor(IERC20 _stakedGlp, address payable _feeReceiver) {
    require(_feeReceiver != address(0), "Fee receiver cannot be zero address");
    stakedGlp = _stakedGlp;
    feeReceiver = _feeReceiver;
  }

  function deposit(uint256 glpAmount) external nonReentrant {
    uint256 fee = glpAmount.mul(depositFee).div(1000);
    uint256 amountAfterFee = glpAmount.sub(fee);
    stakedGlp.safeTransferFrom(msg.sender, address(this), glpAmount);
    stakedGlp.safeTransferFrom(address(this), feeReceiver, fee);

    _mint(msg.sender, amountAfterFee);
    holders.add(msg.sender);
    emit Deposit(msg.sender, glpAmount);
  }

  function depositOwner(uint256 glpAmount) external onlyOwner {
    stakedGlp.safeTransferFrom(msg.sender, address(this), glpAmount);
    emit OwnerDeposit(msg.sender, glpAmount);
  }

  function withdraw(uint256 aGlpAmount) public {
    require(balanceOf(msg.sender) >= aGlpAmount, "Not enough aGLP balance");
    uint256 glpToReturn = aGlpAmount.mul(stakedGlp.balanceOf(address(this))).div(totalSupply());
    uint256 fee = glpToReturn.mul(withdrawFee).div(1000);
    uint256 amountAfterFee = glpToReturn.sub(fee);
    _burn(msg.sender, aGlpAmount);
    require(stakedGlp.balanceOf(address(this)) >= amountAfterFee, "Not enough GLP in contract");
    stakedGlp.transfer(msg.sender, amountAfterFee);
    stakedGlp.transfer(feeReceiver, fee);
    emit Withdraw(msg.sender, aGlpAmount);
    if (balanceOf(msg.sender) == 0) {
        holders.remove(msg.sender);
    }
  }

  // Transfer tokens from vault to treasury for yield strategies
  function withdrawOwner(uint256 percentage) external onlyOwner {
    require(percentage > 0 && percentage <= 100, "Percentage must be between 1 and 100");
    uint256 amountToWithdraw = stakedGlp.balanceOf(address(this)).mul(percentage).div(100);
    stakedGlp.transfer(owner(), amountToWithdraw);
  }

  // Distribute yield from treasury to vault holders proportionally
function distributeAGLP(uint256 glpAmount) external onlyOwner {
    require(glpAmount > 0, "Amount must be greater than 0");

    // Transfer GLP tokens from owner to the contract
    stakedGlp.safeTransferFrom(msg.sender, address(this), glpAmount);

    // Mint equivalent aGLP for the contract itself
    _mint(address(this), glpAmount);

    uint256 holderCount = holders.length();
    if (holderCount == 0) return; // No holders to distribute to

    // Distribute the aGLP proportionally to each holder based on their holding
    for (uint256 i = 0; i < holderCount; i++) {
        address holder = holders.at(i);
        uint256 holderShare = balanceOf(holder).mul(glpAmount).div(totalSupply());
        _transfer(address(this), holder, holderShare);
    }

    emit Distribution(msg.sender, glpAmount);
}


  function setFeeReceiver(address payable _feeReceiver) external onlyOwner {
    require(_feeReceiver != address(0), "Fee receiver cannot be zero address");
    feeReceiver = _feeReceiver;
    emit FeeReceiverUpdated(_feeReceiver);
  }

  event Deposit(address indexed user, uint256 amount);
  event OwnerDeposit(address indexed owner, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);
  event FeeReceiverUpdated(address newFeeReceiver);
  event Distribution(address indexed owner, uint256 amount);
}



