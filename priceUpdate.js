const connection = new HermesClient("http://hermes.pyth.network", {});

const priceIds = [
   "0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace" // ETH/USD
];

const priceUpdates = await connection.getLatestPriceUpdates(priceIds);
console.log(priceUpdates);
