import "dotenv/config";
import { createPublicClient, formatEther, http, parseEther } from "viem";
import {
    sepolia,
    arbitrumSepolia,
    optimismSepolia,
    baseSepolia,
} from "viem/chains";
import abi from "./abi.js";

const chainDetails = {
    16015286601757825753n: {
        chain: sepolia,
        router: "0xEd1f6473345F45b75F8179591dd5bA1888cf2FB3",
        rpcUrl: process.env.ETHEREUM_SEPOLIA_RPC_URL,
        ccipBnM: "0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05",
        ccswap: "0x530b9AeBF59481e459Cf6a0c7269042843a6FCb2",
    },
    3478487238524512106n: {
        chain: arbitrumSepolia,
        router: "0x2779a0CC1c3e0E44D2542EC3e79e3864Ae93Ef0B",
        rpcUrl: process.env.ARBITRUM_SEPOLIA_RPC_URL,
        ccipBnM: "0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D",
        ccswap: "0xa67D4C6E8ffF498a57F400A95701ED7Ee0c161A9",
    },
    10344971235874465080n: {
        chain: baseSepolia,
        router: "0xC5290058841028F1614F3A6F0F5816cAd0df5E27",
        rpcUrl: process.env.BASE_SEPOLIA_RPC_URL,
        ccipBnM: "0x88A2d74F47a237a62e7A51cdDa67270CE381555e",
        ccswap: "0x1Ef00bE0a03f862f980Ac8789A37031c69fB2417",
    },
    5224473277236331295n: {
        chain: optimismSepolia,
        router: "0xC5290058841028F1614F3A6F0F5816cAd0df5E27",
        rpcUrl: process.env.OPTIMISM_SEPOLIA_RPC_URL,
        ccipBnM: "0x8aF4204e30565DF93352fE8E1De78925F6664dA7",
        ccswap: "0xfeCaAc337c404D39944C64B6A174bDadD1269F63",
    },
};

const POOL_FEE = 500; // 0.05% fee

async function simulateSwap({
    originChainSelector,
    destinationChainSelector,
    amount,
    token0,
    token1,
}) {
    const originChain = chainDetails[originChainSelector];
    const destinationChain = chainDetails[destinationChainSelector];
    const originClient = createPublicClient({
        chain: originChain.chain,
        transport: http(originChain.rpcUrl),
    });
    const destinationClient = createPublicClient({
        chain: destinationChain.chain,
        transport: http(destinationChain.rpcUrl),
    });

    const amountInWei = parseEther(amount.toString());

    const params = {
        tokenIn: token0,
        tokenOut: originChain.ccipBnM,
        amountIn: amountInWei,
        fee: POOL_FEE,
        sqrtPriceLimitX96: 0n,
    };

    let { result } = await originClient.simulateContract({
        address: originChain.router,
        abi: abi, // Add the ABI for the router contract
        functionName: "quoteExactInputSingle",
        args: [params],
    });

    console.log("Origin chain swap output value:", formatEther(result[0]));

    const destinationParams = {
        tokenIn: destinationChain.ccipBnM,
        tokenOut: token1,
        amountIn: result[0],
        fee: POOL_FEE,
        sqrtPriceLimitX96: 0n,
    };

    let output = await destinationClient.simulateContract({
        address: destinationChain.router,
        abi: abi, // Add the ABI for the router contract
        functionName: "quoteExactInputSingle",
        args: [destinationParams],
    });

    console.log(
        "Cross-chain swap output value:",
        formatEther(output.result[0])
    );

    return formatEther(output.result[0]);
}

export default simulateSwap;

