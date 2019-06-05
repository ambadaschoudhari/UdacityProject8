# FlightSurety

FlightSurety is a sample application project for Udacity's Blockchain course.

## Install

This repository contains Smart Contract code in Solidity (using Truffle), tests (also using Truffle), dApp scaffolding (using HTML, CSS and JS) and server app scaffolding.

To install, download or clone the repo, then:

`npm install`
`truffle compile`

## Develop Client

To run truffle tests:

`truffle test ./test/flightSurety.js`
`truffle test ./test/oracles.js`

To use the dapp:

`truffle migrate`
`npm run dapp`

To view dapp:

`http://localhost:8080`

## Develop Server

`npm run server`
`truffle test ./test/oracles.js`

## Deploy

To build dapp for prod:
`npm run dapp:prod`

Deploy the contents of the ./dapp folder

Test Results:
1. Separation of Concerns
   a. Implemented data and app contract; 
   b. Business logic is mostly in app contract
   c. Storage and information is mostly in data contract [Data Persistenace]
   d. Security is handled by allowing only app contrat connect to datacontract - registration at deployment
2. Airlines
   a. Registration at time of testing [Deployment does take care of authorized user]
   b. Only existing airlines are allowed to register new airlines
   c. Consensus implemented
3. Passengers
   a. Passensgers can buy insurance, Implemented and tested 
   b. Repayment can tested for one of the insured tickets
4. Oracles
   a. Implemnted functions and tested functionality from query submitted for dapp
   b. Testing completed from oracles.js
5. General
   a. IsOperational Implemented
   b. Requirement statements are implemented
   c. New test cases, data structures and code added.


## Resources

* [How does Ethereum work anyway?](https://medium.com/@preethikasireddy/how-does-ethereum-work-anyway-22d1df506369)
* [BIP39 Mnemonic Generator](https://iancoleman.io/bip39/)
* [Truffle Framework](http://truffleframework.com/)
* [Ganache Local Blockchain](http://truffleframework.com/ganache/)
* [Remix Solidity IDE](https://remix.ethereum.org/)
* [Solidity Language Reference](http://solidity.readthedocs.io/en/v0.4.24/)
* [Ethereum Blockchain Explorer](https://etherscan.io/)
* [Web3Js Reference](https://github.com/ethereum/wiki/wiki/JavaScript-API)