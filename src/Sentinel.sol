// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";
import "@abdk-libraries-solidity/ABDKMath64x64.sol";

contract Sentinel {
    IPyth public pyth;
    PythStructs.Price public price;

    int64 public mean;

    bytes32 public constant PRICE_FEED_ID =
        0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace; // ETH/USD
    uint256 public constant STALENESS_THRESHOLD_IN_SECONDS = 60;

    // Historical price data for volatility calculation
    struct HistoricalPrice {
        int64 price;
        uint64 publishTime;
        uint64 confidence;
        int32 expo;
    }

    HistoricalPrice[] public historicalPrices;
    uint256 public historicalPriceCount;

    // Fixed-point precision for volatility calculations
    int256 constant DECIMALS = 1e18;

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

        // Store the historical price data for volatility calculation
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
     * @dev Compute log return between two prices using fixed-point arithmetic
     * @param priceCurrent Current price
     * @param pricePrev Previous price
     * @return log return in fixed-point (1e18)
     */
    function logReturn(int64 priceCurrent, int64 pricePrev) internal pure returns (int256) {
        require(pricePrev > 0 && priceCurrent > 0, "Price must be positive");
        
        // Scale to 1e18 fixed point
        int256 ratio = (int256(priceCurrent) * DECIMALS) / int256(pricePrev);
        
        // Convert to ABDKMath64x64 format (64.64 fixed point)
        int128 fixedRatio = ABDKMath64x64.fromInt(ratio / 1e18);
        int128 logFixed = ABDKMath64x64.ln(fixedRatio);
        
        // Convert back to 1e18 fixed-point
        return int256(logFixed) * 1e18 / 0x10000000000000000;
    }

    /**
     * @dev Calculate historical volatility from stored price data
     * @return sigmaPerSecond Volatility per second in fixed-point (1e18)
     */
    function historicalVolatility() external view returns (int256 sigmaPerSecond) {
        uint n = historicalPrices.length;
        require(n > 1, "Need at least 2 prices");

        int256[] memory returnsArr = new int256[](n - 1);
        int256 sum = 0;

        // Compute log returns
        for (uint i = 1; i < n; i++) {
            int256 r = logReturn(historicalPrices[i].price, historicalPrices[i - 1].price);
            returnsArr[i - 1] = r;
            sum += r;
        }

        // Compute mean
        int256 meanReturn = sum / int256(n - 1);

        // Compute sample variance
        int256 variance = 0;
        for (uint i = 0; i < n - 1; i++) {
            int256 diff = returnsArr[i] - meanReturn;
            variance += diff * diff / DECIMALS; // Keep fixed-point scaling
        }
        variance = variance / int256(n - 2); // Sample variance (n-1)

        // Standard deviation = sqrt(variance)
        sigmaPerSecond = sqrt(variance);
    }

    /**
     * @dev Babylonian method for sqrt in fixed-point
     * @param x Value to take square root of
     * @return y Square root in fixed-point
     */
    function sqrt(int256 x) internal pure returns (int256 y) {
        require(x >= 0, "sqrt of negative");
        if (x == 0) return 0;
        int256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /**
     * @dev Get annualized volatility (multiply by sqrt(seconds per year))
     * @return Annualized volatility in fixed-point (1e18)
     */
    function getAnnualizedVolatility() external view returns (int256) {
        int256 sigmaPerSecond = this.historicalVolatility();
        // Approximate seconds per year: 365.25 * 24 * 3600 = 31,557,600
        int256 secondsPerYear = 31557600;
        int256 sqrtSecondsPerYear = sqrt(secondsPerYear * DECIMALS);
        return (sigmaPerSecond * sqrtSecondsPerYear) / DECIMALS;
    }

    /**
     * @dev Get the count of historical prices
     * @return count Number of stored historical prices
     */
    function getHistoricalPriceCount() external view returns (uint256 count) {
        return historicalPriceCount;
    }

    /**
     * @dev Get all historical prices (for debugging/verification)
     * @return prices Array of historical price data
     */
    function getAllHistoricalPrices() external view returns (HistoricalPrice[] memory prices) {
        return historicalPrices;
    }
}