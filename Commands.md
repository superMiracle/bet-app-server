## Sepolia Etherscan

forge script script/USDCPool/USDCPool.s.sol --broadcast --private-key 1af2d6e917d558cd9910bbbca67b052db3c5a4d6b469b6b0000fbb700cd2e816 --etherscan-api-key 7GVAT4QGWK35B8C1AXKB5EISIQSJBY2ZWH --rpc-url https://ethereum-sepolia-rpc.publicnode.com --verify src/USDCPool/USDCPool.sol:USDCPool

## Local

forge script script/FirstNFTFactory.s.sol --broadcast --private-key 59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d --rpc-url http://127.0.0.1:8545

cast send 0x56c6cfeE72Fce10361ccC50B3E9AE547811D8E60 --value 100000000000000000000 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --rpc-url http://127.0.0.1:8545

## Sepolia Blast

forge script script/USDCPool/MyBet.s.sol --broadcast --private-key 1af2d6e917d558cd9910bbbca67b052db3c5a4d6b469b6b0000fbb700cd2e816 --etherscan-api-key T7ZFIXZ4XEKCVBVIPPP5EA9EF9MJUETJEQ --rpc-url https://endpoints.omniatech.io/v1/blast/sepolia/public --verify src/USDCPool/MyBet.sol:MyBet
