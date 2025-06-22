## Cross-Chain DEX

Idea: Create cross-chain DEX with Chainlink CCIP for sending message cross-chain and existing DEXes as liquidity.

## Advantages

- Project doesn't need to bootstrap liquidity as DEXes already have that
- With CCIP tokens can be transferred so we can find common token between both chains and use those as bridge. 

Here is how swap from Bonk on Solana can be swapped to ETH on Arbitrum.
```text
BONK -> USDC (Solana)
USDC -> ETH (Arbitrum)
```
- Better trust assumptions
- More decentralized compared to cross-chain dexes that use Market Maker and off-chain order flow

## Tasks

- [x] Cross-chain message tansfer
- [x] Local Testing
- [ ] Cross-chain message + token transfer
- [ ] Fork testing
- [ ] Swap token on DEXes
- [ ] Forking testing part 2
- [ ] Testnet deployment (EVM Testnets)
    - [x] Deployment script
    - [ ] Multiple Test Token creation
    - [ ] Pool creation script (XYZ token + CCIP- BnM token)
- [ ] Basic swap widget and wallet interaction (FE)
- [ ] Token lists addition (FE)
- [ ] Status checking page (FE)
- [ ] Solana program - cross-chain message and token transfer
- [ ] Testing on devnet
- [ ] Test Token creation & Pool creation on Raydium
- [ ] Cross Program invocation to swap from EVM to Solana
- [ ] Swap from Solana to EVM


## Other Tasks
- [ ] Issue with Chainlink dependency installation (wrong paths in Chainlink repos)
- [x] Script to fetch network details and newly deployed contracts