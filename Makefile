# Load environment variables from .env if it exists
ifneq (,$(wildcard .env))
	include .env
	export
endif

.PHONY: build clean test script deploy fmt coverage

build:
	@echo "Building the project..."
	forge build

deploy:
	@echo "Deploying the project..."
	forge script script/DeployScript.s.sol:DeployScript --rpc-url $(NETWORK) --sig "run(string)" $(NETWORK) --account TestAccount --sender 0x8f0E6e090FA856967Db75B9F8aE8c32a120F2Ba1 --verify --broadcast

fork-testnet:
	@echo "Forking testnet..."
	anvil --fork-url $(BASE_SEPOLIA_RPC_URL) --fork-block-number 27407540