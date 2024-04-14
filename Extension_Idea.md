# HE2 Project – Extension Proposal
-----


The original paper conducts an event study to estimate the causal effect of Colombian FX interventions and how effective they were at moving the Exchange Rate (COP/USD) with respect to various criteria the authors would go on to define.

Limitations:
- Sketchy methods
- Strong assumptions
- Invalid counterfactual

We propose a new, more updated and robust identification strategy to estimate the effect of FX interventions by Banrep on the Colombian Exchange Rate.

----
## Synthetic Control

We propose a synthetic control identification stategy which can be formalized as

Suppose the exchange rate of country $i$ in day $t$ is given by:  
  $$E_{i,t}$$

Furthermore, our treatment variable, which for starters we will define as a 5-day period in which Banrep either bought or sold dollars (this has to be thoroughly checked):

$$
D_{i,t} = 
\begin{cases}
1 & \text{if Banrep intervened} \\
0 & \text{otherwise}
\end{cases}
$$

Now our vector of covariables $X$ is crucial for our methodology. By picking this strategy we have to opt for variables that are able to explain a fair amount of $E_{i,t}$ variation. We propose:
$X \longrightarrow$ $i \equiv$ local interest rate (monthly);  $i^* \equiv$ USA interest rate (monthly); $\rho \equiv$ credit default swaps (daily ?); $Vix \equiv$ Volatility Index (VIX) (daily); $E_{i,t+1} \equiv$ Exchange rate expectations (monthly ?)


---
## Data
We will get our data from....

