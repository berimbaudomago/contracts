// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleBet is Ownable {

    address public depositToken;
    address public treasuryFeesAddress;
    uint256 public depositedFirstTeam;
    uint256 public depositedSecondTeam;
    uint256 public depositedDraw;
    uint256 public winnerId;
    uint256 public remaining;
    bool public isOver = false;
    mapping(address => uint256) public depositedUserFirstTeam;
    mapping(address => uint256) public depositedUserSecondTeam;
    mapping(address => uint256) public depositedUserDraw;


    modifier onlyFinished() {
        require(isOver, "Bet still ongoing!");
        _;
    }

    function setDepositToken(address _token) external onlyOwner {
        depositToken = _token;
        emit ChangeDepositToken(_token);
    }

    function setWinner(uint256 _team) external onlyOwner {
        require(!isOver, "Bet has already been settled!");
        winnerId = _team;
        isOver = true;

        
    }

    function depositTeam(uint256 _userChoice, uint256 _amount) external {
        if (_userChoice == 1) {
            depositedUserFirstTeam[msg.sender] += _amount;
            depositedFirstTeam += _amount;
        } else if (_userChoice == 2) { 
            depositedUserSecondTeam[msg.sender] += _amount;
            depositedSecondTeam += _amount;
        } else { 
            depositedUserDraw[msg.sender] += _amount;
            depositedDraw += _amount;
        }
    }

    function withdraw(uint256 _amount) external onlyFinished {
        if (winnerId == 1) {
            require(depositedUserFirstTeam[msg.sender] > 0, "No deposits into winning bet.");
            //depositedSecondTeam -= fees;
            //depositedDraw -= fees;
            uint256 amount = ((depositedSecondTeam + depositedFirstTeam + depositedDraw) * depositedUserFirstTeam[msg.sender]) / depositedFirstTeam;


        } else if (winnerId == 2) { 
            require(depositedUserSecondTeam[msg.sender] > 0, "No deposits into winning bet.");
            //depositedFirstTeam -= fees;
            //depositedDraw -= fees;
            uint256 amount = ((depositedSecondTeam + depositedFirstTeam + depositedDraw) * depositedUserSecondTeam[msg.sender]) / depositedSecondTeam;
            
        } else { 
            require(depositedUserDraw[msg.sender] > 0, "No deposits into winning bet.");
            //depositedFirstTeam -= fees;
            //depositedSecondTeam -= fees;
            uint256 amount = ((depositedSecondTeam + depositedFirstTeam + depositedDraw) * depositedUserDraw[msg.sender]) / depositedDraw;
        }
    }

    constructor(address _treasuryFeesAddress) {
        treasuryFeesAddress = _treasuryFeesAddress;
    }

    event ChangeDepositToken(address indexed _token);

}   