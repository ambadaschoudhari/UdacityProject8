
var FlightSuretyApp = artifacts.require("FlightSuretyApp");
var FlightSuretyData = artifacts.require("FlightSuretyData");
var BigNumber = require('bignumber.js');

var Config = async function(accounts) {
    
    // These test addresses are useful when you need to add
    // multiple users in test scripts
    let testAddresses = [
        "0xbd8Be1884f5b7bccCf567c37e2844B82499CCE65",
        "0x2dcE7d6Fe2d371a8269068F520Db4b7A544E3405",
        "0x497F395B14B82d9F7b328BBDDCDe043843345f74",
        "0xEAA6dBc0aF6BEDa5866334bA9e17025b6fEb6335",
        "0x350c9faE06Fa0315A5d97DE422DDe2e35bfA2344",
        "0x3e237d35Fcc7C75516a71d805EdDEa7f0083Dd16",
        "0x685Fff4478CA19B3D18eef6a6a1fB007F63F4e97",
        "0xDB27e7B7fed8c14DE2791239448B909c8aCB8836",
        "0x2B66D8343A1bD7E4256688bb60f4d80Fd2B3162A"
    ];


    let owner = accounts[0];
    let firstAirline = accounts[1];

    let flightSuretyData = await FlightSuretyData.new();
    let flightSuretyApp = await FlightSuretyApp.new(flightSuretyData.address);

    
    return {
        owner: owner,
        firstAirline: firstAirline,
        weiMultiple: (new BigNumber(10)).pow(18),
        testAddresses: testAddresses,
        flightSuretyData: flightSuretyData,
        flightSuretyApp: flightSuretyApp
    }
}

module.exports = {
    Config: Config
};