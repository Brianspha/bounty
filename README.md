# bounty

## Project setup
```
for local packages
npm install 
```
for gloabal packages
npm install embark -g
```

### Compiles and hot-reloads for development
```
npm run serve
```
embark run --nodashboard
```

### Compiles and minifies for production
```
npm run build
```
embark build production
### Run your tests
```
embark test 
to check for gas details run 
embark test ----gasDetails
to check for which functions where executed during testing run 
embark test --coverage
for some reason run embark test without providing a node key fails could be my machine as a work around in the instance the tests fail on your machine please provide a node key see below

```
Alternatively you could run
embark test --node (your node address) i.e your ganache instance for example
in full 
embark test --http://localhost:8545  for e.g.


### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).


Bounty DApp

An application that allows people to post Bounties for Bounty hunters to solve
As a job poster, I can create a new bounty. I will set a bounty description and include
the amount to be paid for a successful submission. I am able to view a list of bounties
that I have already posted. By clicking on a bounty, I can review submissions that have

been proposed. I can accept or reject the submitted work. Accepting proposed work will
pay the submitter the deposited amount.
As a bounty hunter, I can submit work to a bounty for review.


Payment with an  ERC720 token is not fully tested use at own risk
using public IFPS gateways is quite slow ive the projects uses a local ipfs node however to connect to a public gateway just run

embark run infura --nodashboard
instead of running the defualt
accessible via 
# https://brianspha.github.io/BontyDApp/
