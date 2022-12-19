# Miner Dealer
![alt text](https://xrlab.studio/dev/MinerDealer/logo.jpg)

Miner Dealer encourages storage providers to have the liquidity to operate within the Filecoin network and allows for obligation fulfillment, creating a good reputation and room for expansion. Solving inclusiveness with miners with insufficient liquidity to operate the protocol.

## Problem
Inclusiveness with miners who do not have sufficient liquidity to operate the protocol. Benefiting from holding the tokens in the system by generating yield.

## Solution
Load protocol design, using storage actors within FVM to consult the reputation of miners, manipulating their rewards address allowing lenders to take profits.

## User Flow
![alt text](https://xrlab.studio/dev/MinerDealer/Flow.jpg)

[Hack FEVM Project](https://ethglobal.com/showcase/minerdealer-wmkqj)


## Cloning the Repo

Open up your terminal (or command prompt) and navigate to a directory you would like to store this code on. Once there type in the following command:


```
git clone https://github.com/filecoin-project/FEVM-Hardhat-Kit.git
cd FEVM-hardhat-kit
yarn install
```


This will clone the hardhat kit onto your computer, switch directories into the newly installed kit, and install the dependencies the kit needs to work.


## Get a Private Key

You can get a private key from a wallet provider [such as Metamask](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key).


## Add your Private Key as an Environment Variable

Add your private key as an environment variable by running this command: 
 
 ```
export PRIVATE_KEY='abcdef'
```

 \
If you use a .env file, don't commit and push any changes to .env files that may contain sensitive information, such as a private key! If this information reaches a public GitHub repository, someone can use it to check if you have any Mainnet funds in that wallet address, and steal them!


## Get the Deployer Address

Run this command:
```
yarn hardhat get-address
```

The f4address is the filecoin representation of your Ethereum address. This will be needed for the faucet in the next step.

The Ethereum address will be used otherwise.


## Fund the Deployer Address

Go to the [Wallaby faucet](https://wallaby.network/#faucet), and paste in the f4 address we copied in the previous step. This will send some wallaby testnet FIL to the account.


## Deploy the SimpleCoin Contract

Type in the following command in the terminal: 
 
 ```
yarn hardhat deploy
```

This will compile the contract and deploy it to the Wallaby network automatically!

Keep note of the deployed contract address for the next step.

If you read the Solidity code for SimpleCoin, you will see in the constructor our deployer account automatically gets assigned 10000 SimpleCoin when the contract is deployed.


## Read your SimpleCoin balance

Type in the following command in the terminal: 
 
 ```
yarn hardhat get-balance --contract 'THE DEPLOYED CONTRACT ADDRESS HERE' --account 'YOUR F4 ADDRESS HERE'
```

The console should read that your account has 10000 SimpleCoin!
