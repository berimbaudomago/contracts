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
    uint256 public totalDeposited;
    bool public isOver = false;
    mapping(address => uint256) public depositedUserFirstTeam;
    mapping(address => uint256) public depositedUserSecondTeam;
    mapping(address => uint256) public depositedUserDraw;

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

    modifier onlyFinished() {
        require(isOver, "Bet still ongoing!");
        _;
    }

    function setWinner(uint256 _team) external onlyOwner {
        require(!isOver, "Bet has already been settled!");
        winnerId = _team;
        isOver = true;
        uint256 amount;

        totalDeposited = depositedFirstTeam + depositedSecondTeam + depositedDraw;

        if (winnerId == 1) {
            amount = ((depositedSecondTeam + depositedDraw) * loserFee) / decimals;
        } else if (winnerId == 2) {
            amount = ((depositedFirstTeam + depositedDraw) * loserFee) / decimals;
        } else {
            amount = ((depositedFirstTeam + depositedSecondTeam) * loserFee) / decimals;
        }
        
        totalDeposited -= amount;

        depositToken.transferFrom(address(this), treasuryFeesAddress, amount);
    }

    function depositTeam(uint256 _userChoice, uint256 _amount) external nonReentrant {
        if (_userChoice == 1) {
            depositToken.transferFrom(msg.sender, address(this), _amount);
            depositedUserFirstTeam[msg.sender] += _amount;
            depositedFirstTeam += _amount;
        } else if (_userChoice == 2) { 
            depositToken.transferFrom(msg.sender, address(this), _amount);
            depositedUserSecondTeam[msg.sender] += _amount;
            depositedSecondTeam += _amount;
        } else { 
            depositToken.transferFrom(msg.sender, address(this), _amount);
            depositedUserDraw[msg.sender] += _amount;
            depositedDraw += _amount;
        }
    }

    function withdraw() external onlyFinished nonReentrant {
        uint256 amountToWithdraw;
        if (winnerId == 1) {
            require(depositedUserFirstTeam[msg.sender] > 0, "No deposits into winning bet.");
            amountToWithdraw = (totalDeposited * depositedUserFirstTeam[msg.sender]) / depositedFirstTeam;
        } else if (winnerId == 2) { 
            require(depositedUserSecondTeam[msg.sender] > 0, "No deposits into winning bet.");
            amountToWithdraw = (totalDeposited * depositedUserSecondTeam[msg.sender]) / depositedSecondTeam;
        } else { 
            require(depositedUserDraw[msg.sender] > 0, "No deposits into winning bet.");
            amountToWithdraw = (totalDeposited * depositedUserDraw[msg.sender]) / depositedDraw;
        }

        depositToken.transferFrom(address(this), msg.sender, amountToWithdraw);
    }

    event ChangeDepositToken(address indexed _token);

}   