pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;        // Account used to deploy contract
    bool private operational = true;      // Blocks all state changes throughout the contract if false
    //Prj - 8 Add code for registred airlines
    address[] private registredAirlines = new address[](0);
    
    struct InsuredTickets{
        address payable passengerAccount;
        string TicketNo;
    }
    
    mapping (string => InsuredTickets[]) insuredFlights;  //Flight ID => Insured
    //string [] private flightlist = new string("");
    // seat No ==> Airline ID, flight ID, time, SeatNo, Insured? in future, for now do it in node
    mapping (address => string) private claimStatus;//only one insurance allowed at a time for a passenger

    //Prj - 8 Add code for to limit authorized callers
    mapping (address => bool) authorizedContracts;

    event evntDebugBool(bool bvar);
    event evntDebuguint(uint uintvar);
    event evntTktInsured(address passengerAccount);
    event evntClaimPaid(string flightID);

    uint  unitTestvar1;
    bool  bTestVar2;
    function TestVar1()
                            public
                            view
                            returns(uint)
    {
        return unitTestvar1;
    }
    function TestVar2()
                            public
                            view
                            returns(bool)
    {
        return bTestVar2;
    }

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                )
                                public
    {
        contractOwner = msg.sender;
        //register first airline
        registredAirlines.push(msg.sender);
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational()
    {
        require(operational == true, "Flight Contracts are currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner(address callerAddress)
    {
//        require(msg.sender == contractOwner, "Data Caller is not contract owner");
        require(callerAddress == contractOwner, "Data Caller is not contract owner");

        _;
    }

    modifier requireAuthorizedCaller()
    {
        require(authorizedContracts[msg.sender] == true, "Data Caller is not Authorized");
        _;
    }
    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */
    function dc_isOperational()
                            public
                            view
                            requireAuthorizedCaller
                            returns(bool)
    {
        return operational;
    }
    //debug function to check contract owner
    function whoIsContractOwner()
                            public             //private
                            view
                            returns(address)
    {
        return contractOwner;
        //return msg.sender;
    }
    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */
    function dc_setOperatingStatus
                            (
                                bool mode,
                                address callerAddress
                            )
                            external
                            requireContractOwner(callerAddress)
                            requireAuthorizedCaller
    {
        operational = mode;
    }
    //Prj-8 share data contract address
    function dc_getContractAddress
                            (
                            )
                            external
                            view
                            requireAuthorizedCaller
                            returns (address payable myAddress)
    {
        return (address(this));
    }
    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */
    function dc_registerairline
                            (
                                address airlineaddr
                            )
                            public
                            payable
                            requireIsOperational
                            requireAuthorizedCaller
                            returns(bool successflag)
    {
           bool successFlag = false;
           registredAirlines.push(airlineaddr);
           successFlag = true;
           unitTestvar1 = 2;
           //if (true==true){return (true);}
           return(successFlag);
    }

    function dc_isAirlineRegistered
                            (
                                address airelineaddr
                            )
                            external
                            view
                            requireIsOperational
                            requireAuthorizedCaller
                            returns(bool IsRegistered)
    {
           IsRegistered = false;
               for(uint c = 0; c < registredAirlines.length; c++) {
                   if (registredAirlines[c] == airelineaddr)
                   {
                      IsRegistered = true;
                      break;
                   }
               }
           return(IsRegistered);
    }

   function dc_getClaimStatus
                            (
                                 address passengerAccount
                            )
                            external
                            requireIsOperational
                            requireAuthorizedCaller
                            view
                            returns(string memory claimstaus)
    {
        return (claimStatus[passengerAccount]);
    }

    function dc_getAirLineCount
                            (
                            )
                            external
                            //requireIsOperational
                            requireAuthorizedCaller
                            view
                            returns(uint16 airlinecount)
    {
        return (uint16(registredAirlines.length));
    }

    function authorizeCaller(address allowedCallerAddress)
                           public
                           requireIsOperational
                           requireContractOwner(msg.sender)
    {
        authorizedContracts[allowedCallerAddress] = true;
    }
    // Unused function to be used later
    /*
    function dc_registerFlight
                                (
                                    bytes16 flightID,
                                    address airlineAddress
                                )
                                public
                                requireIsOperational
    {
           require(dc_isAirlineRegistered(airlineAddress), "Airline must be registerd");
           InsuredTickets memory insuredTkt;
           insuredTkt.passengerAccount = address(0);
           insuredTkt.TicketNo = 0x0000000000000000;
           insuredFlights[flightID].push(insuredTkt);
                    
    }
*/
   /**
    * @dev Buy insurance for a flight
    *
    */
    function dc_buy
                            (
                                string calldata flightID,
                                address payable passengerAccount,
                                string calldata ticketNo
                            )
                            external
                            payable
                            requireIsOperational
                            requireAuthorizedCaller
    {
           InsuredTickets memory insuredTkt;
           insuredTkt.passengerAccount = passengerAccount;
           insuredTkt.TicketNo = ticketNo;
           insuredFlights[flightID].push(insuredTkt);
           claimStatus[passengerAccount] = 'Insured';
           emit evntTktInsured(passengerAccount);
    }



    /**
     *  @dev Credits payouts to insurees
    */
    function dc_creditInsurees
                                (
                                   string calldata flightID
                                )
                                external
                                requireIsOperational
                                requireAuthorizedCaller
    {
        for (uint c = 0; c < insuredFlights[flightID].length; c++ )
        {
             uint PAYMENT_AMOUNT = 1.5 ether;
             address payable passengeraccount = insuredFlights[flightID][c].passengerAccount;
             passengeraccount.transfer(PAYMENT_AMOUNT);
             claimStatus[passengeraccount] = 'Settled';
        }
        delete insuredFlights[flightID];
        emit evntClaimPaid(flightID);
    }

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
  //  function pay
  //                          (
  //                              uint256 fundAmount
  //                          )
  //  {
  //      currentFund = currentFund.add(fundAmount);
  //  }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */
    function fund
                            (
                            )
                            public
                            payable
    {
         require(msg.value >= 1 ether,"Registration/fee has to me minimum 1 ether");
         //need to check on how to use safemath
         //currentFund = uint(msg.value);
         emit evntDebuguint(uint(msg.value));
         return;


    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        internal
                        pure
                        returns(bytes32)
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function()
                            external
                            payable
    {
        fund();
        emit evntDebuguint(1);
    }


}

