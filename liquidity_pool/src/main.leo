// The 'liquidity_pool' program.
import credits.leo;

program liquidity_pool.aleo {

    const FEE: u32 = 3u32;

    // balance of LP
    mapping balance: field => u64;
    // loan id to details
    mapping loan: field => u64;
    // always 0field as default
    mapping pool: field => Pool;

    struct Pool {
        current_loaned_token: u64, // loaned amount
        reserve_token: u64, // staked liquudity amount
    }

    struct Loan {
        amount: u64,
        duration: u128,
    }

    // ========================= pool interactions =========================

    transition add_liquidity(
        amount: u64,
        input: credits.leo/credits.record,
     ) -> (credits.leo/credits.record, credits.leo/credits.record) {
        assert_neq(amount, 0u64);
        let r: (credits, credits) = credits.leo/transfer_private(input, aleo1fjmx66zrmfxx288udrw93re4x9xvxkuszwuegmf78prt3shc2yrscf6shw, amount);
        let bid: field = BHP256::hash_to_field(self.caller);
        return (r.0, r.1) then finalize(bid, amount);
    }

    finalize add_liquidity(
        bid: field,
        amount: u64,
    ) {
        let p: Pool = Mapping::get_or_use(pool, 0field, Pool {
            current_loaned_token: 0u64,
            reserve_token: 0u64,
        });

        // update balances
        Mapping::set(balance, bid, Mapping::get_or_use(balance, bid, 0u64) + amount);

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
        let bid: field = BHP256::hash_to_field(self.caller);
        return then finalize(self.caller, bid, amount);
    }

    finalize remove_liquidity(
        caller: address,
        bid: field,
        amount: u64,
    ) {
        let p: Pool = Mapping::get(pool, 0field);

        // update balances
        Mapping::set(balance, bid, Mapping::get(balance, bid) - amount);

        // update pool
        Mapping::set(pool, 0field, Pool {
            current_loaned_token: p.current_loaned_token,
            reserve_token: p.reserve_token - amount,
        });

        // Mapping::set(pending_withdraw, 0field, Mapping::get_or_use(pending_withdraw, 0field, 0u8) + 1u8);
        // Mapping::set(withdraw, caller, Withdraw {
            
        // });
    }

    // // ========================= loan interactions =========================

    // transition get_loan(
    //     public token: field,
    //     public amount: u128,
    // ) {
    //     assert(amount > 0u128);
    //     return then finalize(self.caller, token, amount);
    // }

    // finalize get_loan(
    //     public caller: address,
    //     public token: field,
    //     public amount: u128,
    // ) {
    //     let pid: field = get_pool_id(token);
    //     let pool: Pool = Mapping::get(pools, pid);
    //     // check if this person is eligible to get loan, check ID
    //     // TODO

    //     // check if this person has payed back the loan
    //     let lid: field = get_loan_id(token, caller);
    //     let loan_amount: u128 = Mapping::get_or_use(loans, lid, 0u128);
    //     assert(loan_amount == 0u128);

    //     // check if the loan amount exceeds the maximum allowance
    //     assert(pool.reserve_token - pool.current_loaned_token >= amount);

    //     // update loans
    //     Mapping::set(loans, lid, loan_amount + amount);

    //     // update balances
    //     let bid: field = get_balance_id(token, caller);
    //     Mapping::set(balances, bid, Mapping::get_or_use(balances, bid, 0u128) + amount);

    //     // update pool
    //     Mapping::set(pools, pid, Pool {
    //         current_loaned_token: pool.current_loaned_token + amount,
    //         reserve_token: pool.reserve_token,
    //     });        
    // }

    // transition repay_loan(
    //     public token: field,
    //     public amount: u128,
    // ) {
    //     assert(amount > 0u128);
    //     return then finalize(self.caller, token, amount);
    // }

    // finalize repay_loan(
    //     public caller: address,
    //     public token: field,
    //     public amount: u128,
    // ) {
    //     let pid: field = get_pool_id(token);
    //     let pool: Pool = Mapping::get(pools, pid);

    //     // check if this person has owes any loan
    //     let lid: field = get_loan_id(token, caller);
    //     let loan_amount: u128 = Mapping::get_or_use(loans, lid, 0u128);
    //     assert(loan_amount > 0u128);

    //     // check if the loan repay amount exceeds the original liquidity
    //     assert(loan_amount >= amount);

    //     // update loans
    //     Mapping::set(loans, lid, loan_amount - amount);

    //     // update balances
    //     let bid: field = get_balance_id(token, caller);
    //     Mapping::set(balances, bid, Mapping::get_or_use(balances, bid, 0u128) - amount);

    //     // update pool
    //     Mapping::set(pools, pid, Pool {
    //         current_loaned_token: pool.current_loaned_token - amount,
    //         reserve_token: pool.reserve_token,
    //     });        
    // }

    
}
