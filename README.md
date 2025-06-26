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
- [x] Testing
- [x] Cross-chain message + token transfer
- [x] Testing
- [x] Swap token on DEXes
- [x] Testing
- [x] Testnet deployment (EVM Testnets)
    - [x] Deployment script
    - [x] Multiple Test Token creation (multi-chain script doesn't work due to foundry issue so need to use script on each network separately)
    - [x] Pool creation script (XYZ token + CCIP- BnM token)
    - [x] Set configuration script
    - [x] Cross-Chain Token Swap script
- [x] Basic swap widget and wallet interaction (FE)
- [x] Token lists addition (FE)
- [ ] Status checking page (FE)
- [ ] Solana program - cross-chain message and token transfer
- [ ] Testing on devnet
- [ ] Test Token creation & Pool creation on Raydium
- [ ] Cross Program invocation to swap from EVM to Solana
- [ ] Swap from Solana to EVM
- [x] Simulated output of swap with backend
- [x] Deploy Server


## Other Tasks
- [x] ~~Issue with Chainlink dependency installation (wrong paths in Chainlink repos)~~ currently this issue solved with just using starterkit which doesn't have this issue but while installing it myself I faced this issue, I am gonna come back to that
- [x] Script to fetch network details and newly deployed contracts
- [x] Deploying Tokens on Testnets (~~one testnet remaining~~)
- [x] Get ccipBnM on all those Testnet
- [x] Create ccipBnM + our token pools on Testnets