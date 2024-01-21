# Facilitator Application Template

## Background
- Title of Facilitator  
*GHOptim*

- High Level Description of Mechanism / Request  
*Grants GHOptim contract FACILITATOR and BUCKET_MANAGER roles.*

- Author / Link to License  
*parseb.eth | Unlicenced *

- Link to whitepaper (if applicable)  
*-*

- How Facilitator Furthers GHO  
 -- Gives aditional moneyness to GHO as Options Cost Delta and Assets are priced using the Aave Oracle at $1 = 1 GHO
 -- Adds aditional flexible revenue option for and overall makes aTokens more attractive 
 -- Increases Token Supply, Flows and Liquidity

- Organization / DAO responsible for operation of the Facilitator (if applicable)  
*The Facilitator will operate autonomously by incentivising rebalancing triggers. Fully dependent on Aave DAO.*

- History, Details, Background of the operator of the Facilitator (if applicable)  
*-*

- Credit Line Details  
*Aave DAO should consider seeding the offering using its passive, long-term aToken threasury holdings.*

## Requested Facilitator Cap
- Cap Increase Roadmap (if applicable)  
*The Cap is self regulating and it is currently expected to be equal to the total AUM value. <br> This is done via `updateBucketCapacity` function.*

- Use of Funds  
*Funds will be managed by the AAVE DAO and will remain their bearer with the exception of a share of profit.*

- Revenue Streams  
*All Options incurr a fee. aTokens accrue interest.*

- Revenue Split / Interest Terms  
*Function `profitTake` splits the accrued profit in any given aToken, currently, like this: 69% genesis (deployment DAO), 1% triggering agent, 30% Aave DAO.*

- Collateral Posted  
*All assets are aTokens. In case of successful buys or sells by the option taker, the underlying liquidity that collateralised the minting is transfered to the Aave threasury as part of the execution of the closing logic for any given position. *

- Other Commercial Details/Considerations  
*-*

## Mechanism & Risk Details
- Detailed Description of the Facilitator  
*The facilitator mints GHO in order to hedge the risk of and substitute the need for buying and sellig the traded asset.*

- How Facilitator is backing GHO  
*By transferring position corresponding aTokens to the Aave threasury when profit-taking occurs from both the liquidity provider as well as the bearer.*

- If RWA - description of legal structure etc  
*-*

- Detail any / all risks (Oracle risk, Third-party Dependencies, Contract risk, Cross-chain, Bridging, Regulatory, etc) as well as any prevention/mitigation methods  
*Aave Oracle Risk, Aave Governance Risk, Smart Contract Risk, Reputation Risk as Aave controls (pausing etc.) can lead to losses for option bearers. There is some duration risk in case of aToken devaluation relative to GHO in case of market imbalance and improbable successful sell orders that I am not sure I yet fully understand, particularly given it is mostly externalized tot the DAO.*

## Governance Controls
- List of controls given to Aave DAO  
*Current controls. GHOptim is non-upgradable and is expected to not have any adjustable parameters. Aave DAO has full control as it mirrors Aave accepted assets and uses the same oracle. Aave DAO can pause it by suspending its GHO related roles.*

- Controls given not to Aave DAO  
*-*

- Alternative controls / roles that may be present but not set (optimistic governance? Risk Admin? SubDAO etc) + description on who can set these roles  
*Some form of dynamic profit splitting might be added.*

- Upgradability controls  
*-*

## Facilitator Code and Documentation
- Code Repository  
- https://github.com/parseb/ghoptim

- Audit Report (optional but strongly recommended)  
*Subject to deployment fund or Aave DAO initiative*

- Documentation  
*-*

- Non-technical explainer  
*You have an aRETH token. You want to sell it for at least 10.000 GHO. The price today however is 3000. So you have no problem making it available for speculation in exchange for a profit. So, you sign a `Permit` to let GHOptim transfer it as well as a contract (hash of a "loan agreement" [position struct]). In case anyone is willing to borrow it by paying the difference between the price now (Aave Oracle) and your wanted price ($7000) to trade it for, between 1day and 10 years (max cummulative duration stipulated in agreement) it will be transfered from you into the GHOptim vault. Worst case for you are two: you withdraw it, with some profit (as for it to have been transfer it had to be used at least once) or, you get in return exactly the price at which you wanted to sell. Oh, even worse: your sell price is small, your collateral is used only once, you FOMO because the market is dumping, and now have to pay lots in gas to withdraw and sell. The experience for an options buyer is the same as everywhere else.*

- License Details  
*Same as template*