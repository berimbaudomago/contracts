// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IERC20.sol";

contract SimpleBet is Ownable, ReentrancyGuard {

    IERC20 public depositToken;
    address public treasuryFeesAddress;
    uint256 public depositedFirstTeam;
    uint256 public depositedSecondTeam;
    uint256 public depositedDraw;
    uint256 public winnerId;
    uint256 public remaining;
    uint256 public loserFee;
    uint256 public decimals;
    bool public isOver = false;
    mapping(address => uint256) public depositedUserFirstTeam;
    mapping(address => uint256) public depositedUserSecondTeam;
    mapping(address => uint256) public depositedUserDraw;

    modifier onlyFinished() {
        require(isOver, "Bet still ongoing!");
        _;
    }

    function setWinner(uint256 _team) external onlyOwner {
        require(!isOver, "Bet has already been settled!");
        winnerId = _team;
        isOver = true;

        if (winnerId == 1) {
            uint256 amount = ((depositedSecondTeam + depositedDraw) * loserFee) / decimals;
        } else if (winnerId == 2) {
            uint256 amount = ((depositedFirstTeam + depositedDraw) * loserFee) / decimals;
        } else {
            uint256 amount = ((depositedFirstTeam + depositedSecondTeam) * loserFee) / decimals;
        }

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

    function withdraw(uint256 _amount) external onlyFinished nonReentrant {
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

    constructor(
        address _treasuryFeesAddress, 
        uint256 _loserFee, 
        uint256 _tokenDecimals, 
        address _depositToken 
    ) {
        treasuryFeesAddress = _treasuryFeesAddress;
        loserFee = _loserFee;
        depositToken = IERC20(_depositToken);
        decimals = _tokenDecimals;
    }

    event ChangeDepositToken(address indexed _token);

}   