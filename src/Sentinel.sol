// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract Sentinel {
    IPyth public pyth;
    PythStructs.Price public price;

    int64 public mean;

    bytes32 public constant PRICE_FEED_ID =
        0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace; // ETH/USD
    uint256 public constant STALENESS_THRESHOLD_IN_SECONDS = 60;

    // Historical price storage
    struct HistoricalPrice {
        int64 price;
        uint64 publishTime;
        uint64 confidence;
        int32 expo;
    }

    HistoricalPrice[] public historicalPrices;
    uint256 public historicalPriceCount;

    /**
     * @param pythContract The address of the Pyth contract
     */
    constructor(address pythContract) {
        // The IPyth interface from pyth-sdk-solidity provides the methods to interact with the Pyth contract.
        // Instantiate it with the Pyth contract address from https://docs.pyth.network/price-feeds/contract-addresses/evm
        pyth = IPyth(pythContract);
    }

    /**
     * refresh the price feed
     * @param priceUpdate The encoded data to update the contract with the latest price
     */
    function refreshPriceFeed(bytes[] calldata priceUpdate) public payable {
        // Submit a priceUpdate to the Pyth contract to update the on-chain price.
        // Updating the price requires paying the fee returned by getUpdateFee.
        // WARNING: These lines are required to ensure the getPriceNoOlderThan call below succeeds. If you remove them, transactions may fail with "0x19abf40e" error.
        uint fee = pyth.getUpdateFee(priceUpdate);
        pyth.updatePriceFeeds{value: fee}(priceUpdate);
    }

    function refreshPrice() public {
        price = pyth.getPriceNoOlderThan(
            PRICE_FEED_ID,
            STALENESS_THRESHOLD_IN_SECONDS
        );
    }

    function getPrice() public view returns (int64) {
        return price.price;
    }

    function refreshAndFetchPrice(bytes[] calldata priceUpdate) public payable {
        refreshPriceFeed(priceUpdate);
        refreshPrice();
    }

    function historicalPrice(
        bytes[] calldata priceUpdate,
        uint64 minPublishTime,
        uint64 maxPublishTime
    ) external payable {
        uint fee = pyth.getUpdateFee(priceUpdate);

        bytes32[] memory priceFeeds = new bytes32[](1);
        priceFeeds[0] = PRICE_FEED_ID;

        PythStructs.PriceFeed[] memory prices = pyth.parsePriceFeedUpdates{
            value: fee
        }(priceUpdate, priceFeeds, minPublishTime, maxPublishTime);

        require(prices.length > 0, "Empty price array from pyth");

        // Store the historical price data
        for (uint256 i = 0; i < prices.length; i++) {
            historicalPrices.push(HistoricalPrice({
                price: prices[i].price.price,
                publishTime: uint64(prices[i].price.publishTime),
                confidence: prices[i].price.conf,
                expo: prices[i].price.expo
            }));
            historicalPriceCount++;
        }

        // Update mean with the latest price
        mean = prices[0].price.price;
    }

    /**
     * @dev Get a specific historical price by index
     * @param index The index of the historical price
     * @return priceValue The price value
     * @return publishTime The publish time
     * @return confidence The confidence value
     * @return expo The exponent
     */
    function getHistoricalPrice(uint256 index) external view returns (
        int64 priceValue,
        uint64 publishTime,
        uint64 confidence,
        int32 expo
    ) {
        require(index < historicalPriceCount, "Index out of bounds");
        HistoricalPrice memory hp = historicalPrices[index];
        return (hp.price, hp.publishTime, hp.confidence, hp.expo);
    }

    /**
     * @dev Get all historical prices
     * @return prices Array of historical price data
     */
    function getAllHistoricalPrices() external view returns (HistoricalPrice[] memory prices) {
        return historicalPrices;
    }

    /**
     * @dev Get the count of historical prices
     * @return count Number of stored historical prices
     */
    function getHistoricalPriceCount() external view returns (uint256 count) {
        return historicalPriceCount;
    }

    /**
     * @dev Get historical prices in a range
     * @param startIndex Starting index (inclusive)
     * @param endIndex Ending index (exclusive)
     * @return prices Array of historical price data in the specified range
     */
    function getHistoricalPricesRange(uint256 startIndex, uint256 endIndex) external view returns (HistoricalPrice[] memory prices) {
        require(startIndex < historicalPriceCount, "Start index out of bounds");
        require(endIndex <= historicalPriceCount, "End index out of bounds");
        require(startIndex < endIndex, "Invalid range");

        uint256 length = endIndex - startIndex;
        HistoricalPrice[] memory result = new HistoricalPrice[](length);
        
        for (uint256 i = 0; i < length; i++) {
            result[i] = historicalPrices[startIndex + i];
        }
        
        return result;
    }
}
