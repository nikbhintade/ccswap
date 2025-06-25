import express from "express";
import cors from "cors";
import rateLimit from "express-rate-limit";
import simulateSwap from "./simulateSwap.js";

const isProduction = process.env.NODE_ENV === "production";
const ALLOWED_ORIGIN = "https://your-allowed-domain.com"; // Change to your allowed domain

const corsOptions = isProduction
    ? { origin: ALLOWED_ORIGIN, optionsSuccessStatus: 200 }
    : { origin: true, optionsSuccessStatus: 200 };

const app = express();

// CORS middleware to allow only certain domain
app.use(cors(corsOptions));

// Rate limiting middleware: 2 requests per second per IP
const limiter = rateLimit({
    windowMs: 1000, // 1 second
    max: 2,
});
app.use(limiter);

app.get("/", (req, res) => {
    res.send("Hello from Express server!");
});

/**
 * http://localhost:3000/simulate?originChainSelector=16015286601757825753&destinationChainSelector=3478487238524512106&amount=0.1&token0=0xC5AaBA5A2bf9BaFE78402728da518B8b629F3808&token1=0x6110497BB349F84452b92E012B4D6394B5A41AC0
 */

app.get("/simulate", async (req, res) => {
    const {
        originChainSelector,
        destinationChainSelector,
        amount,
        token0,
        token1,
    } = req.query;

    try {
        const result = await simulateSwap({
            originChainSelector: BigInt(originChainSelector),
            destinationChainSelector: BigInt(destinationChainSelector),
            amount,
            token0,
            token1,
        });
        res.json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
