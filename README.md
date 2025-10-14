So, let's streamline the price updating. The order is as follows:

1. I call the API and get the `priceUpdate` byte array.
2. I obtain the update fee `getUpdateFee(priceUpdate)`
3. Using both, I refresh the price on-chain: `updatePriceFeeds{value: fee}(priceUpdate)`
4. I can then pull the price from the contract `getPriceNoOlderThan(priceFeedId, 60);`

after the price update, I can immediately start the historical price fetching?

Let's first streamline the above.
