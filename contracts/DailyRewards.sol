// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./library/IterableMapping.sol";

contract DailyRewards is ERC20, AccessControl {
  using IterableMapping for IterableMapping.Map;

  address public admin;

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  IterableMapping.Map private rewardableUserList;
  uint256 public rewardsAmount;

  event onSuccess(string msg);
  event onError(string msg);

  constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
    _mint(msg.sender, (10 ** 9) * (10**18));
    admin = msg.sender;
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  modifier onlyAdmin() {
    require(_msgSender() == admin, "Not admin");
    _;
  }

  function mint(address to, uint256 amount) external onlyAdmin {
    require(hasRole(MINTER_ROLE, _msgSender()), "Caller is not a minter");
    _mint(to, amount);
  }

  function burn(address account, uint256 amount) internal virtual {
    require(hasRole(BURNER_ROLE, _msgSender()), "Caller is not a burner");
    super._burn(account, amount);
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    super.transfer(recipient, amount);
    
    return true;    
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return super.allowance(owner, spender);
  }

  function approve(address spender, uint256 amount) public virtual override returns (bool) {
    super.approve(spender, amount);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
    super.increaseAllowance(spender, addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {
    super.decreaseAllowance(spender, subtractedValue);
    return true;
  }

  function setRewardAmount(uint256 amount) external onlyAdmin returns(bool) {
    require(amount > 0, 'The rewards percentage should be bigger than zero');
    rewardsAmount = amount;
    return true;
  }

  function getRewardStatus(address account) external view returns(uint256) {
    // calculate reward amount per account for now(block.timestamp)
    uint256 lastestRewardTime = rewardableUserList.get(account);
    return lastestRewardTime;
  }

  /* 
  ** Distribute Rewards for now.
  */
  function distributeRewards() external onlyAdmin {
    uint256 numberOfUsers = rewardableUserList.keys.length;
    uint256 iterations = 0;

    if (numberOfUsers == 0) {
      emit onError("There are no users to get rewards");
      return;
    }

    while (iterations < numberOfUsers) {
      address userAddress = rewardableUserList.getKeyAtIndex(iterations);
      uint256 lastestRewardTime = rewardableUserList.get(userAddress);
      
      if (block.timestamp - lastestRewardTime > 0) {
        _mint(userAddress, block.timestamp - lastestRewardTime / 86400 * rewardsAmount);
      }
      
      iterations ++;
      rewardableUserList.set(userAddress, block.timestamp);
    }

    emit onSuccess("The rewards was distributed successfully");
  }

  /* 
  ** Create new node that can get reward
  */
  function createNode(address account) external onlyAdmin {
    rewardableUserList.set(account, block.timestamp);

    emit onSuccess("New code was created successfully");
  }
}