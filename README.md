# Words

This dApp let you to discover and save off-chain asstet to you account, and then can mint them to on-chain asset anytime. 

This architecture is great for games/fast ui apps, with ability to mint your assets on-chain on demand.

How it works under the hood:
1. Login with Metamask
2. Discover new asset and save it to database
3. Mint your asset (While minting application backend is providing signature for you saved assets and it's used to mint your NFTs) 

Demo is live here https://t3chmo.github.io/Words/

Technology stack
1. ReactJS with Chakra-ui
2. Moralis backend with Database, Cloud functions
3. Smart contract with onchain svg assets
