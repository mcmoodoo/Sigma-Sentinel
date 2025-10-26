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
    
    function getHistoricalPriceCount() external view returns (uint256);
    function getHistoricalPrice(uint256 index) external view returns (
        int64 price,
        uint64 publishTime,
        uint64 confidence,
        int32 expo
    );
    function getAllHistoricalPrices() external view returns (
        int64[] memory prices,
        uint64[] memory publishTimes,
        uint64[] memory confidences,
        int32[] memory expos
    );
}

contract FetchMultipleHistoricalPricesScript is Script {
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
        string memory historicalData = vm.readFile("./price_update.json");
        
        // Set up time bounds
        uint64 minPublishTime = uint64(block.timestamp - 30000);
        uint64 maxPublishTime = uint64(block.timestamp + 30000);
        
        // Start broadcasting for all transactions
        vm.startBroadcast();
        
        // Process each entry - try to parse until we hit an error
        uint256 entryCount = 0;
        bool hasMoreEntries = true;
        
        console2.log("Starting to process historical price updates...");
        
        while (hasMoreEntries) {
            try vm.parseJsonString(
                historicalData, 
                string.concat("$[", vm.toString(entryCount), "].binary.data[0]")
            ) returns (string memory hexData) {
                console2.log("Processing entry", entryCount);
                
                // Convert to bytes[] array
                bytes[] memory priceUpdate = new bytes[](1);
                priceUpdate[0] = vm.parseBytes(hexData);
                
                console2.log("Calling historicalPrice for entry", entryCount);
                
                // Call historicalPrice for this entry
                ISettlement(sentinelAddr).historicalPrice{value: 1}(
                    priceUpdate,
                    minPublishTime,
                    maxPublishTime
                );
                
                entryCount++;
            } catch {
                hasMoreEntries = false;
            }
        }
        
        console2.log("Processed", entryCount, "price update entries");
        
        // Read back the stored historical prices
        console2.log("Reading stored historical prices...");
        uint256 storedCount = ISettlement(sentinelAddr).getHistoricalPriceCount();
        console2.log("Total stored historical prices:", storedCount);
        
        // Display first few prices for verification
        for (uint256 i = 0; i < storedCount && i < 5; i++) {
            (int64 price, uint64 publishTime, uint64 confidence, int32 expo) = 
                ISettlement(sentinelAddr).getHistoricalPrice(i);
            console2.log("Price", i, ":");
            console2.log("  Value:", price);
            console2.log("  Publish Time:", publishTime);
            console2.log("  Confidence:", confidence);
            console2.log("  Exponent:", expo);
        }
        
        vm.stopBroadcast();
    }
}