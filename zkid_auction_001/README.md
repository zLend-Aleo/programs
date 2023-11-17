# zkid_auction_001.aleo

## Steps
### Admin
1. Start auction with loan id
2. (Wait for bidding)
3. Resolve bids
4. Finish with winning bid
5. (Wait for payment)
6. Transfer zkID to winning Debt Collector

### Debt Collector
1. Place bid with loan id
2. (Wait for result)
3. Pay for the winning bid
4. Receive zkID for further action


## Questions
1. Importing record contains struct doesn't work. (SnarkVM Error: Invalid record entry 'NFT.data': Struct 'BaseURI' is not defined in the program)
2. Calling imported function credits.leo/transfer_public causes this unknown error (SnarkVM Error: Expected 1 outputs, found 0)