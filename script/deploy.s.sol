// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Sentinel} from "../src/Sentinel.sol";

contract DeploySentinel is Script {
    function run() external {
        deploy(0x2880aB155794e7179c9eE2e38200202908C17B43);
    }

    function deploy(address pythContractAddress) public {
        vm.startBroadcast();
        Sentinel someContract = new Sentinel(pythContractAddress);

        console.log("Sentinel deployed at:", address(someContract));

        vm.stopBroadcast();

    }
}
