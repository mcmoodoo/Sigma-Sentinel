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

## On-Chain Transactions (Unichain Chain ID 130)

### 1. Price Update Transactions (update.s.sol)
- **Transaction Hash**: `0x4f8e61f22c95b1f877948d51eae165891f76cc4495cf452e9b3253af9325e35b`
- **Function**: `refreshPriceFeed(bytes[])`
- **Contract**: `0xb61652cc6e2c8d49b7d7fa5ac2f98c1f16a19023` (Sentinel contract)
- **From**: `0x1da4207f6f6da04c9fe66bb72b1fa89616220a72`
- **Gas Used**: 210,585 (0x338d9)
- **Gas Price**: 4,070 (0xfe6) wei
- **Value**: 1 wei
- **Block**: 0x1d509e7 (30,750,183)
- **Status**: Success (0x1)

- **Transaction Hash**: `0x787d9c579fca54c0bc6318a701cc31437345af03df65b0b912a13b2da3830b98`
- **Function**: `refreshPrice()`
- **Contract**: `0xb61652cc6e2c8d49b7d7fa5ac2f98c1f16a19023`
- **From**: `0x1da4207f6f6da04c9fe66bb72b1fa89616220a72`
- **Gas Used**: 80,866 (0x13be2)
- **Gas Price**: 4,070 (0xfe6) wei
- **Value**: 0 wei
- **Block**: 0x1d509e7 (30,750,183)
- **Status**: Success (0x1)

### 2. Historical Price Fetch Transactions (fetchHistoricalPrices.s.sol)
- **Transaction Hash**: `0x0464c3f9e02d68e59f89c91b57ed56525072850bd74fc0e5b14361c7f4fb872c`
- **Function**: `historicalPrice(bytes[],uint64,uint64)`
- **Contract**: `0xb61652cc6e2c8d49b7d7fa5ac2f98c1f16a19023`
- **From**: `0x1da4207f6f6da04c9fe66bb72b1fa89616220a72`
- **Gas Used**: 312,632 (0x4c538)
- **Gas Price**: 4,008 (0xfa8) wei
- **Value**: 1 wei
- **Block**: 0x1d50cf6 (30,751,222)
- **Status**: Success (0x1)

- **Transaction Hash**: `0xd3139c0cb95184ef67267c3b3a740284a6175e29d2a718c3d7f98579c27b210a`
- **Function**: `historicalPrice(bytes[],uint64,uint64)`
- **Contract**: `0xb61652cc6e2c8d49b7d7fa5ac2f98c1f16a19023`
- **From**: `0x1da4207f6f6da04c9fe66bb72b1fa89616220a72`
- **Gas Used**: 261,407 (0x3fd1f)
- **Gas Price**: 4,008 (0xfa8) wei
- **Value**: 1 wei
- **Block**: 0x1d50cf6 (30,751,222)
- **Status**: Success (0x1)

- **Transaction Hash**: `0xafe124b994f26db5d038e1249048eaf7c637ad9aa491dba9f2175a682ed7bddb`
- **Function**: `historicalPrice(bytes[],uint64,uint64)`
- **Contract**: `0xb61652cc6e2c8d49b7d7fa5ac2f98c1f16a19023`
- **From**: `0x1da4207f6f6da04c9fe66bb72b1fa89616220a72`
- **Gas Used**: 261,420 (0x3fcec)
- **Gas Price**: 4,008 (0xfa8) wei
- **Value**: 1 wei
- **Block**: 0x1d50cf6 (30,751,222)
- **Status**: Success (0x1)

### Contract Deployment
- **Transaction Hash**: `0xcb6bfd8f8f69a497cce52c4e21e1d553ed7563aa9cdc80b00995e5b136ddd3c2`
- **Type**: Contract Creation
- **Contract Name**: Sentinel
- **Contract Address**: `0xb61652cc6e2c8d49b7d7fa5ac2f98c1f16a19023`
- **From**: `0x1da4207f6f6da04c9fe66bb72b1fa89616220a72`
- **Gas Used**: 1,789,255 (0x1b3f47)
- **Gas Price**: 3,618 (0xe22) wei
- **Block**: 0x1d5079d (30,749,853)
- **Status**: Success (0x1)

### Key Details
- **Chain ID**: 130 (Unichain)
- **Price Feed ID**: `0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace`
- **Pyth Oracle Address**: `0x2880ab155794e7179c9ee2e38200202908c17b43`
- **All transactions were successful** (status: 0x1)
- **Total gas spent**: ~1.2M gas across all transactions
- **Timestamps**: January 26, 2025