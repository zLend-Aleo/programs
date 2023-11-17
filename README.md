# Programs flow / steps
## zkID NFT Program
### Admin
1. Initialize collection (public symbol: u128)
2. issue_zkid (private requester: address, private personal_info: BaseURI)

### User
1. prove_ownership (private nft: NFT, private prove_to: address)
2. zkid_transfer_private (nft: NFT, private receiver: address)

## zkID Debt Auction
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