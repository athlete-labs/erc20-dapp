// contracts/AthleteToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract AthleteToken is ERC20, ERC20Permit, ERC20Votes {

    uint public initialSupply = 1000000000e8;
    uint public tokenTotalStake;
    uint public difficultyPerBlock;
    uint public athletePool;
    uint public costNewOperator = 100e8;
    uint public costNewScout = 200e8;
    uint public costUpLevel = 50e8;

    mapping(address => mapping(uint => Stake)) public stakeSubscriptions;
    mapping(address => Worker) public workers;
    mapping(address => Athlete) public athletes;

    enum roles { operator, scout }

    struct Stake {
        uint amount;
        uint blockId;
    }

    struct Worker {
        roles role;
        uint8 level;
        bool banned;
    }

    struct Athlete {
        string performance;
        bool banned;
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

    function balanceStaked(address _wallet, uint _blockNumber) public view returns (uint) {
        return stakeSubscriptions[_wallet][_blockNumber].amount;
    }

    function registerWorker(address _wallet, uint8 kind) public {
        require(kind > 0 && kind < 3);
        if (kind == 1) {
            _burn(_wallet, costNewOperator);
            athletePool += costNewOperator / 2;
            workers[_wallet] = Worker(roles.operator, 0, false);
        }
        if (kind == 2) {
            _burn(_wallet, costNewScout);
            athletePool += costNewScout / 2;
            workers[_wallet] = Worker(roles.scout, 0, false);
        }
    }

    function registerAthlete(address _wallet) public {
        athletes[_wallet] = Athlete("", false);
    }

    function banWorker(address _wallet) public {
        workers[_wallet].banned = true;
    }

    function banAthltete(address _wallet) public {
        athletes[_wallet].banned = true;
    }

    function getWorker(address _wallet) public view returns (Worker memory worker) {
        return workers[_wallet];
    }

    function upLevelWorker(address _wallet) public {
        _burn(_wallet, costUpLevel);
        athletePool += costUpLevel / 2;
        workers[_wallet].level += 1;
    }

    function evaluateAthlete(address _wallet, string memory _performance) public {
        athletes[_wallet].performance = _performance;
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