// contracts/AthleteToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AthleteToken is ERC20 {

    uint public tokenTotalStake;
    uint public difficultyPerBlock;
    uint public initialSupply = 100000000000000000;

    mapping(address => mapping(uint => Stake)) public stakeSubscriptions;

    struct Stake {
        uint256 amount;
        uint256 blockId;
    }

    constructor() ERC20("Athlete Token", "ATH") {
        _mint(msg.sender, initialSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 8;
    }

    function subscribeStake(uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount);
        require(_amount > 10000000000);
        require(stakeSubscriptions[msg.sender][block.number].amount == 0);
        _burn(msg.sender, _amount);
        tokenTotalStake += _amount;
        stakeSubscriptions[msg.sender][block.number] = Stake(_amount, block.number);
        difficultyPerBlock = ((tokenTotalStake * 100) + (initialSupply / 5)) / 200;
    }

    function unsubscribeStake(uint _blockNumber) public {
        uint256 amountStake = stakeSubscriptions[msg.sender][_blockNumber].amount;
        uint256 qtdBlocks = block.number - _blockNumber;
        require(amountStake > 0);
        require(block.number > _blockNumber);
        tokenTotalStake -= amountStake;
        amountStake += (amountStake / (difficultyPerBlock / (qtdBlocks * 100000000)));
        _mint(msg.sender, amountStake);
        stakeSubscriptions[msg.sender][_blockNumber].amount = 0;
    }

    function balanceStaked(address wallet, uint _blockNumber) public view returns (uint256) {
        return stakeSubscriptions[wallet][_blockNumber].amount;
    }

}