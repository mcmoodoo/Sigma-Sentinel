import requests
import time
import json

# Base URL for the API
BASE_URL = "https://benchmarks.pyth.network/v1/updates/price"

# Parameters
timestamp = int(time.time()) - 60
interval = 2
price_feed_id = "0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace"

# Construct URL
url = f"{BASE_URL}/{timestamp}/{interval}"
params = {"ids": price_feed_id}

# Make request
response = requests.get(url, params=params)
response.raise_for_status()

# print(response.json())

# Save JSON response to file
with open("cache/historical_price_update.json", "w") as f:
    json.dump(response.json(), f, indent=2)

print("✅ Saved response to cache/historical_price_update.json")
