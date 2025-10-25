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

        // Hardcoded price update data
        string
            memory hardCoded = "0x504e41550100000003b801000000040d00cda14c749a60206e1e8dc3d63559d6bece41bffe41fd786ae66c2f8c4582815f58dc528737e46b86024232f8135a6c51c26f7759f74aa6c0648d8e75f595105f000386aed9eccf3e2928f434b33fb18ca0e3ff3dcc2a068ca3324ddfdb64e516c51056c138ab45fb51f501669df3cd0e5040d211ef8c15755e7224346fdff61f96730104e839c26aeb3fa328c00e081c99ba641f5b7173af0fd540c28d5c8d33bbd6ee19799082d2db9b4525e29ca3862eb9eca221f40f566962ec3e1dff6a1bddc44bee01065ac06fee4a7042ca509c564134473e89f8e9c95f6f12679d8e64c3f238496fc617b8c13efbada41a69662018333658e8fd97f34921346046f771fe91adecdff4000863b557ca0303c38602e87a5558c29df7d0d23d2f13b1d5af131b65a1cdc89601196f5ab0e555e62d3e3607ea0dc26a96ca0d03907bef9d4024d7d9a1e6e13ca6000ba1d4a722b67de6a7ac67d633187f6f4d3bb65cc619c7b64a5ec7528dcc1107dc4964a124d0b274ae7e9e03c3c1fb4a3957fe3bb807066d422cdb96a496b94427010cbf2bcd61800fb11e6bec8a97bcd3f2882a3b2f68b3745907ff7ee1efaaf2ff6b1998b2a7f6e1baaded71068834bc2343827ae53859e2027013c15f349a884611010d2e9539e50f029a31600f354d1070e38e0dbd50cd9f25aff1fc1bd3bea120db1211e0d513db86d1d6bb6c93797a68178f4a93ae0c86bfe5ad5be65e056ff52202000edfff7d76f608a5fbede00465434518265ff8a57921d7407b98c9d73bcab97cae3b1664f3b349fea2a0129130d1e677f67a3a5cd0f6b78b415752dc5c3cf54a9a010f4b556c9b26967721c33eff69d0130dd6e22946f18c8933212f200d4d10f2784b0c4b03c6f5966ad991ef277a6d4ce7b52488c2482fd90dcbb02a1f1d79c2be130110586047cb87fc5f8f12496ac6f96013acc1e3e1f41da7def495f6cd0958f1e6e53b994e4e4c0d73e5c8e63524a362b2809ad765144a53ca3161360d0cb850eae0001106b9884a82074e8ccb5368e3d49997962fd38a59c8a4222a66ef0a74731b78c80951e42030953c2949e3503b4b1ddac8994d885ad61c7581aaa72ea728abf79f0112988089c65779e215fee9dd2a323c80e751b9bd15bfbf9eaf18ae152495acbfc91985fcbeb4d87329250c0e40ab57126729f194ba6f17b6d53703ad1cc92c3df00068fb5ec300000000001ae101faedac5851e32b9b23b5f9411a8c2bac4aae3ed4dd7b811dd1a72ea4aa710000000009e3e3c9014155575600000000000ef184c700002710c6c852fab5d16fe86afdddb3f5a96ce44bc44dc601005500ff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace0000005c3368dbc100000000084ee578fffffff80000000068fb5ec30000000068fb5ec20000005c28155d40000000000860ed730db650a25b04d5f431101ca35858b1aee7621ee02b3510c37cd6ccb5da7d8388128268f3cdf1c27f766b3fd3cae7d0845b55e76c12a949cfab29248f0dedbfd17c62224f4cfdc22d6880ca8f8ad3588e3d0b8ad945e725f61585d7823d22c63d9543067f188ca8b13e22967b918867cb090b5c5795f293dbbdfc8d5441b6593e7e1371a97ddc7ef72bec1bf63908e2a4e108ca227f8176a00d4d45f5b51a4ea44d99392994752038f95f3e7828cafc7a92119ae1039f7f78f364594505fc16976b6f61656773b06a8838d3865a17cadae1c7d1691d9daf8057ca3db278428df52c7140690c1a59a9196783ba066ad7c7e5ab2024092eddfd3e47b04468889d6da766ee8a56";

        // Convert to bytes[] array
        bytes[] memory priceUpdate = new bytes[](1);
        priceUpdate[0] = vm.parseBytes(hardCoded);

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

    function _hexStringToBytes(
        string memory hexStr
    ) internal pure returns (bytes memory) {
        bytes memory strBytes = bytes(hexStr);
        uint offset = 0;

        // Skip "0x" prefix if present
        if (
            strBytes.length >= 2 &&
            strBytes[0] == "0" &&
            (strBytes[1] == "x" || strBytes[1] == "X")
        ) {
            offset = 2;
        }

        uint len = (strBytes.length - offset) / 2;
        bytes memory result = new bytes(len);

        for (uint i = 0; i < len; i++) {
            result[i] = bytes1(
                _hexCharToByte(strBytes[offset + 2 * i]) *
                    16 +
                    _hexCharToByte(strBytes[offset + 2 * i + 1])
            );
        }

        return result;
    }

    function _hexCharToByte(bytes1 char) internal pure returns (uint8) {
        uint8 byteValue = uint8(char);
        if (
            byteValue >= uint8(bytes1("0")) && byteValue <= uint8(bytes1("9"))
        ) {
            return byteValue - uint8(bytes1("0"));
        } else if (
            byteValue >= uint8(bytes1("a")) && byteValue <= uint8(bytes1("f"))
        ) {
            return 10 + byteValue - uint8(bytes1("a"));
        } else if (
            byteValue >= uint8(bytes1("A")) && byteValue <= uint8(bytes1("F"))
        ) {
            return 10 + byteValue - uint8(bytes1("A"));
        }
        revert("Invalid hex character");
    }
}
