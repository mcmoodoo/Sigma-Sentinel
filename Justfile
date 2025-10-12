default:
    @just --list

# spin up anvil
anvil-fork:
    anvil --fork-url $INFURA_ETHEREUM_MAINNET_RPC

# deploy the example smart contract
deploy:
    forge script script/deploy.s.sol --rpc-url http://localhost:8545 --broadcast

update-price addr="0x2d493cde51adc74D4494b3dC146759cF32957A23":
    cast send {{addr}} \
      "exampleMethod(bytes[])" \
      "[]" \
      --value 0 \
      --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
      --rpc-url http://localhost:8545
