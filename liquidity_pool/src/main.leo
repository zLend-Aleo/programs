// The 'liquidity_pool' program.
program liquidity_pool.aleo {

    const FEE: u32 = 3u32;

    mapping balances: field => u128;
    mapping loans: field => u128;
    mapping tokens: field => TokenInfo;
    mapping pools: field => Pool;

    struct TokenInfo {
        name: field,
        symbol: field,
        decimals: u8,
        total_supply: u128,
        admin: address,
    }

    struct Pool {
        current_loaned_token: u128, // loaned amount
        reserve_token: u128, // staked liquudity amount
    }

    struct BalanceKeyData {
        token: field,
        user: address,
    }

    inline get_balance_id(token_: field, user_: address) -> field {
        // copy to avoid compiling error
        let token: field = token_;
        let user: address = user_;
        return BHP256::hash_to_field(BalanceKeyData {token, user});
    }

    inline get_loan_id(token_: field, user_: address) -> field {
        let token: field = token_;
        let user: address = user_;
        return BHP256::hash_to_field(BalanceKeyData {token, user});
    }

    // Build the id of a liquidity pool
    inline get_pool_id(token_: field) -> field {
        // copy to avoid compiling error
        let token: field = token_;
        return  BHP256::hash_to_field(token);
    }

    // ========================= pool interactions =========================

    transition create_pool(
        public token: field,
        public amount: u128,
     ) {
        assert(amount > 0u128);
        return then finalize(self.caller, token, amount);
    }

    finalize create_pool(
        public caller: address,
        public token: field,
        public amount: u128,
    ) {
        let pid: field = get_pool_id(token);
        let liquidity: u128 = amount;
        assert(liquidity > 0u128);

        let pool: Pool = Mapping::get_or_use(pools, pid, Pool {
            current_loaned_token: 0u128,
            reserve_token: 0u128,
        });

        // mint liquidity pbid == Pool Balance Id
        let pbid: field = get_balance_id(pid, caller);
        Mapping::set(balances, pbid, Mapping::get_or_use(balances, pbid, 0u128) + liquidity);

        // update Pool
        Mapping::set(pools, pid, Pool {
            current_loaned_token: pool.current_loaned_token + amount,
            reserve_token: pool.reserve_token + amount,
        });
    }

    transition add_liquidity(
        public token: field,
        public amount: u128,
        public min: u128,
     ) {
        assert(amount > 0u128 && amount >= min);
        return then finalize(self.caller, token, amount, min);
    }

    finalize add_liquidity(
        public caller: address,
        public token: field,
        public amount: u128,
        public min: u128,
    ) {
        let pid: field = get_pool_id(token);
        let pool: Pool = Mapping::get(pools, pid);

        // update balances
        let bid: field = get_balance_id(token, caller);
        Mapping::set(balances, bid, Mapping::get(balances, bid) - amount);

        // mint liquidity
        let bid_p: field = get_balance_id(pid, caller);
        Mapping::set(balances, bid_p, Mapping::get_or_use(balances, bid_p, 0u128) + liquidity);

        // update pool
        Mapping::set(pools, pid, Pool {
            current_loaned_token: pool.current_loaned_token + amount,
            reserve_token: pool.reserve_token + amount,
        });
    }

    transition remove_liquidity(
        public token: field,
        public amount: u128,
        public min: u128,
     ) {
        assert(amount > 0u128);
        return then finalize(self.caller, token, amount, min);
    }

    finalize remove_liquidity(
        public caller: address,
        public token: field,
        public amount: u128,
        public min: u128,
    ) {
        let pid: field = get_pool_id(token);
        let pool: Pool = Mapping::get(pools, pid);

        // calculate token amounts
        assert(amount >= min);
        
        // check if the loan is still under the allowance after withdraw

        // burn liquidity
        let bid_p: field = get_balance_id(pid, caller);
        Mapping::set(balances, bid_p, Mapping::get(balances, bid_p) - amount);

        // update pool
        Mapping::set(pools, pid, Pool {
            current_loaned_token: pool.current_loaned_token - amount,
            reserve_token: pool.reserve_token - amount,
        });

        // send tokens
        let bid: field = get_balance_id(token, caller);
        Mapping::set(balances, bid, Mapping::get_or_use(balances, bid, 0u128) + amount);
    }

    // ========================= loan interactions =========================

    transition get_loan(
        public token: field,
        public amount: u128,
    ) {
        assert(amount > 0u128);
        return then finalize(self.caller, token, amount);
    }

    finalize get_loan(
        public caller: address,
        public token: field,
        public amount: u128,
    ) {
        let pid: field = get_pool_id(token);
        let pool: Pool = Mapping::get(pools, pid);
        // check if this person is eligible to get loan, check ID
        // TODO

        // check if this person has payed back the loan
        let lid: field = get_loan_id(token, caller);
        let loan_amount: u128 = Mapping::get_or_use(loans, lid, 0u128);
        assert(loan_amount == 0u128);

        // check if the loan amount exceeds the maximum allowance
        assert(pool.reserve_token - pool.current_loaned_token >= amount);

        // update loans
        Mapping::set(loans, lid, loan_amount + amount);

        // update balances
        let bid: field = get_balance_id(token, caller);
        Mapping::set(balances, bid, Mapping::get_or_use(balances, bid, 0u128) + amount);

        // update pool
        Mapping::set(pools, pid, Pool {
            current_loaned_token: pool.current_loaned_token + amount,
            reserve_token: pool.reserve_token,
        });        
    }

    transition repay_loan(
        public token: field,
        public amount: u128,
    ) {
        assert(amount > 0u128);
        return then finalize(self.caller, token, amount);
    }

    finalize repay_loan(
        public caller: address,
        public token: field,
        public amount: u128,
    ) {
        let pid: field = get_pool_id(token);
        let pool: Pool = Mapping::get(pools, pid);

        // check if this person has owes any loan
        let lid: field = get_loan_id(token, caller);
        let loan_amount: u128 = Mapping::get_or_use(loans, lid, 0u128);
        assert(loan_amount > 0u128);

        // check if the loan repay amount exceeds the original liquidity
        assert(loan_amount >= amount);

        // update loans
        Mapping::set(loans, lid, loan_amount - amount);

        // update balances
        let bid: field = get_balance_id(token, caller);
        Mapping::set(balances, bid, Mapping::get_or_use(balances, bid, 0u128) - amount);

        // update pool
        Mapping::set(pools, pid, Pool {
            current_loaned_token: pool.current_loaned_token - amount,
            reserve_token: pool.reserve_token,
        });        
    }

    
}
