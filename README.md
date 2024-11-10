# MobiFi

## Overview
MobiFi (MBF) is a TRC20 utility token designed to revolutionize the mobile phone retail ecosystem.<br> Built on the TRON network, MobiFi introduces a blockchain-based loyalty and rewards system <br> for mobile phone stores, creating a seamless connection between retailers and customers.

## Features

### 🎯 Core Functionality
- Utility Token: Used for purchases, discounts, rewards, and ecosystem benefits
- Smart Contract Based: Built on TRON network following TRC20 standard
- Fixed Supply: Total supply of 10 million tokens (10,000,000 MBF)
- Secure: Implements standard security practices and audit recommendations

### 💎 Token Distribution
- Public Sale: 40% (4,000,000 MBF)
- Rewards Pool: 30% (3,000,000 MBF)
- Team Allocation: 15% (1,500,000 MBF)
- Marketing & Partnerships: 10% (1,000,000 MBF)
- Reserve: 5% (500,000 MBF)

### 🏆 Loyalty Program
- Bronze Tier: 100 tokens - 5% storewide discount
- Silver Tier: 500 tokens - 10% discount + early product access
- Gold Tier: 1000 tokens - 15% discount + priority support + exclusive events

### 🔒 Staking System
- Lock periods: 3-6 months
- Additional rewards for staked tokens
- Automatic tier upgrades based on staking amount

## Smart Contract

### Contract Address
- Mainnet: [To be added after deployment]
- Testnet: [To be added after testnet deployment]


## Installation

1. Clone the repository<br>
```
git clone https://github.com/Unnati-Gupta24/MobiFi.git
cd MobiFi
```

2. Install dependencies<br>
```
npm install
```

3. Configure environment variables<br>
```
cp .env.example .env
# Edit .env with your configuration
```

4. Compile Contracts<br>
```
tronbox compile
```

5. Deploy Contracts Testnet<br>
```
tronbox migrate --network shasta
```

## Integration Guide

### Adding MobiFi to Your Store

```
const MobiFi = require('@mobifi/contract');
const contract = new MobiFi('YOUR_CONTRACT_ADDRESS');

// Calculate customer discount
const discount = await contract.calculateDiscount(customerAddress, purchaseAmount);

// Process referral
await contract.rewardReferral(referrerAddress, refereeAddress);
```

## Contributing

1. Fork the repository<br>
2. Create your feature branch (git checkout -b feature/AmazingFeature)<br>
3. Commit your changes (git commit -m 'Add some AmazingFeature')<br>
4. Push to the branch (git push origin feature/AmazingFeature)<br>
5. Open a Pull Request

## License
Distributed under the MIT License. See LICENSE for more information.

