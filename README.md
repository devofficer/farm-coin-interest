# Task

Create a smart contract which accepts USDC deposits and pays out interest in the form of a new ERC-20 that you create called FarmCoin. The interest rate should be determined by how long a user agrees to lock up their USDC deposit. If the user wishes to unlock their tokens early, they should be able to withdraw them for a 10% fee.
Functionality: 
- A contract that accepts USDC deposits and rewards the user with FarmCoins 
- If there is no lock up period, the user should earn 10% APY in FarmCoin 
- For a six month lock up, the user should earn 20% APY in FarmCoin 
- For a 1 year lock up, the user should earn 30% APY in FarmCoin 
- For example, if a user deposits 100 USDC with no lockup, their deposit should begin accruing interest immediately, at a rate of 10 FarmCoins per year. 
- If the user locks up their USDC for higher returns, they should be able to withdraw them early for a 10% fee on the original USDC deposit.
