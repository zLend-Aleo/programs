// The 'liquidity_pool' program.
program liquidity_pool.aleo {

    mapping balances: field => u128;
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
        reserve_token: u128,
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
        public to: address
     ) {
        assert(amount > 0u128);
        return then finalize(self.caller, token, amount, to);
    }

    finalize create_pool(
        public caller: address,
        public token: field,
        public amount: u128,
        public to: address
    ) {
        let pid: field = get_pool_id(token);
        let liquidity: u128 = amount;
        assert(liquidity > 0u128);

        let tokenInfo: TokenInfo = Mapping::get_or_use(tokens, pid, TokenInfo {
            name: 5183377571718029925300968712562field,
            symbol: 4281168field,
            decimals: 6u8,
            total_supply: 0u128,
            admin: aleo1qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq3ljyzc,
        });
        assert_eq(tokenInfo.total_supply, 0u128);

        let pool: Pool = Mapping::get_or_use(pools, pid, Pool {
            reserve_token: 0u128,
        });

        // mint liquidity pbid == Pool Balance Id
        let pbid: field = get_balance_id(pid, to);
        Mapping::set(balances, pbid, Mapping::get_or_use(balances, pbid, 0u128) + liquidity);

        // update Pool
        Mapping::set(pools, pid, Pool {
            reserve_token: pool.reserve_token + amount,
        });
    }

    transition add_liquidity(
        public token: field,
        public amount: u128,
        public min: u128,
        public to: address
     ) {
        assert(amount > 0u128 && amount >= min);
        return then finalize(self.caller, token, amount, min, to);
    }

    finalize add_liquidity(
        public caller: address,
        public token: field,
        public amount: u128,
        public min: u128,
        public to: address
    ) {
        let pid: field = get_pool_id(token);
        let pool: Pool = Mapping::get(pools, pid);
        let tokenInfo: TokenInfo = Mapping::get(tokens, pid);

        // update balances
        let bid: field = get_balance_id(token, caller);
        Mapping::set(balances, bid, Mapping::get(balances, bid) - amount_a);

        // mint liquidity
        let bid_p: field = get_balance_id(pid, to);
        Mapping::set(balances, bid_p, Mapping::get_or_use(balances, bid_p, 0u128) + liquidity);
        Mapping::set(tokens, pid, TokenInfo {
            name: tokenInfo.name,
            symbol: tokenInfo.symbol,
            decimals: tokenInfo.decimals,
            total_supply: tokenInfo.total_supply + liquidity,
            admin: tokenInfo.admin,
        });

        // update pool
        Mapping::set(pools, pid, Pool {
            reserve_token: pool.reserve_token + amount,
        });
    }

    transition remove_liquidity(
        public token: field,
        public amount: u128,
        public min: u128,
        public to: address,
     ) {
        assert(amount > 0u128);
        return then finalize(self.caller, token, amount, min, to);
    }

    finalize remove_liquidity(
        public caller: address,
        public token: field,
        public amount: u128,
        public min: u128,
        public to: address,
    ) {
        let pid: field = get_pool_id(token);
        let tokenInfo: TokenInfo = Mapping::get(tokens, pid);
        let pool: Pool = Mapping::get(pools, pid);

        // calculate token amounts
        assert(amount >= min);

        // burn liquidity
        let bid_p: field = get_balance_id(pid, caller);
        Mapping::set(balances, bid_p, Mapping::get(balances, bid_p) - amount);
        Mapping::set(tokens, pid, TokenInfo {
            name: tokenInfo.name,
            symbol: tokenInfo.symbol,
            decimals: tokenInfo.decimals,
            total_supply: tokenInfo.total_supply - amount,
            admin: tokenInfo.admin,
        });

        // update pool
        Mapping::set(pools, pid, Pool {
            reserve_token: pool.reserve_token - amount,
        });

        // send tokens
        let bid: field = get_balance_id(token, to);
        Mapping::set(balances, bid, Mapping::get_or_use(balances, bid, 0u128) + amount);
    }

}
