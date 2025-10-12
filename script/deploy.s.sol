// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Counter.sol";

contract DeploySomeContract is Script {
    function run() external {
        // Anvil default private key (DO NOT use in production)
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        // Start broadcasting with this private key
        vm.startBroadcast(deployerPrivateKey);

        // Use a placeholder Pyth contract address (replace with actual one if needed)
        address pythContractAddress = 0x4305FB66699C3B2702D4d05CF36551390A4c69C6; // example ETH mainnet address

        // Deploy the contract
        SomeContract someContract = new SomeContract(pythContractAddress);

        console.log("SomeContract deployed at:", address(someContract));

        vm.stopBroadcast();
    }
}
