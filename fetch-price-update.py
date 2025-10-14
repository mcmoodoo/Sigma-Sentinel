import requests, json
from web3 import Web3

# Fetch price update
resp = requests.get("https://hermes.pyth.network/v2/updates/price/latest?ids[]=...")
parts = ["0x"+p if not p.startswith("0x") else p for p in resp.json()["binary"]["data"]]

# Save to JSON cache
with open("cache/data.json", "w") as f:
    json.dump({"PRICE_UPDATE_HEX": parts}, f)
