PYTH_UNICHAIN := "0x2880aB155794e7179c9eE2e38200202908C17B43"

default:
    @just --list

# spin up anvil
anvil-fork:
    anvil --fork-url $INFURA_UNICHAIN_MAINNET_RPC

# deploy the example smart contract
deploy:
    forge script script/deploy.s.sol --rpc-url $INFURA_UNICHAIN_MAINNET_RPC --broadcast --account burner
    
get-update-fee bytes addr=PYTH_UNICHAIN:
    cast call {{addr}} \
        "getUpdateFee(bytes[])" \
        {{bytes}} \
        --rpc-url $INFURA_UNICHAIN_MAINNET_RPC

update-price addr:
    cast send {{addr}} \
        "exampleMethod(bytes[])" \
        "[$PRICE_UPDATE_HEX]" \
        --value 10 \
        --account burner \
        --rpc-url $INFURA_UNICHAIN_MAINNET_RPC

hit-hermes:
    curl -s 'https://hermes.pyth.network/v2/updates/price/latest?ids[]=0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace' -H 'accept: application/json' | jq .binary.data[]

fetch-price-update:
    set -euo pipefail

    # Fetch price update
    raw=$(curl -s 'https://hermes.pyth.network/v2/updates/price/latest?ids[]=0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace' \
           -H 'accept: application/json')

    # Convert to 0x-prefixed JSON array
    newdata=$(echo "$raw" | jq -c '[.binary.data[] | if startswith("0x") then . else "0x"+. end]')
