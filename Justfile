PYTH_UNICHAIN := "0x2880aB155794e7179c9eE2e38200202908C17B43"

# list available commands
default:
    @just --list

# spin up anvil
anvil-fork:
    anvil --fork-url $INFURA_UNICHAIN_MAINNET_RPC

# deploy Sentinel smart contract
deploy:
    forge script script/deploy.s.sol --rpc-url $INFURA_UNICHAIN_MAINNET_RPC --broadcast --account burner
    
# refresh price feeds and fetch the price
refresh-price:
    python fetch-price-update.py
    forge script script/update.s.sol --rpc-url $INFURA_UNICHAIN_MAINNET_RPC --broadcast --account burner

get-price addr:
    cast call {{addr}} "getPrice()(int64)" --rpc-url $INFURA_UNICHAIN_MAINNET_RPC

get-mean addr:
    cast call {{addr}} "mean()(int64)" --rpc-url $INFURA_UNICHAIN_MAINNET_RPC 

get-historical-price-count addr:
    cast call {{addr}} "getHistoricalPriceCount()(uint256)" --rpc-url $INFURA_UNICHAIN_MAINNET_RPC

get-all-historical-prices addr:
    cast call {{addr}} "getAllHistoricalPrices()((int64,uint64,uint64,int32)[])" --rpc-url $INFURA_UNICHAIN_MAINNET_RPC

historical:
    python fetch-historical-price-updates.py
    forge script script/fetchHistoricalPrices.s.sol --rpc-url $INFURA_UNICHAIN_MAINNET_RPC --broadcast --account burner
