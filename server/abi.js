const abi = [
    {
        type: "function",
        name: "quoteExactInput",
        inputs: [
            {
                name: "path",
                type: "bytes",
                internalType: "bytes",
            },
            {
                name: "amountIn",
                type: "uint256",
                internalType: "uint256",
            },
        ],
        outputs: [
            {
                name: "amountOut",
                type: "uint256",
                internalType: "uint256",
            },
            {
                name: "sqrtPriceX96AfterList",
                type: "uint160[]",
                internalType: "uint160[]",
            },
            {
                name: "initializedTicksCrossedList",
                type: "uint32[]",
                internalType: "uint32[]",
            },
            {
                name: "gasEstimate",
                type: "uint256",
                internalType: "uint256",
            },
        ],
        stateMutability: "nonpayable",
    },
    {
        type: "function",
        name: "quoteExactInputSingle",
        inputs: [
            {
                name: "params",
                type: "tuple",
                internalType: "struct IQuoterV2.QuoteExactInputSingleParams",
                components: [
                    {
                        name: "tokenIn",
                        type: "address",
                        internalType: "address",
                    },
                    {
                        name: "tokenOut",
                        type: "address",
                        internalType: "address",
                    },
                    {
                        name: "amountIn",
                        type: "uint256",
                        internalType: "uint256",
                    },
                    {
                        name: "fee",
                        type: "uint24",
                        internalType: "uint24",
                    },
                    {
                        name: "sqrtPriceLimitX96",
                        type: "uint160",
                        internalType: "uint160",
                    },
                ],
            },
        ],
        outputs: [
            {
                name: "amountOut",
                type: "uint256",
                internalType: "uint256",
            },
            {
                name: "sqrtPriceX96After",
                type: "uint160",
                internalType: "uint160",
            },
            {
                name: "initializedTicksCrossed",
                type: "uint32",
                internalType: "uint32",
            },
            {
                name: "gasEstimate",
                type: "uint256",
                internalType: "uint256",
            },
        ],
        stateMutability: "nonpayable",
    },
    {
        type: "function",
        name: "quoteExactOutput",
        inputs: [
            {
                name: "path",
                type: "bytes",
                internalType: "bytes",
            },
            {
                name: "amountOut",
                type: "uint256",
                internalType: "uint256",
            },
        ],
        outputs: [
            {
                name: "amountIn",
                type: "uint256",
                internalType: "uint256",
            },
            {
                name: "sqrtPriceX96AfterList",
                type: "uint160[]",
                internalType: "uint160[]",
            },
            {
                name: "initializedTicksCrossedList",
                type: "uint32[]",
                internalType: "uint32[]",
            },
            {
                name: "gasEstimate",
                type: "uint256",
                internalType: "uint256",
            },
        ],
        stateMutability: "nonpayable",
    },
    {
        type: "function",
        name: "quoteExactOutputSingle",
        inputs: [
            {
                name: "params",
                type: "tuple",
                internalType: "struct IQuoterV2.QuoteExactOutputSingleParams",
                components: [
                    {
                        name: "tokenIn",
                        type: "address",
                        internalType: "address",
                    },
                    {
                        name: "tokenOut",
                        type: "address",
                        internalType: "address",
                    },
                    {
                        name: "amount",
                        type: "uint256",
                        internalType: "uint256",
                    },
                    {
                        name: "fee",
                        type: "uint24",
                        internalType: "uint24",
                    },
                    {
                        name: "sqrtPriceLimitX96",
                        type: "uint160",
                        internalType: "uint160",
                    },
                ],
            },
        ],
        outputs: [
            {
                name: "amountIn",
                type: "uint256",
                internalType: "uint256",
            },
            {
                name: "sqrtPriceX96After",
                type: "uint160",
                internalType: "uint160",
            },
            {
                name: "initializedTicksCrossed",
                type: "uint32",
                internalType: "uint32",
            },
            {
                name: "gasEstimate",
                type: "uint256",
                internalType: "uint256",
            },
        ],
        stateMutability: "nonpayable",
    },
];

export default abi;
