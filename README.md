## GHOptim
### A GHO denominating options market protocol
### Design Features:
- No cost for LP providers 
- Non-opinionated market structure
- Yield enhancing for aTokens (Aave deposit tokens)
- Self-regulating GHO facilitator
- Fully immutable, dependent on Aave price and asset data

### ChatGPT Generated Description 
#### Input: `GHOptim.sol`

####  GHOptim: Efficient, GHO-Denominating Aave-dependent Options Protocol

Introduction:
GHOptim is an advanced and efficient options protocol designed for GHO denominations, operating within the Aave decentralized finance ecosystem. Developed by parseb (Bogdan A), 

GHOptim provides a versatile platform for executing options contracts with a focus on flexibility and ease of use.

#### Key Features and Advantages:

Denomination in GHO: GHOptim introduces a novel approach by denominating options in GHO, providing stability and predictability in transaction values.


Efficient Position Management: GHOptim enables users to initiate and manage positions efficiently. The protocol supports both buy and sell orders, allowing users to take advantage of market movements in a streamlined manner.

Automated Price Calculation: The protocol incorporates an automated price calculation mechanism, determining the cost to be paid by the option taker. This ensures fair and transparent pricing based on the current value of tradeable assets.

Liquidity Provider (LP) Interaction: GHOptim facilitates the interaction between option takers and liquidity providers. LPs can deposit collateral, and in the case of sell orders, GHO is minted as a substitute for selling, offering a unique feature for LPs.

Dynamic Expiry and Duration: The protocol allows users to set dynamic expiry dates for their positions. The duration of the options contract can be adjusted based on individual preferences, providing flexibility to adapt to changing market conditions.

How it Works:

Position Initiation: Users can initiate options positions by calling the takePosition function. This function handles the transfer of collateral from the LP, mints GHO for sell orders, and ensures proper validation of the execution price, duration, and other parameters.

Position Liquidation: Positions can be liquidated through the liquidatePosition function. Liquidation is either triggered by expiration or the owner, and the outcome determines whether the LP is recapitalized or the underlying asset is re-auctioned.

Surplus Redistribution: GHOptim incorporates a profit-taking mechanism through the profitTake function, which sweeps surplus Aave aToken balances and redistributes them to the Aave treasury and the genesis address.

Conclusion:
GHOptim stands as a robust and innovative options protocol within the Aave ecosystem, providing users with a seamless and efficient way to engage in options trading with a GHO denomination. The protocol's integration with Aave and its focus on user-friendly position management make it a valuable tool for both experienced and novice decentralized finance participants.


### Dev Notes

Partial success running dapp locally using forked tenderly testnet and applying state modifications and setup. No need to update ABIs and addresses. Let forked network sync to prevent need for unarchived state. <br>
`forge script script/GHODeployDeveNet.sol --rpc-url http://127.0.0.1:8545 -vvvv --broadcast`
<br>
where
<br>
`anvil --rpc-url $RPCmainDevTenderly` is testnet (beta)







## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
