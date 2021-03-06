
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
    assert.equal(status, true, "TC1: Incorrect initial operating status value");

  });

  it(`Case 2: (multiparty) can block access to setOperatingStatus() for non-Contract Owner account`, async function () {

      // Ensure that access is denied for non-Contract Owner account
      let accessDenied = false;
      try 
      {
         await config.flightSuretyApp.setOperatingStatus(false, { from: accounts[1] });
       }
      catch(e) {
          //console.log("Test case 2 Error : "+e);
          accessDenied = true;
      }
      assert.equal(accessDenied, true, "TC2: Access not restricted to Contract Owner");
            
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
      assert.equal(status, false, "TC3: Operating status did not get changed");
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
      assert.equal(reverted, true, "TC4: Access not blocked for requireIsOperational");      

      // Set it back for other tests to work
      await config.flightSuretyApp.setOperatingStatus(true), {from: accounts[0]};
      let status = await config.flightSuretyApp.isOperational.call();
      assert.equal(status, true, "TC4: Operating status is not set to true");

  });

  it('Case 5: (airline) cannot register an Airline using registerAirline() if it is not funded', async () => {
    
    // ARRANGE
    let newAirline = accounts[2];
    let status = await config.flightSuretyApp.isOperational.call();
    console.log("status: "+status)
    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline});
    }
    catch(e) {
      console.log("Test case 5 Error : "+e);
    }
    let result = await config.flightSuretyApp.isAirlineRegistered(newAirline); 

    assert.equal(result, false, "TC5: Airline should not be able to register another airline if it hasn't provided funding");

  });

   it('Case 6: (airline) cannot register an Airline using registerAirline() if it is not funded enough', async () => {
    
    // ARRANGE
    let newAirline = accounts[6];
    let status = await config.flightSuretyApp.isOperational.call();
    let reg_fee =  web3.utils.toWei("9", "ether")

    console.log("status: "+status)
    // ACT
    try {
        await config.flightSuretyApp.registerAirline(newAirline, {from: config.firstAirline, value : reg_fee});
    }
    catch(e) {
      console.log("Test case 6 Error : "+e);
    }
    let result = await config.flightSuretyApp.isAirlineRegistered(newAirline); 

    assert.equal(result, false, " TC6: Airline should not be able to register another airline if it hasn't provided funding");

  });

  it('Case 7: First 4 airlines can be registered without consensus & 5th with consensus', async () => {
    
    // ARRANGE
    let Airline_2 = accounts[2];
    let Airline_3 = accounts[3];
    let Airline_4 = accounts[4];
    let reg_fee =  web3.utils.toWei("10", "ether")
    let Airline_5 = accounts[5];    

    
    //let status = await config.flightSuretyApp.isOperational.call();
    //console.log("UC7 status: "+status)
    await config.flightSuretyApp.registerAirline(Airline_2, {from: config.firstAirline, value : reg_fee});
    let result2 = await config.flightSuretyApp.isAirlineRegistered(Airline_2); 
    console.log("Second airline registration status : " + result2);
    //let testvar1 = await config.flightSuretyApp.TestVar1(); 
    //console.log("Test Var Value : " + testvar1);    
    assert.equal(result2, true, "TC7: Register second airline without concenus");

    //registered airline is able to register another airline
    await config.flightSuretyApp.registerAirline(Airline_3, {from: Airline_2, value : reg_fee});
    let result3 = await config.flightSuretyApp.isAirlineRegistered(Airline_3); 
    assert.equal(result3, true, "TC7: Register third airline without concenus");
    console.log("Third airline registration status : " + result3);    

    await config.flightSuretyApp.registerAirline(Airline_4, {from: Airline_3, value : reg_fee});
    let result4 = await config.flightSuretyApp.isAirlineRegistered(Airline_4); 
    console.log("Fourth airline registration status : " + result4);    
    assert.equal(result4, true, "TC7: Register fourth airline without concenus");

    await config.flightSuretyApp.registerAirline(Airline_5, {from: Airline_3, value : reg_fee});
    let result5_1 = await config.flightSuretyApp.isAirlineRegistered(Airline_5); 
    console.log("Fifth airline registration status 1: " + result5_1);    
    assert.equal(result5_1, false, "TC7: Register attempt  of fifth airline with only one reco");

    await config.flightSuretyApp.registerAirline(Airline_5, {from: Airline_2, value : reg_fee});
    let result5_2 = await config.flightSuretyApp.isAirlineRegistered(Airline_5); 
    console.log("Fifth airline registration status 2: " + result5_2);    
    assert.equal(result5_2, true, "TC7: Register attempt  of fifth airline with 50% reco");


  });  

  it('Case 8: User is allowed to buy insurance & Refunded', async () => {
    
    // ARRANGE
    let User6 = accounts[6];
    let Airline_2 = accounts[2];

    console.log("User to buy contract:" + User6);
    let reg_fee =  web3.utils.toWei("2", "ether");
    await config.flightSuretyApp.buy(Airline_2,'AI--6666--:16:30','A-34', {from: User6, value : reg_fee});
    let claimStatus6 = "None";   
    claimStatus6 = await config.flightSuretyApp.getClaimStatus(User6);
    assert.equal(claimStatus6, "Insured", "TC8: Passenger 6 Shall be able to buy insurance");

    let User7 = accounts[7];
    await config.flightSuretyApp.buy(Airline_2,'AI--7777--:17:30','A-34', {from: User7, value : reg_fee});
    let claimStatus7 = "None";   
    claimStatus7 = await config.flightSuretyApp.getClaimStatus(User7);
    assert.equal(claimStatus7, "Insured", "TC8: Passenger 7 Shall be able to buy insurance");

    let User8 = accounts[8];
    await config.flightSuretyApp.buy(Airline_2,'AI--8888--:18:30','A-34', {from: User8, value : reg_fee});
    let claimStatus8 = "None";   
    claimStatus8 = await config.flightSuretyApp.getClaimStatus(User8);
    assert.equal(claimStatus8, "Insured", "TC8: Passenger 8 Shall be able to buy insurance");

    //Below test requires flightSuretyApp.creditInsurees to be modified 
    //to make it a public function
    await config.flightSuretyApp.creditInsurees('AI--6666--:16:30');
    claimStatus = await config.flightSuretyApp.getClaimStatus(User6);
    assert.equal(claimStatus, "Settled", "TC8: Passenger Shall be paid Claim");


  });  

  

});

