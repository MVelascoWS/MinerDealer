pragma solidity >=0.4.25 <=0.8.17;

import "openzeppelin/contracts/ownership/Ownable.sol";
import "openzeppelin/contracts/lifecycle/Pausable.sol";
import "openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libs/LoanMath.sol";
import "./libs/String.sol";
import "./MinerAPI.sol";
import "./types/CommonTypes.sol";
import "./types/MarketTypes.sol";

contract LoanContract {
    address minerApiAddress;

    using SafeMath for uint256;

    uint256 constant PLATFORM_FEE_RATE = 100;
    address constant WALLET_1 = 0x5Da83193F81B481e5cd50B759D700549a3B5607d;
    uint256 constant SOME_THINGS = 105;
    address admin = 0x666E4f96E7C727c7d68165cAB8b05B5EE1B8E060;

    enum LoanStatus {
        OFFER,
        REQUEST,
        ACTIVE,
        FUNDED,
        REPAID,
        DEFAULT
    }    
    struct LoanData {

        uint256 loanAmount;
        uint256 interestRate; // will be updated on acceptance in case of loan offer        
        uint128 duration;
        uint256 createdOn;
        uint256 startedOn;
        mapping (uint256 => bool) repayments;
        address borrower;
        address lender;
        LoanStatus loanStatus;
    }

    LoanData loan;    

    IERC20 public ERC20;
    
    modifier OnlyBorrower {
        require(msg.sender == loan.borrower, "Not Authorised");
        _;
    }
    
     modifier OnlyAdmin {
        require(msg.sender == admin, "Only Admin");
        _;
    }
    
    modifier OnlyLender {
        require(msg.sender == loan.lender, "Not Authorised");
        _;
    }

    constructor(uint256 _loanAmount, uint128 _duration,
        uint256 _interestRate, address _borrower, address _lender, LoanStatus _loanstatus, address _minerApiAddress) public {
        loan.loanAmount = _loanAmount;
        loan.duration = _duration;
        loan.interestRate = _interestRate;
        loan.createdOn = now;
        loan.borrower = _borrower;
        loan.lender = _lender;
        loan.loanStatus = _loanstatus;       
        minerApiAddress = _minerApiAddress; 
    }

    // after loan offer created
    function transferFundsToLoan() public payable OnlyLender {
         require(msg.value >= loan.loanAmount, "Sufficient funds not transferred");
          loan.loanStatus = LoanStatus.FUNDED;
          //status changed OFFER -> FUNDED
    }
    
    function toString(address x) public returns (string memory) {
        bytes memory b = new bytes(20);
        for (uint i = 0; i < 20; i++)
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        return string(b);
    }    

    function acceptLoanOffer(uint256 _interestRate, address _collateralAddress, uint256 _collateralAmount, uint256 _collateralPriceInETH, uint256 _ltv) public {

        require(loan.loanStatus == LoanStatus.FUNDED, "Incorrect loan status");
        loan.borrower = msg.sender;
    }

   function approveLoanRequest() public payable {

        require(msg.value >= loan.loanAmount, "Sufficient funds not transferred");
        require(loan.loanStatus == LoanStatus.REQUEST, "Incorrect loan status");

        loan.lender = msg.sender;
        loan.loanStatus = LoanStatus.FUNDED;        
        
        loan.startedOn = now;
        MinerAPI minerApiInstance = MinerAPI(minerApiAddress);

        MinerTypes.ChangeBeneficiaryParams memory params;
        params.new_beneficiary = loan.lender;
        params.new_quota = 90;
        params.new_expiration = loan.duration;
        minerApiInstance.change_beneficiary(params);
        address(uint160(loan.borrower)).transfer(loan.loanAmount);
        //loan.loanStatus = LoanStatus.ACTIVE;
    }


    function getLoanData() view public returns (
        uint256 _loanAmount, uint128 _duration, uint256 _interest, uint256 startedOn, LoanStatus _loanStatus,        
        address _borrower, address _lender) {

        return (loan.loanAmount, loan.duration, loan.interestRate, loan.startedOn, loan.loanStatus, loan.collateral.collateralAddress, loan.borrower, loan.lender);
    }    

    function getCurrentRepaymentNumber() view public returns(uint256) {
      return LoanMath.getRepaymentNumber(loan.startedOn, loan.duration);
    }

    function getRepaymentAmount(uint256 repaymentNumber) view public returns(uint256 amount, uint256 monthlyInterest, uint256 fees){

        uint256 totalLoanRepayments = LoanMath.getTotalNumberOfRepayments(loan.duration);

        monthlyInterest = LoanMath.getAverageMonthlyInterest(loan.loanAmount, loan.interestRate, totalLoanRepayments);

        if(repaymentNumber == 1)
            fees = LoanMath.getPlatformFeeAmount(loan.loanAmount, PLATFORM_FEE_RATE);
        else
            fees = 0;

        amount = LoanMath.calculateRepaymentAmount(loan.loanAmount, monthlyInterest, fees, totalLoanRepayments);

        return (amount, monthlyInterest, fees);
    }
    function repayLoan() public payable {

        require(now <= loan.startedOn + loan.duration * 1 minutes, "Loan Duration Expired");

        uint256 repaymentNumber = LoanMath.getRepaymentNumber(loan.startedOn, loan.duration);

        (uint256 amount, , uint256 fees) = getRepaymentAmount(repaymentNumber);

        require(msg.value >= amount, "Required amount not transferred");

        if(fees != 0){
            transferToWallet1(fees);
        }
        uint256 toTransfer = amount.sub(fees);
      

        loan.repayments[repaymentNumber] = true;

        address(uint160(loan.lender)).transfer(toTransfer);
    }

    function transferToWallet1(uint256 fees) private {
        address(uint160(WALLET_1)).transfer(fees);
    }

}