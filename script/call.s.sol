// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../contracts/SomeContract.sol";

contract CallExampleMethod is Script {
    function run() external {
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.startBroadcast(deployerPrivateKey);

        // Set your deployed contract address
        address someContractAddress = 0x2d493cde51adc74D4494b3dC146759cF32957A23;
        SomeContract someContract = SomeContract(someContractAddress);

        // Mock priceUpdate (empty array for testing only)
        bytes ;

        // Call getUpdateFee (will return 0 for empty array, but normally you'd get it from Pyth)
        uint256 fee = 0; // Replace with someContract.pyth().getUpdateFee(priceUpdate) if pyth is public

        // Call exampleMethod with fee
        someContract.exampleMethod{value: fee}(priceUpdate);

        vm.stopBroadcast();
    }
}
