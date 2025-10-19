A decentralized platform built on Clarity smart contracts that provides complete transparency and traceability for cannabis production from seed to sale in the pharmaceutical industry.

## 🔍 Overview

This smart contract system addresses critical issues in the cannabis pharmaceutical supply chain by providing:
- 🔗 Complete seed-to-sale tracking with NFT-style plant identities
- 📜 Regulatory license verification and management
- 🧪 Tamper-proof lab result recording
- 💊 On-chain prescription validation
- 🚨 Real-time product recall capabilities
- 🏆 Compliance incentive system with token rewards

## 🚀 Core Features

### 🌱 Plant Lifecycle Tracking
Each cannabis plant receives a unique digital identity that tracks its complete journey:
- Seed planting and strain information
- Growth stage updates (seedling → vegetative → flowering → harvest)
- Lab testing results and approval status
- Ownership transfers throughout the supply chain

### 🏥 License Management
Comprehensive stakeholder verification system:
- **Growers**: Cultivation license validation
- **Labs**: Testing facility certification
- **Doctors**: Medical prescription authority
- **Pharmacies**: Dispensary distribution rights

### 🧪 Lab Results & Testing
Immutable recording of cannabis testing data:
- THC and CBD concentration levels
- Contaminant detection and safety reports
- Testing facility verification
- Approval status for pharmaceutical use

### 💊 Prescription System
Secure digital prescription workflow:
- Doctor-issued prescriptions linked to specific plants
- Time-sensitive prescription validity (24 hours)
- Pharmacy fulfillment tracking
- Patient safety verification

### 🎯 Compliance & Rewards
Token-based incentive system encouraging transparency:
- Compliance tokens awarded for proper documentation
- Stakeholder scoring system
- Violation tracking and penalties
- Real-time compliance monitoring

## 🛠️ Usage Instructions

### License Registration
```clarity
(contract-call? .cannabis-tracker register-license 'SP1HTBVD3JG9C05J7HBJTHGR0GGW7KX17ECQJ 'grower u2000)
```

### Plant Creation
```clarity
(contract-call? .cannabis-tracker plant-seed "OG Kush")
```

### Stage Updates
```clarity
(contract-call? .cannabis-tracker update-plant-stage u1 "flowering")
```

### Lab Testing
```clarity
(contract-call? .cannabis-tracker submit-lab-results u1 u15 u8 "Clean" true)
```

### Prescription Issuance
```clarity
(contract-call? .cannabis-tracker issue-prescription 'SP2PATIENT u1 u30)
```

### Prescription Fulfillment
```clarity
(contract-call? .cannabis-tracker fill-prescription u1)
```

### Product Recall
```clarity
(contract-call? .cannabis-tracker recall-product u1)
```

## 🔍 Read-Only Functions

### Check License Status
```clarity
(contract-call? .cannabis-tracker get-license 'SP1GROWER "grower")
```

### View Plant Information
```clarity
(contract-call? .cannabis-tracker get-plant u1)
```

### Check Lab Results
```clarity
(contract-call? .cannabis-tracker get-lab-result u1 'SP1LAB)
```

### View Prescription Details
```clarity
(contract-call? .cannabis-tracker get-prescription u1)
```

### Check Compliance Tokens
```clarity
(contract-call? .cannabis-tracker get-compliance-balance 'SP1STAKEHOLDER)
```

### View Stakeholder Score
```clarity
(contract-call? .cannabis-tracker get-stakeholder-score 'SP1ENTITY)
```

## 🏗️ Contract Architecture

### Data Structures
- **licenses**: Entity licensing and validity tracking
- **plants**: Complete plant lifecycle information
- **lab-results**: Testing data and approvals
- **prescriptions**: Medical prescription records
- **compliance-tokens**: Reward token balances
- **stakeholder-scores**: Performance and compliance metrics

### Access Control
- Contract owner manages license registration/revocation
- Licensed entities perform role-specific actions
- Automated compliance scoring and token distribution

## 🔐 Security Features

- ✅ Role-based access control
- ✅ License expiration validation
- ✅ Product recall protection
- ✅ Prescription time limits
- ✅ Ownership verification
- ✅ Compliance tracking

## 🎯 Benefits

### For Patients 👥
- 🔍 Complete product traceability
- 🛡️ Safety through verified lab results
- 💊 Authentic prescription validation

### For Pharmaceutical Companies 🏢
- 📊 Supply chain transparency
- ⚡ Automated compliance tracking
- 🚨 Rapid recall capabilities

### For Regulators 🏛️
- 📋 Real-time compliance monitoring
- 🔒 Tamper-proof record keeping
- 📈 Data-driven oversight

### For Industry 🌿
- 🏆 Incentivized compliance
- 🤝 Trust between stakeholders
- 📱 Streamlined operations

## 🧪 Testing

Deploy using Clarinet and test all contract functions:

```bash
clarinet console
clarinet check
clarinet test
```

## 📄 License

MIT License - Built for transparency and safety in cannabis pharmaceuticals.

## 🛒 Plant Marketplace

### 🌱 Direct Plant Trading
Empower stakeholders with a decentralized marketplace for seamless plant exchanges:
- **List Plants**: Owners can showcase their plants with custom pricing
- **Secure Transactions**: Built-in STX transfers ensure trustless exchanges
- **License Verification**: Only licensed growers can participate in buying
- **Compliance Rewards**: Successful trades boost stakeholder scores

### 💰 Marketplace Functions
```clarity
(contract-call? .cannabis-tracker list-plant-for-sale u1 u1000)
(contract-call? .cannabis-tracker buy-plant u1)
```

### 🔍 Marketplace Queries
```clarity
(contract-call? .cannabis-tracker get-plant-listing u1)
```

### Data Structures
- **plant-listings**: Active sale listings with pricing and seller info

### Benefits
- 🚀 **Liquidity Boost**: Facilitates efficient resource allocation
- 🔒 **Regulatory Compliance**: Maintains license checks and ownership tracking
- 💼 **Economic Opportunities**: Opens new revenue streams for growers
- 🌐 **Decentralized Trading**: Peer-to-peer without intermediaries

#CannabisTech #BlockchainTrading #PharmaInnovation

## 💰 Compliance Token Transfers

### 🔄 Token Economy Enhancement
Introduce tradable compliance tokens to foster a dynamic incentive ecosystem:
- **Transfer Functionality**: Holders can send tokens to other principals
- **Balance Validation**: Ensures sufficient funds before transfer
- **Self-Transfer Prevention**: Blocks invalid transfers to the same account
- **Positive Amount Checks**: Enforces meaningful transaction values

### 💸 Transfer Operations
```clarity
(contract-call? .cannabis-tracker transfer-compliance-tokens 'SP2RECIPIENT u500)
```

### Benefits
- 🌟 **Market Dynamics**: Enables token trading and redistribution
- 🏆 **Incentive Flexibility**: Allows earned rewards to be shared or sold
- 🔗 **Ecosystem Growth**: Promotes broader participation and compliance
- ⚡ **Seamless Integration**: Builds directly on existing token infrastructure

#TokenEconomy #ComplianceRewards #DecentralizedFinance
