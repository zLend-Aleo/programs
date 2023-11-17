// The 'zkid_auction_001' program.

import zkid_nft_001.leo;
import credits.leo;

program zkid_auction_001.aleo {

    // Loan ID to mark as paid
    mapping paid: u128 => bool;

    // A bid in an auction.
    // - `owner`     : The address of the account that owns the record associated with this bid.
    //                 This is separate from the address of the account that placed the bid.
    // - `bidder`    : The address of the account that placed the bid.
    // - `amount`    : The amount of the bid.
    // - `is_winner` : Whether the bid is the winning bid.
    // - `loan_id`   : The loan of bidding.
    record Bid {
        owner: address,
        bidder: address,
        amount: u64,
        loan_id: u128,
        is_winner: bool,
        is_paid: bool,
    }

    // Returns a new bid.
    // - `bidder` : The address of the account that placed the bid.
    // - `amount` : The amount of the bid.
    // Requires that `bidder` matches the function caller.
    // The owner of the record is set to the entity responsible for running the auction (auction runner).
    // The address of the auction runner is aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh.
    transition place_bid(amount: u64, loan_id: u128) -> Bid {
        return Bid {
            owner: aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw,
            bidder: self.caller,
            amount: amount,
            loan_id: loan_id,
            is_winner: false,
            is_paid: false,
        };
    }

    // Returns the winning bid.
    // - `first`  : The first bid.
    // - `second` : The second bid.
    // Requires that the function caller is the auction runner.
    // Assumes that the function is invoked only after the bidding period has ended.
    // In the event of a tie, the first bid is selected.
    transition resolve(first: Bid, second: Bid) -> Bid {
        // Ensure the caller is the auctioneer.
        assert_eq(self.caller, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        // Resolve the winner of the auction.
        if (first.amount >= second.amount) {
            return first;
        } else {
            return second;
        }
    }

    // Returns ownership of the bid to bidder.
    // - `bid` : The winning bid.
    // Requires that the function caller is the auction runner.
    // Assumes that the function is invoked only after all bids have been resolved.
    transition finish(bid: Bid) -> Bid {
        // Ensure the caller is the auctioneer.
        assert_eq(self.caller, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        // Return 'is_winner' as 'true' in the winning 'Bid'.
        return Bid {
            owner: bid.bidder,
            bidder: bid.bidder,
            amount: bid.amount,
            loan_id: bid.loan_id,
            is_winner: true,
            is_paid: false
        };
    }

    transition pay_bid(bid: Bid, input: credits.leo/credits.record) -> Bid {
        credits.leo/transfer_private(input, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw, bid.amount);
        return Bid {
            owner: bid.bidder,
            bidder: bid.bidder,
            amount: bid.amount,
            loan_id: bid.loan_id,
            is_winner: true,
            is_paid: true,
        };
    }

    transition send_zkid(nft: zkid_nft_001.leo/NFT.record, bid: Bid) -> zkid_nft_001.leo/NFT.record {
        assert_eq(bid.is_paid, true);
        return zkid_nft_001.leo/zkid_transfer_private(nft, bid.bidder);
    }
}
