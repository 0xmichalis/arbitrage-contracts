
build: clean
	forge build --optimize --optimize-runs 1000000
.PHONY: build

clean:
	forge clean
.PHONY: clean

deploy-kovan:
	forge create --constructor-args 0x88757f2f99175387aB4C6a4b3067c77A695b0349 \
	             --constructor-args 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506 \
	             --constructor-args 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D \
	             --constructor-args 0x13512979ade267ab5100878e2e0f485b568328a4 \
	             --constructor-args $(ARBED_ASSET) \
	             --rpc-url https://kovan.infura.io/ \
				 --chain kovan -i FlashLoan
.PHONY: deploy-kovan

deploy-polygon:
	forge create --constructor-args 0xd05e3E715d945B59290df0ae8eF85c1BdB684744 \
	             --constructor-args 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506 \
	             --constructor-args 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff \
	             --constructor-args 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174 \
	             --constructor-args 0x4e78011Ce80ee02d2c3e649Fb657E45898257815 \
	             --rpc-url https://polygon-rpc.com/ --chain polygon -i FlashLoan
.PHONY: deploy-polygon
