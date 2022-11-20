pragma solidity ^0.5.0;

import "openzeppelin/contracts/ownership/Ownable.sol";
import "openzeppelin/contracts/lifecycle/Pausable.sol";
import "./LoanContract.sol";
import "./MinerAPI.sol";
import "./types/CommonTypes.sol";
import "./types/MarketTypes.sol";

contract LoanCreator is Ownable, Pausable {
    address minerApiAddress;
    address[] public loans;


 constructor() public {
    minerApiAddress = _minerApiAddress; 
 }
 
 function createNewLoanOffer(uint256 _loanAmount, uint128 _duration, string memory _acceptedCollateralsMetadata) public returns(address _loanContractAddress) {

         _loanContractAddress = address (new LoanContract(_loanAmount, _duration, 0, address(0), msg.sender, LoanContract.LoanStatus.OFFER, minerApiAddress));

         loans.push(_loanContractAddress);

         emit LoanOfferCreated(msg.sender, _loanContractAddress);

         return _loanContractAddress;
 }

 function createNewLoanRequest(uint256 _loanAmount, uint128 _duration, uint256 _interest)
 public returns(address _loanContractAddress) {
        //Validate Miner reputation
         _loanContractAddress = address (new LoanContract(_loanAmount, _duration, _interest, msg.sender, address(0), LoanContract.LoanStatus.REQUEST, minerApiAddress));

         loans.push(_loanContractAddress);

         emit LoanRequestCreated(msg.sender, _loanContractAddress);

         return _loanContractAddress;
 }

 function getAllLoans() public view returns(address[] memory){
     return loans;
 }

}