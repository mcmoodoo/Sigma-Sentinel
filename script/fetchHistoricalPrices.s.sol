// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

interface ISettlement {
    function historicalPrice(
        bytes[] calldata priceUpdate,
        uint64 minPublishTime,
        uint64 maxPublishTime
    ) external payable;
}

contract SettleWithHistoricalPriceScript is Script {
    using stdJson for string;

    struct BinaryWrapper {
        bytes[] data;
    }

    struct PriceUpdate {
        BinaryWrapper binary;
    }

    function run() external {
        // Get deployed Sentinel contract address
        string memory broadcast = vm.readFile(
            string.concat(
                "./broadcast/deploy.s.sol/",
                vm.toString(block.chainid),
                "/run-latest.json"
            )
        );
        address sentinelAddr = vm.parseJsonAddress(
            broadcast,
            ".transactions[0].contractAddress"
        );
        console2.log("Sentinel address:", sentinelAddr);

        // Read price update data from JSON file
        string memory historicalData = vm.readFile("./cache/historical_price_update.json");
        
        // Parse the first hex value from the JSON array
        string memory hexData = vm.parseJsonString(historicalData, "$[0].binary.data[0]");
        
        // Convert to bytes[] array
        bytes[] memory priceUpdate = new bytes[](1);
        priceUpdate[0] = vm.parseBytes(hexData);

        uint64 minPublishTime = uint64(block.timestamp - 30000);
        uint64 maxPublishTime = uint64(block.timestamp + 30000);

        // call historicalPrice
        vm.startBroadcast();
        ISettlement(sentinelAddr).historicalPrice{value: 1}(
            priceUpdate,
            minPublishTime,
            maxPublishTime
        );
        vm.stopBroadcast();
    }

}
