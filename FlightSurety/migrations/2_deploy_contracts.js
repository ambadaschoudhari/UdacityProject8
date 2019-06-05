const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const fs = require('fs');

module.exports = function(deployer) {

    let firstAirline = '0xDB27e7B7fed8c14DE2791239448B909c8aCB8836';
    deployer.deploy(FlightSuretyData,{from:firstAirline})
    .then((flightsuretydata) => {
        return deployer.deploy(FlightSuretyApp,FlightSuretyData.address,{from:firstAirline})
                .then(() => {
                    return flightsuretydata.authorizeCaller(FlightSuretyApp.address,{from:firstAirline}).then(()=>{
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
}