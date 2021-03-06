const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const fs = require('fs');
let reg_fee =  web3.utils.toWei("10", "ether");

module.exports = function(deployer) {

    let firstAirline = '0x2dcE7d6Fe2d371a8269068F520Db4b7A544E3405';
    //let firstAirline = accounts[1];
    deployer.deploy(FlightSuretyData,{from:firstAirline})
    .then((flightsuretydata) => {
        return deployer.deploy(FlightSuretyApp,FlightSuretyData.address,{from:firstAirline})
                .then((flightsuretyapp) => {
                    return flightsuretydata.authorizeCaller(
                        FlightSuretyApp.address,{from:firstAirline}).then(()=>{
                            return flightsuretyapp.registerAirline
                            (firstAirline, {from: firstAirline, value : reg_fee}).then(()=>{
                                let config = {
                                localhost: {
                                    url: 'HTTP://127.0.0.1:7545',
                                    dataAddress: FlightSuretyData.address,
                                    appAddress: FlightSuretyApp.address
                                    }
                                }   
                                fs.writeFileSync(__dirname + '/../src/dapp/config.json',JSON.stringify(config, null, '\t'), 'utf-8');
                                fs.writeFileSync(__dirname + '/../src/server/config.json',JSON.stringify(config, null, '\t'), 'utf-8');
                            });
                            });
                    });
            });
}