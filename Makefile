.PHONY: build clean test script deploy fmt coverage

build:
	@echo "Building the project..."
	forge build

deploy:
	@echo "Deploying the project..."
	forge script script/DeployScript.s.sol:DeployScript --rpc-url $(NETWORK) --sig "run(string)" $(NETWORK) --account TestAccount --sender 0x8f0E6e090FA856967Db75B9F8aE8c32a120F2Ba1 --verify --broadcast