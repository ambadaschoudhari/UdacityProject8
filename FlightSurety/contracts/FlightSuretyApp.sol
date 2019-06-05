pragma solidity ^0.5.0;

// It's important to avoid vulnerabilities due to numeric overflow bugs
// OpenZeppelin's SafeMath library, when used correctly, protects agains such bugs
// More info: https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2018/november/smart-contract-insecurity-bad-arithmetic/

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

/************************************************** */
/* FlightSurety Smart Contract                      */
/************************************************** */
contract FlightSuretyApp {
    using SafeMath for uint256; // Allow SafeMath functions to be called for all uint256 types (similar to "prototype" in Javascript)

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    // Flight status codees
    uint8 private constant STATUS_CODE_UNKNOWN = 0;
    uint8 private constant STATUS_CODE_ON_TIME = 10;
    uint8 private constant STATUS_CODE_LATE_AIRLINE = 20; //Relevant
    uint8 private constant STATUS_CODE_LATE_WEATHER = 30;
    uint8 private constant STATUS_CODE_LATE_TECHNICAL = 40;
    uint8 private constant STATUS_CODE_LATE_OTHER = 50;

    uint  private constant AIRLINE_REGISTRATION_FEE = 10 ether;
    uint  private constant AIRLINE_INSURANCE_FEE = 1 ether;

    address private contractOwner;          // Account used to deploy contract

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;
        address airline;
    }
    mapping(bytes32 => Flight) private flights;


    //Prj8: Add reference to data contract in app contract
    FlightSuretyData flightsuretydata;

    //Prj8: Add reference to for multiparty concensus
    address[] multiCallsflightReg = new address[](0);
    address[] multiCallsModeChange = new address[](0);

    mapping (string => address ) flightList;
    string[] flightArray;
    address payable private datacontractaddress;
    /********************************************************************************************/
    /*                                       PRJ-8 events                                       */
    /********************************************************************************************/
    event evntDebugBool(bool bvar);
    event evntDebuguint(uint uintvar);
    event evntDebuguint16(uint16 uint16var);
    uint  unitTestvar1;
    bool  bTestVar2;
    address addrTestVar3;
    
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
         // Modify to call data contract's status
        require(flightsuretydata.dc_isOperational() == true, "App Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnough(uint _price) {
        require(msg.value >= _price, "Registration/Fee amount is not sufficient");
        _;
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwnerApp()
    {
        require(msg.sender == contractOwner, "App Caller is not contract owner");
        _;
    }

    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    /**
    * @dev Contract constructor
    *
    */
    constructor
                                (
                                    address payable DataContractAddress
                                )
                                public
    {
        contractOwner = msg.sender;
        flightsuretydata = FlightSuretyData(DataContractAddress);
        datacontractaddress = DataContractAddress;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/
    //Prj - 8 : get operational info from data contract
    function isOperational()
                            public
                            view
                            returns(bool opstatus)
    {
        return flightsuretydata.dc_isOperational();  // Modify to call data contract's status
    }
    function isAirlineRegistered(
                           address airlineAddress
                       )
                           public
                           view
                           requireIsOperational
                           returns(bool regstatus)
    {
        return flightsuretydata.dc_isAirlineRegistered(airlineAddress);
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

   /**
    * @dev Add an airline to the registration queue
    * Prj 8 : - to be called from Daaap
    */

    function registerAirline
                            (
                                address newAirLineAddress
                            )
                            public
                            payable
                            requireIsOperational
                            paidEnough(AIRLINE_REGISTRATION_FEE)
                            returns(bool success, uint256 votes)
    {
        unitTestvar1 = 0;
        if (flightsuretydata.dc_isAirlineRegistered(newAirLineAddress) == true)
        {
            return(true, 0) ; // airline already registered, don't waste gas
        }
        uint256 airlineCount = flightsuretydata.dc_getAirLineCount();
        //Funding base contract for registration
        datacontractaddress = flightsuretydata.dc_getContractAddress();
        datacontractaddress.transfer(AIRLINE_REGISTRATION_FEE);
        //if (true==true){return (true,1 );}
        unitTestvar1 = 1;
        bool varConsensus = false;
        if (airlineCount < 4)
             {
               unitTestvar1 = 2;
               bool result = flightsuretydata.dc_registerairline(newAirLineAddress);
               return(result, airlineCount);
             }
        else {
              uint256 support = airlineCount.div(2);
              unitTestvar1 = 3;
              varConsensus = isConcensus(multiCallsflightReg, support);
              votes = multiCallsflightReg.length;
              if (varConsensus) {
                    unitTestvar1 = 4;
                    multiCallsflightReg = new address[](0);
                    flightsuretydata.dc_registerairline(newAirLineAddress);
                    return(true, votes);
                }
              else{
                    unitTestvar1 = 5;
                    return(false, votes);
                }
             }
    }

    function setOperatingStatus
                            (
                                bool mode
                            )
                            public
                            {
                               _setOperatingStatus(mode);
                            }

    function _setOperatingStatus
                            (
                                bool mode
                            )
                            private
    {
        bool varConsensus = false;
        uint256 airlineCount = flightsuretydata.dc_getAirLineCount();
        if (airlineCount < 4)
             {
               flightsuretydata.dc_setOperatingStatus(mode,msg.sender);
             }
        else {
              uint256 support = airlineCount.div(2);
              varConsensus = isConcensus(multiCallsModeChange, support);
              if (varConsensus) {
                    multiCallsModeChange = new address[](0);
                    flightsuretydata.dc_setOperatingStatus(mode,msg.sender);
              }
            }
    }

    function isConcensus
              (address[] storage multiCalls, uint256 support) private
               returns (bool consensusOk)
               {
               consensusOk = false;
               bool isDuplicate = false;
               for(uint c = 0; c < multiCalls.length; c++) {
                   if (multiCalls[c] == msg.sender)
                   {
                      isDuplicate = true;
                      break;
                   }
               }
               require(!isDuplicate, "Caller has already called this function.");
               multiCalls.push(msg.sender);
               if (multiCalls.length >= support) {
                   consensusOk = true;
               }
               return consensusOk;
    }

   /**
    * @dev Register a future flight for insuring.
    * Prj 8 : - to be called from Daap
    */

    function registerFlight
                                (
                                    string memory flightID,
                                    address airlineAddress
                                )
                                public
                            requireIsOperational
    {
       require(flightsuretydata.dc_isAirlineRegistered(airlineAddress),
        "Airline shall be part of consortium to register flight");
       flightList[flightID] = airlineAddress;
       flightArray.push(flightID);
    }

    function buy
                            (
                                string memory flightID,
                                string memory ticketNo
                            )
                            public
                            payable
                            requireIsOperational
                            paidEnough(AIRLINE_INSURANCE_FEE)
    {
           datacontractaddress.transfer(AIRLINE_INSURANCE_FEE);
           flightsuretydata.dc_buy(flightID,msg.sender,ticketNo);
    }
   function getClaimStatus
                            (
                                 address passengerAccount
                            )
                            public
                            view
                            returns(string memory claimstaus)
    {
        return flightsuretydata.dc_getClaimStatus(passengerAccount);
    }


   /**
    * @dev Called after oracle has updated flight status
    *
    */
    function processFlightStatus
                                (
                                    address airline,
                                    string memory flightID,
                               //     uint256 timestamp,
                                    uint8 statusCode
                                )
                                internal
                                requireIsOperational
    {
       require(flightsuretydata.dc_isAirlineRegistered(airline), "App:Airline shall be part of consortium");
       //Flight surety flights
       // fetchFlightStatus(airline,flightID);
       if (statusCode == STATUS_CODE_LATE_AIRLINE)
       {
          flightsuretydata.dc_creditInsurees(flightID);
       }

    }
    // test function
    function creditInsurees
                                (
                                   string calldata flightID
                                )
                                //private after test is complete
                                external ///while testing
                                requireIsOperational
    {
         flightsuretydata.dc_creditInsurees(flightID);
    }

    // Generate a request for oracles to fetch flight information
    function fetchFlightStatus
                        (
                            address airline,
                            string calldata flightID
                          //  ,uint256 timestamp
                        )
                        external
                        requireIsOperational
    {
        uint8 index = getRandomIndex(msg.sender);

        // Generate a unique key for storing the request
        //bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
        //bytes32 key = keccak256(abi.encodePacked(index, airline, flightID));
        bytes32 key = keccak256(abi.encodePacked(index, flightID));
        oracleResponses[key] = ResponseInfo({
                                                requester: msg.sender,
                                                isOpen: true
                                            });

        //emit OracleRequest(index, airline, flight, timestamp);
        emit OracleRequest(index, airline, flightID);
    }


// region ORACLE MANAGEMENT

    // Incremented to add pseudo-randomness at various points
    uint8 private nonce = 0;

    // Fee to be paid when registering oracle
    uint256 public constant REGISTRATION_FEE = 1 ether;

    // Number of oracles that must respond for valid status
    uint256 private constant MIN_RESPONSES = 3;


    struct Oracle {
        bool isRegistered;
        uint8[3] indexes;
    }

    // Track all registered oracles
    mapping(address => Oracle) private oracles;

    // Model for responses from oracles
    struct ResponseInfo {
        address requester;                              // Account that requested status
        bool isOpen;                                    // If open, oracle responses are accepted
        mapping(uint8 => address[]) responses;          // Mapping key is the status code reported
                                                        // This lets us group responses and identify
                                                        // the response that majority of the oracles
    }

    // Track all oracle responses
    // Key = hash(index, flight, timestamp)
    mapping(bytes32 => ResponseInfo) private oracleResponses;

    // Event fired each time an oracle submits a response
    //event FlightStatusInfo(address airline, string flight, uint256 timestamp, uint8 status);

    //event OracleReport(address airline, string flight, uint256 timestamp, uint8 status);
    event FlightStatusInfo(address airline, string flightID, uint8 status);

    event OracleReport(address airline, string flightID, uint8 status);

    // Event fired when flight status request is submitted
    // Oracles track this and if they have a matching index
    // they fetch data and submit a response
    //event OracleRequest(uint8 index, address airline, string flight, uint256 timestamp);
     event OracleRequest(uint8 index, address airline, string flightID);

    // Register an oracle with the contract
    function registerOracle
                            (
                            )
                            external
                            payable
                            requireIsOperational
    {
        // Require registration fee
        require(msg.value >= REGISTRATION_FEE, "Registration fee is required");

        uint8[3] memory indexes = generateIndexes(msg.sender);

        oracles[msg.sender] = Oracle({
                                        isRegistered: true,
                                        indexes: indexes
                                    });
    }

    function getMyIndexes
                            (
                            )
                            external
                            view
                            requireIsOperational
                            returns( uint8[3] memory)
    {
        require(oracles[msg.sender].isRegistered, "Not registered as an oracle");

        return oracles[msg.sender].indexes;
    }


    // Called by oracle when a response is available to an outstanding request
    // For the response to be accepted, there must be a pending request that is open
    // and matches one of the three Indexes randomly assigned to the oracle at the
    // time of registration (i.e. uninvited oracles are not welcome)
    function submitOracleResponse
                        (
                            uint8 index,
                            address airline,
                            string calldata flightID,
    //                        uint256 timestamp,
                            uint8 statusCode
                        )
                        external
                        requireIsOperational
    {
        require((oracles[msg.sender].indexes[0] == index) ||
        (oracles[msg.sender].indexes[1] == index) ||
        (oracles[msg.sender].indexes[2] == index), "Index does not match oracle request");


   //     bytes32 key = keccak256(abi.encodePacked(index, airline, flight, timestamp));
   //     bytes32 key = keccak256(abi.encodePacked(index, airline, flightID));
        bytes32 key = keccak256(abi.encodePacked(index, flightID));
        require(oracleResponses[key].isOpen, "Flight or timestamp do not match oracle request");

        oracleResponses[key].responses[statusCode].push(msg.sender);

        // Information isn't considered verified until at least MIN_RESPONSES
        // oracles respond with the *** same *** information
        //emit OracleReport(airline, flight, timestamp, statusCode);
        emit OracleReport(airline, flightID, statusCode);
        if (oracleResponses[key].responses[statusCode].length >= MIN_RESPONSES) {

            //emit FlightStatusInfo(airline, flight, timestamp, statusCode);
            emit FlightStatusInfo(airline, flightID, statusCode);

            // Handle flight status as appropriate
     //       processFlightStatus(airline, flight, timestamp, statusCode);
            processFlightStatus(airline, flightID, statusCode);
        }
    }


    function getFlightKey
                        (
                            address airline,
                            string  memory flightID //,
                            //uint256 timestamp
                        )
                        internal
                        pure
                        returns(bytes32)
    {
        //return keccak256(abi.encodePacked(airline, flight, timestamp));
        return keccak256(abi.encodePacked(airline, flightID));
    }

    // Returns array of three non-duplicating integers from 0-9
    function generateIndexes
                            (
                                address accountS
                            )
                            internal
                            returns(uint8[3] memory)
    {
        uint8[3] memory indexes;
        indexes[0] = getRandomIndex(accountS);

        indexes[1] = indexes[0];
        while(indexes[1] == indexes[0]) {
            indexes[1] = getRandomIndex(accountS);
        }

        indexes[2] = indexes[1];
        while((indexes[2] == indexes[0]) || (indexes[2] == indexes[1])) {
            indexes[2] = getRandomIndex(accountS);
        }

        return indexes;
    }

    // Returns array of three non-duplicating integers from 0-9
    function getRandomIndex
                            (
                                address account
                            )
                            internal
                            returns (uint8)
    {
        uint8 maxValue = 10;

        // Pseudo random number...the incrementing nonce adds variation
        uint8 random = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - nonce++), account))) % maxValue);

        if (nonce > 250) {
            nonce = 0;  // Can only fetch blockhashes for last 256 blocks so we adapt
        }

        return random;
    }
// endregion
}
//Prj - 8 Add code for interfaces
    /********************************************************************************************/
    /*                                     Interface for data contract                          */
    /********************************************************************************************/
contract FlightSuretyData{
    function dc_registerairline
                            (
                                address airlineaddr
                            )
                            external
                            returns(bool success)
    {
    }
    function dc_getAirLineCount
                            (
                            )
                            external
                            pure
                            returns(uint16 airlinecount)
    {
    }
    function dc_isOperational()
                            public
                            view
                            returns(bool)
    {
    }
    function dc_setOperatingStatus
                            (
                                bool mode,
                                address callerAddress
                            )
                            external
    {
    }
    function dc_isAirlineRegistered
                            (
                                address airelineaddr
                            )
                            external
                            view
                            returns(bool)
    {
    }
    function dc_getContractAddress
                            (
                            )
                            external
                            view
                            returns (address payable myAddress)
    {
    }

    function dc_registerFlight
                                (
                                    bytes16 flightID,
                                    address airlineAddress
                                )
                                external
    {
    }
    function dc_buy
                            (
                                string calldata flightID,
                                address payable passengerAccount,
                                string calldata TicketNo
                            )
                            external
                            payable
    {
    }
   function dc_getClaimStatus
                            (
                                 address passengerAccount
                            )
                            external
                            view
                            returns(string memory claimstaus)
    {
    }
    function dc_creditInsurees
                                (
                                   string calldata flightID
                                )
                                external
    {

    }
}
