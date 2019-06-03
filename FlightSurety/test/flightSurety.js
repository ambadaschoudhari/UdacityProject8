
var Test = require('../config/testConfig.js');
var BigNumber = require('bignumber.js');

contract('Flight Surety Tests', async (accounts) => {

  var config;
  before('setup contract', async () => {
    config = await Test.Config(accounts);
    await config.flightSuretyData.authorizeCaller(config.flightSuretyApp.address);
  });

  /****************************************************************************************/
  /* Operations and Settings                                                              */
  /****************************************************************************************/

  it(`Case 1: (multiparty) has correct initial isOperational() value`, async function () {

    // Get operating status
    let status = await config.flightSuretyApp.isOperational.call();
    assert.equal(status, true, "Incorrect initial operating status value");

  });

  it(`Case 2: (multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
         await config.flightSuretyApp.setOperatingStatus(false, { from: accounts[1] });
       }
      catch(e) {
          console.log("Test case 2 Error : "+e);
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "Access not restricted to Contract Owner");
            
  });

  it(`Case 3: (multiparty) can allow access to setOperatingStatus() for Contract Owner account`, async function () {

      // Ensure that access is allowed for Contract Owner account
      let accessDenied = false;
      let contractOwner = await config.flightSuretyData.whoIsContractOwner();
      //console.log ("contract owner is " + contractOwner)
      try 
      {
          await config.flightSuretyApp.setOperatingStatus(false, {from: contractOwner});
      }
      catch(e) {
          accessDenied = true;
          console.log("Test case 3 Error : "+e);
      }
      assert.equal(accessDenied, false, "Access not restricted to Contract Owner");
      let status = await config.flightSuretyApp.isOperational.call();
      assert.equal(status, false, "Test case 3: Operating status did not get changed");
  });

  it(`Case 4: (multiparty) can block access to functions using requireIsOperational when operating status is false`, async function () {
      //operating status is already false due to previous test case, so commented below line
      //await config.flightSuretyApp.setOperatingStatus(false, {from: contractOwner});

      let reverted = false;
      try 
      {
          //await config.flightSurety.setTestingMode(true);
          await config.flightSuretyApp.registerAirline(accounts[0]);
      }
      catch(e) {
          reverted = true;
          console.log("Test case 4 Error : "+e);
      }
      assert.equal(reverted, true, "Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyApp.setOperatingStatus(true), {from: accounts[0]};
      let status = await config.flightSuretyApp.isOperational.call();
      assert.equal(status, true, "Test case 4: Operating status is not set to true");

  });
/*
  it('Case 5: (airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];

    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline});
    }
    catch(e) {

    }
    let result = await config.flightSuretyData.isAirline.call(newAirline); 

    // ASSERT
    assert.equal(result, false, "Airline should not be able to register another airline if it hasn't provided funding");

  });
 
*/
});
