// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Sentinel} from "../src/Sentinel.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract UpdateSentinelWithPrice is Script {
    IPyth pyth;

    function run() external {
        vm.startBroadcast();

        string memory broadcast = vm.readFile(
            string.concat(
                "./broadcast/deploy.s.sol/",
                vm.toString(block.chainid),
                "/run-latest.json"
            )
        );

        address sentinelAddr = vm.parseJsonAddress(broadcast, ".transactions[0].contractAddress");
        console2.log("Sentinel address:", sentinelAddr);

        string memory priceUpdateJson = vm.readFile(
            "./cache/data.json"
        );
        bytes[] memory priceUpdateHex = vm.parseJsonBytesArray(priceUpdateJson, ".PRICE_UPDATE_HEX");

        Sentinel sentinel = Sentinel(sentinelAddr);

        IPyth pythInstance = IPyth(sentinel.pyth());
        uint256 fee = pythInstance.getUpdateFee(priceUpdateHex);

        console2.log("Update fee:", fee);

        sentinel.refreshPriceFeed{value: fee}(priceUpdateHex);
        sentinel.refreshPrice();

        (int64 price,,,) = sentinel.price();

        console2.log("price:", price);

        vm.stopBroadcast();
    }
}
