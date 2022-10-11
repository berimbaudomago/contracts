// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./SimpleBet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Deployer is Ownable {

    function deployBet(
        address _treasuryFeesAddress, 
        uint256 _loserFee, 
        uint256 _tokenDecimals, 
        address _depositToken,
        string memory _firstTeam,
        string memory _secondTeam 
    ) external returns (address) {
        SimpleBet simplebet = new SimpleBet(_treasuryFeesAddress, _loserFee, _tokenDecimals, _depositToken);
        emit NewBetDeployed(_firstTeam, _secondTeam, address(simplebet));
        return address(simplebet);  
    }
    
    event NewBetDeployed(string _firstTeam, string _secondTeam, address indexed _betAddress);
 
}