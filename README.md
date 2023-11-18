# Test
Spin up local development node, run script.sh

# Programs flow / steps
## zkID NFT Program
### Admin
1. Initialize collection (public symbol: u128)
2. issue_zkid (private requester: address, private personal_info: URI) (URI can be change to direct info storing)

### User
1. prove_ownership (private nft: NFT, private prove_to: address)
2. zkid_transfer_private (nft: NFT, private receiver: address)

## zkID LP/Loan Program
### Liquidity provider
1. Add liquidity
2. Remove liquidity
3. (Earn interest)
4. Withdraw to LP (Admin function)

### Borrower
1. Get loan
2. Send loan amount (Admin function)
3. Repay loan
4. Return Id (Admin function)

### Anyone
1. Liquidate to enable auction if duration > block.height

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

# Biggest challenges
1. Programs could not own private states (cannot automate the process of transferring records like Aleo credits, zkID).
2. Caller must be owner (cannot transfer credits on behalf of others).
3. Record within struct does not work while importing.
4. Array assignment not available.
