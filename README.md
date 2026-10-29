# Aptos 0DTE (Zero-Day) Quant Futures Terminal

## 📖 Table of Contents
1. [Project Overview](#1-project-overview)
2. [Core Concepts & Use Cases](#2-core-concepts--use-cases)
3. [Project Structure](#3-project-structure)
4. [Prerequisites](#4-prerequisites)
5. [Step-by-Step Setup & Deployment](#5-step-by-step-setup--deployment)
6. [Interactive Usage Guide](#6-interactive-usage-guide)

---

## 1. Project Overview
This repository contains the complete submission for **Track 2: Zero Day Futures Contracts (MVP)**. 

It is a decentralized, 24-hour futures trading platform built on the Aptos blockchain. The system features a Move-based smart contract that handles collateral locking, leverage calculations, and dynamic settlement, paired with a high-performance, responsive trading terminal (frontend) that interacts directly with the Aptos Testnet via the Aptos TS SDK.

---

## 2. Core Concepts & Use Cases
### What are Zero-Day (0DTE) Futures?
Zero-Day to Expiration (0DTE) contracts are financial derivatives that expire on the exact same day they are traded. They offer high-risk, high-reward opportunities over a very short time horizon (24 hours).

### Real-World DeFi Use Cases:
* **Short-Term Speculation:** Traders can take highly leveraged positions (up to 10x in this MVP) on intraday price movements without locking up capital for weeks or months.
* **Intraday Portfolio Hedging:** Liquidity providers can hedge immediate market exposure against sudden crashes by opening a 24-hour SHORT position.
* **Algorithmic/Quant Strategies:** Trading bots can utilize short-duration contracts to execute delta-neutral strategies, capitalizing on rapid intraday price convergence.
* **Capital Efficiency:** Because the contract settles in exactly 24 hours (86,400 seconds), capital is freed up daily, allowing for a much higher velocity of money within the DeFi ecosystem.

---

## 3. Project Structure
The repository is kept intentionally lightweight and modular:

* `Move.toml` - The package manifest and configuration file for the Aptos Move smart contract.
* `sources/futures.move` - The core smart contract logic. Contains the `Position` resource, event emission, and the `open_position` and `settle_position` entry functions.
* `index.html` - The complete frontend application. It is a single-file decentralized application (dApp) utilizing Tailwind CSS, HTML5 Canvas for dynamic charting, and the Aptos SDK for direct blockchain communication.

---

## 4. Prerequisites
Before deploying and running this project, ensure you have the following installed:
1. **Aptos CLI:** The command-line tool for compiling and deploying Move contracts. ([Installation Guide](https://aptos.dev/tools/aptos-cli/))
2. **A Modern Web Browser:** Chrome, Firefox, Brave, or Edge (with JavaScript enabled).
3. **A Code Editor:** VSCode, Sublime Text, etc.

---

## 5. Step-by-Step Setup & Deployment

### Phase 1: Smart Contract Deployment
1. **Initialize an Aptos Account:**
   Open your terminal in the project directory and run:
   ```bash
   aptos init --network testnet
   ```
   *Follow the prompts to generate a new keypair and fund it with testnet APT via the faucet.*

2. **Retrieve Your Account Address:**
   Look inside the `.aptos/config.yaml` file that was just generated. Copy your `account` address.

3. **Update the `Move.toml` File:**
   Open `Move.toml` and paste your copied address into the `[addresses]` section:
   ```toml
   [addresses]
   futures_addr = "0xYOUR_ACCOUNT_ADDRESS_HERE"
   ```

4. **Compile and Publish the Contract:**
   Run the following command to deploy the contract to the Aptos Testnet:
   ```bash
   aptos move publish --named-addresses futures_addr=default
   ```
   *Type `yes` when prompted to pay the gas fee.*

### Phase 2: Frontend Setup
Because the frontend is a self-contained HTML file using CDN links (no Node.js or React build step required), setup is instant.

1. Open `index.html` in your code editor.
2. Locate the `contractAddr` input field (around line 118) and update its default `value` to match the address you just deployed to.
3. Open `index.html` in your web browser (Double-click the file, or use VSCode's "Live Server" extension).

---

## 6. Interactive Usage Guide
The frontend is divided into 4 intuitive "Boxes" (Cards). Follow this flow to simulate a trade:

### Step 1: Connect Wallet (Box 1)
* **Contract Address:** Ensure this matches your deployed `futures_addr`.
* **Private Key:** Open `.aptos/config.yaml`, copy your `private_key`, and paste it here. 
* Click **Connect**. The terminal will authenticate you and fetch any existing on-chain data.

### Step 2: Place an Order (Box 2)
* **Direction:** Choose **LONG** (profit if price goes up) or **SHORT** (profit if price goes down).
* **Margin Collateral:** Enter the amount of mock "UNITS" you want to lock up (e.g., 300).
* **Entry Price:** Click "Sync Live Price" or enter a manual USD price.
* **Leverage:** Use the slider to select a multiplier (1x to 10x). Watch the "Est. Liquidation Price" update dynamically.
* Click the **Lock & Open** button to sign and execute the transaction on the Aptos blockchain.

### Step 3: Simulate Market Movement & Settle (Box 3)
* Use the **Market Shock Buttons** (e.g., "+15% Rally", "-5% Dip") to simulate the market moving over the 24-hour period.
* Observe the interactive HTML5 Canvas chart updating your P&L in real-time.
* Click **Settle** to trigger the `settle_position` function on-chain based on the current simulated price.

### Step 4: View Telemetry (Box 4)
* This panel acts as an on-chain explorer. Once your position is settled, this box will sync with the Aptos blockchain.
* It will display your final payout, whether you were liquidated, and provide a direct link to the Aptos Explorer to verify your transaction hashes.

---
