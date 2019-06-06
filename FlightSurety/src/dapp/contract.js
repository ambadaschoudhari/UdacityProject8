import FlightSuretyApp from '../../build/contracts/FlightSuretyApp.json';
import Config from './config.json';
import Web3 from 'web3';

export default class Contract {
    constructor(network, callback) {

        let config = Config[network];
        this.web3 = new Web3(new Web3.providers.HttpProvider(config.url));
        //this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, config.dataAddress);
        this.flightSuretyApp = new this.web3.eth.Contract(FlightSuretyApp.abi, config.appAddress);
        //console.log(this.flightSuretyApp.address);
       

        this.owner = null;
        this.airlines = [];
        this.passengers = [];
        this.initialize(callback);
    }

    initialize(callback) {
        this.web3.eth.getAccounts((error, accts) => {
           
            this.owner = accts[0];

            let counter = 1;
            
            while(this.airlines.length < 5) {
                this.airlines.push(accts[counter++]);
            }

            while(this.passengers.length < 5) {
                this.passengers.push(accts[counter++]);
            }

            callback();
        });
    }

    isOperational(callback) {
       let self = this;
       self.flightSuretyApp.methods
            .isOperational()
            .call({ from: self.owner}, callback);
    }

    fetchFlightStatus(flight, callback) {
        let self = this;
        let payload = {
            airline: self.airlines[0],
            flight: flight,
            timestamp: Math.floor(Date.now() / 1000)
        } 
        self.flightSuretyApp.methods
//            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
              .fetchFlightStatus(payload.airline, payload.flight)
            .send({ from: self.owner}, (error, result) => {
                callback(error, payload);
            });
    }

    buyInsurance(flightID, seatnumber,premium,callback) {

        let self = this;
        let passengerAddr ="0xbd8Be1884f5b7bccCf567c37e2844B82499CCE65"; 
        let airlineAddr ="0xDB27e7B7fed8c14DE2791239448B909c8aCB8836";
       // this.reg_fee =  this.web3.utils.toWei("1", "ether");
        let price = self.web3.utils.toWei(premium, "ether");
        console.log("Airlne: ",airlineAddr," Price ",price);
        let payload = {
            airline: airlineAddr,
            flightID: flightID,
            seatNo:  seatnumber,
            Price:  price
        } 
        self.flightSuretyApp.methods
//            .fetchFlightStatus(payload.airline, payload.flight, payload.timestamp)
              .buy(payload.airline, payload.flightID,payload.seatNo)
            .send({ from:passengerAddr, value:payload.Price}, (error, result) => {
                callback(error, payload);
            });
    }    
}