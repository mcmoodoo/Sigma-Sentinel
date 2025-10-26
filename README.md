# Pyth Price Feeds Sentinel

A Solidity contract that integrates with Pyth Network price feeds to calculate historical volatility for ETH/USD.

## Architecture

- **Sentinel.sol**: Main contract that fetches price data from Pyth and computes volatility using log returns
- **Python scripts**: Fetch price updates from Pyth API
- **Foundry scripts**: Deploy contract and update price feeds

## Dependencies

- Foundry
- Python 3 with `requests` and `web3`
- Pyth SDK for Solidity
- ABDKMath64x64 for logarithmic calculations

## Setup

1. Install dependencies:
```bash
npm install
forge install abdk-consulting/abdk-libraries-solidity
```

2. Set environment variables:
```bash
export INFURA_UNICHAIN_MAINNET_RPC="your_rpc_url"
```

## Usage

1. Deploy contract:
```bash
just deploy
```

2. Fetch and update current price:
```bash
just refresh-price
```

3. Fetch historical data and calculate volatility:
```bash
just historical
```

4. Query contract:
```bash
just get-price <contract_address>
just get-volatility <contract_address>
just get-annualized-volatility <contract_address>
```

## Contract Functions

- `refreshPriceFeed()`: Update Pyth price feeds
- `historicalPrice()`: Store historical prices for volatility calculation
- `historicalVolatility()`: Calculate per-second volatility
- `getAnnualizedVolatility()`: Calculate annualized volatility

## Volatility Calculation

Uses log returns with fixed-point arithmetic (1e18 precision):
1. Compute log(price_t / price_{t-1}) for consecutive prices
2. Calculate sample variance of log returns
3. Return square root as volatility per second