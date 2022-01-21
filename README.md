# Arbitrage contracts

Utilize AAVE flashloans to arbitrage Uniswap v2 AMMs.

## Build

```
make build
```

## Deploy

Updated `ARBED_ASSET` in Makefile with the asset you want to arb, then
deploy in Kovan with:
```
make deploy-kovan
```

Deploy in Polygon:
```
make deploy-polygon
```

## Contracts

| Contract              | Polygon                                                                                                                  | Kovan                                                                                                                       |
|-----------------------|--------------------------------------------------------------------------------------------------------------------------|------------|
| USDC                  | [0x2791bca1f2de4661ed88a30c99a7a9449aa84174](https://polygonscan.com/address/0x2791bca1f2de4661ed88a30c99a7a9449aa84174) | Check [AAVE faucet](https://staging.aave.com/#/faucet)                                                                                         |
| Lending pool provider | [0xd05e3E715d945B59290df0ae8eF85c1BdB684744](https://polygonscan.com/address/0xd05e3E715d945B59290df0ae8eF85c1BdB684744) | [0x88757f2f99175387aB4C6a4b3067c77A695b0349](https://kovan.etherscan.io/address/0x88757f2f99175387aB4C6a4b3067c77A695b0349) |
| Liquidity router #0   | [0x1b02da8cb0d097eb8d57a175b88c7d8b47997506](https://polygonscan.com/address/0x1b02da8cb0d097eb8d57a175b88c7d8b47997506) | [0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506](https://kovan.etherscan.io/address/0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506) |
| Liquidity router #1   | [0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff](https://polygonscan.com/address/0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff) | [0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D](https://kovan.etherscan.io/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D) |
