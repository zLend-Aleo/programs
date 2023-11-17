// The 'liquidity_pool' program.
import credits.leo;
import zkid_nft_001.leo;

program liquidity_pool.aleo {

    const FEE: u32 = 3u32;

    // balance of LP
    mapping balance: address => u64;
    // always 0field as default
    // incremental loan id
    mapping loan_id: field => u128;
    // loan id to details
    mapping loan: LoanID => Loan;
    // always 0field as default
    mapping pool: field => Pool;
    // always 0field as default
    // withdrawal request
    mapping withdraw: address => u64;

    struct Pool {
        current_loaned_token: u64, // loaned amount
        reserve_token: u64, // staked liquudity amount
    }

    struct LoanID {
        borrower: address,
        id: u128,
    }

    struct Loan {
        amount: u64,
        duration: u32,
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
        let p: Pool = Mapping::get_or_use(pool, 0field, Pool {
            current_loaned_token: 0u64,
            reserve_token: 0u64,
        });

        // update balances
        Mapping::set(balance, caller, Mapping::get_or_use(balance, caller, 0u64) + amount);

        // update pool
        Mapping::set(pool, 0field, Pool {
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
        let p: Pool = Mapping::get(pool, 0field);

        // update balances
        Mapping::set(balance, caller, Mapping::get(balance, caller) - amount); // fails if underflow

        // update pool
        Mapping::set(pool, 0field, Pool {
            current_loaned_token: p.current_loaned_token,
            reserve_token: p.reserve_token - amount,
        });

        Mapping::set(withdraw, caller, amount);
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
        let w: u64 = Mapping::get(withdraw, to);
        assert_eq(w, amount);

        Mapping::set(withdraw, to, w - amount);
    }

    // ========================= loan interactions =========================

    transition get_loan(
        amount: u64,
        duration: u32,
        zkid: zkid_nft_001.leo/NFT.record,
    ) -> zkid_nft_001.leo/NFT.record {
        assert_neq(amount, 0u64);
        zkid_nft_001.leo/zkid_transfer_private(zkid, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw);
        return then finalize(self.caller, amount, duration);
    }

    finalize get_loan(
        caller: address,
        amount: u64,
        duration: u32
    ) {
        let lid: u128 = loan_id.get_or_use(0field, 0u128);
        let p: Pool = pool.get(0field);
        assert(p.reserve_token - p.current_loaned_token >= amount);

        let l: LoanID = LoanID {
            borrower: caller,
            id: lid,
        };

        loan.set(l, Loan {
            amount: amount,
            duration: duration,
        });

        // update pool
        pool.set(0field, Pool {
            current_loaned_token: p.current_loaned_token + amount,
            reserve_token: p.reserve_token,
        });
        loan_id.set(0field, lid + 1u128);
    }
    
    
}
