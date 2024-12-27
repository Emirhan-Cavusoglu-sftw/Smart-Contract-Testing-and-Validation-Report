# Smart Contract Testing and Validation Report

## Project Members

| # | ID       | Name         | Surname     | Task                                         |
|---|----------|--------------|-------------|---------------------------------------------|
| 1 | 2102451  | Emirhan  |   Çavuşoğlu    | General Introduction, Automated Tools Review |
| 2 | 2102899  | Ahmet Tahir      |  Yıldız  | Verification and Validation Activities , Testing Plan |


---

# Automated Tools Review

## 1. Slither

### Purpose:

Slither is a static analysis tool designed specifically for Solidity-based smart contracts. It helps in identifying vulnerabilities, optimizing code, and improving the overall quality of the contract.

### Features:

- Detects security vulnerabilities such as:
  - Reentrancy
  - Integer overflow/underflow
  - Unchecked low-level calls
- Provides code optimization suggestions.
- User-friendly command-line interface (CLI).

### Advantages:

- Fast and efficient in analyzing smart contracts.
- Easy to set up and use.
- Effective for large projects with complex Solidity code.

### Limitations:

- Supports only Solidity code.
- Performs static analysis only; does not cover runtime behaviors or dynamic analysis.

### Usage:

1. **Installation:**
   ```bash
   pip install slither-analyzer
   ```
2. **Execution:** Run Slither in your project folder:
   ```bash
   slither <project-folder>
   ```
3. **Output:**
   - Provides a detailed report highlighting vulnerabilities and optimization recommendations.

### Example Results:

- **Recommendation:** Remove unused variables to improve gas efficiency.
- **Warning:** Potential reentrancy vulnerability detected in the `withdraw` function.

---

## 2. Foundry

### Purpose:

Foundry is a development framework for Ethereum smart contracts. It allows developers to write, test, and deploy contracts efficiently using Solidity and other supporting tools.

### Features:

- High-speed testing and deployment framework.
- Allows writing test cases directly in Solidity.
- Supports fuzz testing and fork testing.
- Can simulate Ethereum networks for accurate testing.

### Advantages:

- Modern and fast compared to older frameworks like Hardhat and Truffle.
- Provides flexibility by enabling direct testing in Solidity.
- Excellent for simulating edge cases and dynamic behaviors.

### Limitations:

- Steeper learning curve for new users.
- Smaller ecosystem compared to Hardhat.

### Usage:

1. **Installation:**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```
2. **Project Initialization:**
   ```bash
   forge init <project-name>
   ```
3. **Running Tests:**
   ```bash
   forge test
   ```

### Example Use Cases:

- **Fuzz Testing:** Automatically generates random inputs to test contract reliability.
- **Fork Testing:** Uses real data from Ethereum mainnet to simulate interactions and test the contract.

---

## Comparison Table

| Tool    | Purpose                             | Advantages                          | Limitations           |
| ------- | ----------------------------------- | ----------------------------------- | --------------------- |
| Slither | Static analysis for smart contracts | Fast, reliable, user-friendly       | No dynamic analysis   |
| Foundry | Testing and development framework   | Modern, fast, direct Solidity tests | Higher learning curve |

---

This review provides a comprehensive overview of Slither and Foundry, which are crucial tools for ensuring the reliability and security of Ethereum smart contracts. Next steps include selecting a smart contract for validation and testing using these tools.

---

# Verification and Validation Activities

## Selected Smart Contract: Vault Contract

### Contract Overview:

The Vault contract allows users to deposit and withdraw Ether securely. It tracks individual user balances and ensures safe fund management.

### Contract Code:

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vault {
    mapping(address => uint256) private balances;

    // Events
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
}
```

---

### Testing Plan:

#### **Functional Test Cases:**

1. **Deposit Function:**
   - Valid deposit amount increases user balance.
   - Emits the correct `Deposit` event.
2. **Withdraw Function:**
   - Valid withdrawal amount decreases user balance.
   - Emits the correct `Withdrawal` event.
   - Reverts for insufficient balance.
3. **Balance Check:**
   - Returns the correct balance for a user.

#### **Structural Tests:**

- Verify the correct mapping of balances.
- Ensure no unintended access to balances.

---
### Foundry Testing Implementation

#### Test File: `VaultTest.t.sol`

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault vault;

    function setUp() public {
        vault = new Vault();
    }

    function testDeposit() public {
        uint256 depositAmount = 1 ether;
        vm.deal(address(this), depositAmount);

        vault.deposit{value: depositAmount}();
        assertEq(vault.getBalance(), depositAmount);
    }

    function testWithdraw() public {
        uint256 depositAmount = 1 ether;
        uint256 withdrawAmount = 0.5 ether;
        vm.deal(address(this), depositAmount);

        vault.deposit{value: depositAmount}();
        vault.withdraw(withdrawAmount);

        assertEq(vault.getBalance(), depositAmount - withdrawAmount);
    }

    function testWithdrawRevert() public {
        uint256 withdrawAmount = 1 ether;

        vm.expectRevert("Insufficient balance");
        vault.withdraw(withdrawAmount);
    }
}
```

#### Running the Tests:

To run the tests, use the following command:

```bash
forge test
```

#### Expected Results:

1. **testDeposit:**

   - Ensures deposit increases balance correctly.
   - Verifies the `Deposit` event is emitted.

2. **testWithdraw:**

   - Ensures withdrawal decreases balance correctly.
   - Verifies the `Withdrawal` event is emitted.

3. **testWithdrawRevert:**

   - Confirms the contract reverts for insufficient balance.

---

### Slither Analysis Results

#### Output:

- **Version Constraint Warning:**

  - Solidity version ^0.8.13 has known severe issues:
    - VerbatimInvalidDeduplication
    - FullInlinerNonExpressionSplitArgumentEvaluationOrder
    - MissingSideEffectsOnSelectorAccess
    - StorageWriteRemovalBeforeConditionalTermination
    - AbiReencodingHeadOverflowWithStaticArrayCleanup
    - DirtyBytesArrayToStorage
    - InlineAssemblyMemorySideEffects
    - DataLocationChangeInInternalOverride
    - NestedCalldataArrayAbiReencodingSizeValidation
  - Recommendation: Upgrade to a safer Solidity version.

- **Reentrancy Warning:**

  - Found in `Vault.withdraw(uint256)` function:
    - External call: `address(msg.sender).transfer(amount)`.
    - Event emitted after the external call: `Withdrawal(msg.sender,amount)`.
  - Reference: [Slither Reentrancy Vulnerabilities](https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-4)

#### Recommendations:

1. **Update Solidity Version:**

   - Use a newer Solidity version to avoid known issues in ^0.8.13.

2. **Reentrancy Mitigation:**

   - Implement a checks-effects-interactions pattern in `withdraw` function to mitigate reentrancy risks.
