// contracts/AthleteToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract AthleteToken is ERC20, ERC20Permit, ERC20Votes {

    uint public initialSupply = 1000000000e8;
    uint public tokenTotalStake;
    uint public difficultyPerBlock;
    uint public athletePool;

    mapping(address => mapping(uint => Stake)) public stakeSubscriptions;

    struct Stake {
        uint amount;
        uint blockId;
    }

    constructor() ERC20("Athlete Token", "ATH") ERC20Permit("Athlete Token") {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    function subscribeStake(uint _amount) public {
        require(balanceOf(msg.sender) >= _amount);
        require(_amount > (100e8));
        require(stakeSubscriptions[msg.sender][block.number].amount == 0);
        _burn(msg.sender, _amount);
        tokenTotalStake += _amount;
        stakeSubscriptions[msg.sender][block.number] = Stake(_amount, block.number);
        difficultyPerBlock = (initialSupply + (tokenTotalStake * 10)) / 100;
    }

    function unsubscribeStake(uint _blockNumber) public {
        uint amountStake = stakeSubscriptions[msg.sender][_blockNumber].amount;
        uint timeBlocks = (block.number - _blockNumber) * 10 ** decimals();
        require(amountStake > 0);
        require(block.number > _blockNumber);
        tokenTotalStake -= amountStake;
        uint rewards = amountStake / (difficultyPerBlock / timeBlocks);
        athletePool += rewards;
        _mint(msg.sender, amountStake + rewards);
        stakeSubscriptions[msg.sender][_blockNumber].amount = 0;
    }

    function balanceStaked(address wallet, uint _blockNumber) public view returns (uint) {
        return stakeSubscriptions[wallet][_blockNumber].amount;
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

}