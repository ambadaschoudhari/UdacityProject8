const FlightSuretyApp = artifacts.require("FlightSuretyApp");
const FlightSuretyData = artifacts.require("FlightSuretyData");
const fs = require('fs');

module.exports = function(deployer) {

    let firstAirline = '0xbd8Be1884f5b7bccCf567c37e2844B82499CCE65';
    deployer.deploy(FlightSuretyData,{from:firstAirline})
    .then(() => {
        return deployer.deploy(FlightSuretyApp,FlightSuretyData.address,{from:firstAirline})
                .then(() => {
                    
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
}