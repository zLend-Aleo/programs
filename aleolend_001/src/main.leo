// The 'aleolend_001' program.
import credits.leo;
import zkid_nft_001.leo;

program aleolend_001.aleo {

    const FEE: u64 = 3u64;
    const SCALE: u64 = 100u64;

    // balance of LP
    mapping balance: address => u64;
    // always 0field as default
    // incremental loan id
    mapping loan_id_inc: field => u128;
    // loan id to details
    mapping loan: u128 => Loan;
    // always 0field as default
    mapping pool: field => Pool;
    // always 0field as default
    // withdrawal request
    mapping withdraw: address => u64;
    // always 0field as default
    // total interest accumulated
    mapping acc_interest: field => u64;

    struct Pool {
        current_loaned_token: u64, // loaned amount
        reserve_token: u64, // staked liquudity amount
    }

    struct Loan {
        borrower: address,
        amount: u64,
        duration: u32,
        sent: bool,
        repaid: bool,
        on_auction: bool,
    }

    // ========================= pool interactions =========================

    transition add_liquidity(
        amount: u64,
        input: credits.leo/credits.record,
     ) -> (credits.leo/credits.record, credits.leo/credits.record) {
        assert_neq(amount, 0u64);
        let r: (credits, credits) = credits.leo/transfer_private(input, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw, amount);
        return (r.0, r.1) then finalize(self.caller, amount);
    }

    finalize add_liquidity(
        caller: address,
        amount: u64,
    ) {
        let p: Pool = pool.get_or_use(0field, Pool {
            current_loaned_token: 0u64,
            reserve_token: 0u64,
        });

        // update balances
        balance.set(caller, balance.get_or_use(caller, 0u64) + amount);

        // update pool
        pool.set(0field, Pool {
            current_loaned_token: p.current_loaned_token,
            reserve_token: p.reserve_token + amount,
        });
    }

    transition remove_liquidity(
        amount: u64,
    ) {
        assert_neq(amount, 0u64);
        return then finalize(self.caller, amount);
    }

    finalize remove_liquidity(
        caller: address,
        amount: u64,
    ) {
        let p: Pool = pool.get(0field);

        // update balances
        balance.set(caller, balance.get(caller) - amount); // fails if underflow

        // update pool
        pool.set(0field, Pool {
            current_loaned_token: p.current_loaned_token,
            reserve_token: p.reserve_token - amount,
        });

        withdraw.set(caller, amount);
    }

    // admin only function
    transition withdrawal(
        to: address,
        amount: u64,
        input: credits.leo/credits.record,
    ) -> (credits.leo/credits.record, credits.leo/credits.record) {
        assert_eq(self.caller, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        let r: (credits, credits) = credits.leo/transfer_private(input, to, amount);
        return (r.0, r.1) then finalize(to, amount);
    }

    finalize withdrawal(to: address, amount: u64) {
        let w: u64 = withdraw.get(to);
        assert_eq(w, amount);

        withdraw.set(to, w - amount);
    }

    // ========================= loan interactions =========================

    transition get_loan(
        amount: u64,
        duration: u32,
        zkid: zkid_nft_001.leo/NFT.record,
    ) -> zkid_nft_001.leo/NFT.record {
        assert_neq(amount, 0u64);
        let zid: NFT = zkid_nft_001.leo/zkid_transfer_private(zkid, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        return zid then finalize(self.caller, amount, duration);
    }

    finalize get_loan(
        caller: address,
        amount: u64,
        duration: u32
    ) {
        let lid: u128 = loan_id_inc.get_or_use(0field, 0u128);
        let p: Pool = pool.get(0field);
        assert(p.reserve_token - p.current_loaned_token >= amount);

        loan.set(lid, Loan {
            borrower: caller,
            amount: amount,
            duration: duration,
            sent: false,
            repaid: false,
            on_auction: false,
        });

        // update pool
        pool.set(0field, Pool {
            current_loaned_token: p.current_loaned_token + amount,
            reserve_token: p.reserve_token,
        });
        loan_id_inc.set(0field, lid + 1u128);
    }

    // Return ID for expired loan applications
    transition return_id_without_loan(
        loan_id: u128,
        zkid: zkid_nft_001.leo/NFT.record
    ) -> zkid_nft_001.leo/NFT.record {
        let zid: NFT = zkid_nft_001.leo/zkid_transfer_private(zkid, zkid.id_owner);
        return zid then finalize(loan_id);
    }

    finalize return_id_without_loan(loan_id: u128) {
        let l: Loan = loan.get(loan_id);
        assert(l.duration > block.height);
    }

    transition send_loan(
        loan_id: u128,
        amount: u64,
        input: credits.leo/credits.record,
        zkid: zkid_nft_001.leo/NFT.record,
    ) -> (
        zkid_nft_001.leo/NFT.record,
        credits.leo/credits.record,
        credits.leo/credits.record,
    ) {
        let interest: u64 = amount * FEE / SCALE;
        if (interest == 0u64) {interest = 1u64;} // set min interest if amount too minimum
        let r: (credits, credits) = credits.leo/transfer_private(input, zkid.owner, amount - interest);
        return (zkid, r.0, r.1) then finalize(loan_id, zkid.owner, amount, interest);
    }

    finalize send_loan(
        loan_id: u128,
        borrower: address,
        amount: u64,
        interest: u64,
    ) {
        assert_neq(amount, 0u64);
        let l: Loan = loan.get(loan_id);
        assert_neq(l.sent, true);
        assert_eq(l.amount, amount);

        loan.set(loan_id, Loan {
            borrower: l.borrower,
            amount: l.amount,
            duration: l.duration,
            sent: true,
            repaid: l.repaid,
            on_auction: l.on_auction,
        });

        // storing accumulated interests
        acc_interest.set(0field, acc_interest.get_or_use(0field, 0u64) + interest);
    }

    transition repay_loan(
        loan_id: u128,
        amount: u64,
        input: credits.leo/credits.record,
    ) -> (credits.leo/credits.record, credits.leo/credits.record) {
        let r: (credits, credits) = credits.leo/transfer_private(input, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw, amount);
        return (r.0, r.1) then finalize(loan_id, self.caller, amount);
    }

    finalize repay_loan(loan_id: u128, caller: address, amount: u64) {
        let l: Loan = loan.get(loan_id);
        assert_neq(l.repaid, true);
        assert_eq(l.amount, amount);
        
        loan.set(loan_id, Loan {
            borrower: l.borrower,
            amount: l.amount,
            duration: l.duration,
            sent: l.sent,
            repaid: true,
            on_auction: l.on_auction,
        });
    }

    transition return_id(
        loan_id: u128,
        to: address,
        zkid: zkid_nft_001.leo/NFT.record,
    ) -> zkid_nft_001.leo/NFT.record {
        let zid: NFT = zkid_nft_001.leo/zkid_transfer_private(zkid, zkid.id_owner);
        return zid then finalize(loan_id, to, zkid.id_owner);
    }

    finalize return_id(
        loan_id: u128,
        to: address,
        id_owner: address,
    ) {
        assert_eq(to, id_owner);
        let l: Loan = loan.get(loan_id);
        assert_eq(l.repaid, true);
    }

    transition liquidate(loan_id: u128) {
        return then finalize(loan_id);
    }

    finalize liquidate(loan_id: u128) {
        let l: Loan = loan.get(loan_id);
        assert_eq(l.on_auction, false);
        assert(l.duration > block.height);

        loan.set(loan_id, Loan {
            borrower: l.borrower,
            amount: l.amount,
            duration: l.duration,
            sent: l.sent,
            repaid: l.repaid,
            on_auction: true,
        });
    }
}
