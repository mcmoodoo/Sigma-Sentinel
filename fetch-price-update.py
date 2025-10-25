import sys
import requests
import json
from datetime import datetime
from web3 import Web3

price_feed_id = "0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace"
url = f"https://hermes.pyth.network/v2/updates/price/latest?ids[]={price_feed_id}"

try:
    resp = requests.get(url, timeout=10)
    resp.raise_for_status()
except requests.exceptions.Timeout:
    sys.exit("Error: Request timed out")
except requests.exceptions.HTTPError as e:
    sys.exit(f"HTTP error: {e}")
except requests.exceptions.RequestException as e:
    sys.exit(f"Request failed: {e}")

try:
    data = resp.json()
except json.JSONDecodeError:
    sys.exit("Error: Failed to decode JSON response")

try:
    parts = ["0x" + p if not p.startswith("0x") else p for p in data["binary"]["data"]]
except KeyError:
    sys.exit("Error: Unexpected JSON structure, missing 'binary' or 'data' keys")
except TypeError:
    sys.exit("Error: 'data' is not iterable")

# Save to JSON cache with timestamp
timestamp = datetime.utcnow().isoformat() + "Z"  # UTC ISO 8601 format

try:
    with open("cache/data.json", "w") as f:
        json.dump({
            "PRICE_UPDATE_HEX": parts,
            "FETCHED_AT": timestamp
        }, f, indent=2)
except IOError as e:
    sys.exit(f"Error writing to file: {e}")

print(f"Price update saved successfully to cache/data.json at {timestamp}!")

