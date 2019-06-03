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
    //Prj - 8 Add code for to limit authorized callers
    mapping (address => bool) authorizedContracts;

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
        dc_registerairline(msg.sender);
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
                            external
                            requireIsOperational
                            requireAuthorizedCaller
                            returns(bool successflag)
                            
    {
           bool successFlag = false;
           registredAirlines.push(airlineaddr);
           successFlag = true;
           return(successFlag);
    }
    function dc_getAirLineAcount
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
   /**
    * @dev Buy insurance for a flight
    *
    */
    function buy
                            (
                            )
                            external
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                )
                                external
                                pure
    {
    }

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            pure
    {
    }

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
    }


}

