# Analysis-of-Fatal-Traffic-Accidents-in-Taiwan-Spatial-Clustering-and-Potential-Environmental-Factors
Final group report of Statistical Data Analysis, Jan 2024 @ NCKU Statistics

![Made with R](https://img.shields.io/badge/Made%20with-R-276DC3?logo=r&logoColor=white)

## 1. Background and Motivation

Traffic accidents remain a critical public safety issue in Taiwan, particularly A1-level accidents**, which are defined as incidents **causing fatalities either on-site or within 24 hours**. Understanding not only where these fatal accidents occur, but also why they cluster spatially is essential for effective policy intervention and road safety improvement.

Most existing analyses focus on descriptive statistics or regression-based approaches. However, fatal traffic accidents are inherently **spatial phenomena**, influenced by geographic context, infrastructure design, and environmental conditions. This project adopts a spatial-statistical perspective, integrating point pattern analysis with categorical variable exploration to **reveal hidden spatial structures and potential environmental drivers**.

## 2. Data Description and Preprocessing
### 2.1 Data Source

- A1 traffic accident records in Taiwan

- Coverage period: up to November 20, 2023

- Original format: police incident-based reports

### 2.2 Data Cleaning

Due to the nature of police reporting, **multiple records may correspond to the same accident event**. To address this:

- Records were deduplicated based on occurrence time and geographic location

- Each accident was assigned a unique event ID

- After filtering, 1,516 unique fatal accidents remained

### 2.3 Variable Selection

To focus on spatial and environmental characteristics:

- Variables unrelated to environment or location (e.g., cause attribution, vehicle type, casualty counts) were removed

- Redundant variables were consolidated

- Only categorical variables were retained

**The final dataset contains:**

- Geographic coordinates (longitude, latitude)

- Road environment indicators

- Weather and visibility conditions

- Traffic signal and road design attributes

No dependent variable was defined; **this study is exploratory in nature**.

## 3. Spatial Analysis Methods
### 3.1 Point Pattern Analysis

Point pattern analysis is used to determine whether accident locations exhibit **randomness, clustering, or dispersion**.

#### 3.1.1 Ripley’s K-function

Ripley’s K-function measures the expected number of additional events within a given distance of a randomly selected event.

Definition:

$$K(t)=λ^{−1}E[\text{number of additional events within distance t}]$$

Estimator:

$$K(r)=\frac{1}{n^2}\sum_{i}^{n}\sum_{j}^{n}ω(r_{ij})$$

where:

$n$ is the number of events

$r_{ij}$ is the distance between event $i$ and $j$

$\lambda$ is the event density

If the observed $K(r)$ exceeds the theoretical value under complete spatial randomness (CSR), clustering is indicated.

#### 3.1.2 G-function (Nearest Neighbor Distribution)

The G-function focuses on nearest-neighbor distances rather than all pairwise distances.

Definition:

$$
G(r)=\frac{1}{2\pi}\int_{0}^{r}K(u)du
$$

This function is more sensitive to local clustering and short-distance interactions.

### 3.1.3 Monte Carlo Simulation

To assess statistical significance:

99 Monte Carlo simulations were generated under CSR

Empirical $K$ and $G$ functions were compared against simulated envelopes

Observed curves exceeding the envelopes indicate significant clustering

### 3.2 Quadrat Analysis

The study area was divided into regular spatial grids, and the number of accidents in each cell was counted.

The Variance-to-Mean Ratio (VMR) is defined as:

$$VMR=Variance/Mean$$
​
**Statistical testing:**

$$t=\frac{VMR−1}{\frac{2}{m−1}}$$

where $m$ is the number of grid cells.

**Interpretation:**

$VMR = 1$: random distribution

$VMR > 1$: clustering

$VMR < 1$: dispersion

### 3.3 Nearest Neighbor Analysis

The Nearest Neighbor Index (R) compares observed and expected nearest-neighbor distances.

Observed mean distance:

$$r_{obs}=\frac{1}{n}\sum_{i=1}^{n}d_i$$

Expected distance under CSR:

$$
r_{exp} = \frac{1}{2\sqrt{\lambda}}
$$

Nearest Neighbor Index:

$$R=\frac{r_{obs}}{r_{exp}}$$

Z-statistic:

$$Z=\frac{r_{obs}−r_{exp}}{SE}$$

where $SE$ is the standard error.

Values of $R$ close to 0 indicate strong clustering.

### 3.4 Kernel Density Estimation (KDE)

Kernel Density Estimation produces a smooth surface representing accident intensity.

Definition:

$$f^(x,y)=\frac{1}{nh^2}\sum_{i}^{n}K(\frac{d_i(x,y)}{h})$$

where:

$h$ is the bandwidth

$K(\cdot)$ is the kernel function

$d_i(x,y)$ is the distance from event $i$ to location $(x,y)$

### 3.5 DBSCAN Clustering

DBSCAN identifies clusters based on density rather than distance thresholds.

Key parameters:

$\varepsilon$: neighborhood radius

$MinPts$: minimum number of points to form a core point

This method:

Detects arbitrarily shaped clusters

Identifies noise points

Does not require predefining the number of clusters

## 4. Environmental Variable Analysis
### 4.1 Categorical Correlation Analysis

Associations between categorical variables were measured using Cramér’s V.

Definition:

$$V=\sqrt{\frac{χ^2}{n(k−1)}}$$

where:

$\chi^2$ is the chi-square statistic

$n$ is the sample size

$k$ is the smaller dimension of the contingency table

Heatmaps were used to visualize inter-variable relationships.

### 4.2 Multiple Correspondence Analysis (MCA)

**MCA is a dimensionality reduction technique for categorical data, analogous to PCA.**

Objectives:

- Identify latent structures

- Reduce dimensionality

- Visualize category relationships

Eigenvalue analysis showed that the first five dimensions explain approximately 58% of total inertia.

Categories with high contributions include:

- Road obstacles

- Construction zones

- Wet or oily road surfaces

## 5. Results and Interpretation
### 5.1 Spatial Results

All spatial tests rejected CSR at the 0.05 significance level

<img width="1639" height="985" alt="圖片" src="https://github.com/user-attachments/assets/ef5872f7-90de-49cb-a6e6-2a44250daf57" /><img width="1639" height="985" alt="圖片" src="https://github.com/user-attachments/assets/6d2fd4c5-e7c4-48c5-bf64-fa9e7ed1ac0a" />

<img width="1639" height="985" alt="圖片" src="https://github.com/user-attachments/assets/76c8fdf8-2ef8-407b-9042-ca1d849a5ebb" />

Fatal accidents exhibit strong spatial clustering

Hotspots are concentrated in urban and densely populated regions

<img width="1639" height="985" alt="圖片" src="https://github.com/user-attachments/assets/c02337b8-22ea-4aae-87b7-e5f2e93e805a" />
<img width="1639" height="985" alt="圖片" src="https://github.com/user-attachments/assets/72ff7b8b-5651-4342-a640-aebed4ba0555" />


### 5.2 Environmental Insights

The most influential environmental factors are related to visibility degradation, including:

Physical obstructions

Road construction

Wet and slippery surfaces

Adverse weather conditions

<img width="1639" height="985" alt="圖片" src="https://github.com/user-attachments/assets/f3c86bdd-6ecc-4635-a40e-f8b252eb9309" />
<img width="1639" height="985" alt="圖片" src="https://github.com/user-attachments/assets/811548a1-3df3-4020-b8b5-68668b3421fe" />
<img width="1639" height="985" alt="圖片" src="https://github.com/user-attachments/assets/25d81a63-1939-49aa-9dec-c44581ca0ad6" />


## 6. Conclusion and Implications

This project demonstrates that fatal traffic accidents in Taiwan:

Are spatially clustered rather than randomly distributed

Are strongly influenced by **road visibility and environmental conditions**

Practical implications include:

Routine inspection and removal of road obstacles

Enhanced traffic management during construction

Improved safety measures during rainy or low-visibility conditions

## 7. Reference

溫在弘 (2021)。《空間分析:方法與應用 第二版》

Burt C. (1950) .The factorial analysis of qualitative data. British J. of Statist. psychol. 3, 3, p166-185.

Cramér, Harald. (1946). Mathematical Methods of Statistics. Princeton: Princeton University Press, page 282 (Chapter 21. The two-dimensional case).

Clark, P. J., & Evans, F. C. (1954). Distance to Nearest Neighbor as a Measure of Spatial Relationships in Populations. Ecology, 35(4), 445–453.

Guttman L. (1941) .The quantification of a class of attributes: a theory and method of a scale construction. The prediction of personal adjustment (Horst P., ed.) p 251 - 264, SSCR New York.

King, L. J. ( 1969). Statistical analysis in geography. Prentice-Hall, Englewood Cliffs, New Jersey.

Martin Ester, Hans-Peter Kriegel, Jörg Sander, and Xiaowei Xu. (1996). A density-based algorithm for discovering clusters in large spatial databases with noise. In Proceedings of the Second International Conference on Knowledge Discovery and Data Mining (KDD'96). AAAI Press, 226–231.

Parzen, E. (1962). On estimation of a probability density function and mode. The annals of mathematical statistics, 33(3), 1065-1076.

Ripley, B.D. (1976). The second-order analysis of stationary point processes, Journal of Applied Probability 13, 255–266.

Ripley, B.D. (1977). Modelling spatial patterns, Journal of the Royal Statistical Society, Series B 39, 172–192.

Rogers, A. (1969). Quadrat Analysis of Urban Dispersion: 1. Theoretical Techniques. Environment and Planning A: Economy and Space, 1(1), 47- 80.https://doi.org/10.1068/a010047

Rogers, A. (1969). Quadrat Analysis of Urban Dispersion: 2. Case Studies of Urban Retail Systems. Environment and Planning A: Economy and Space, 1(2), 155- 171. https://doi.org/10.1068/a010155

Rosenblatt, M. (1955). Remarks on some nonparametric estimates of a density function. Ann. Math. Statist. 27 832–837.

Snow, John (1855). On the Mode of Communication of Cholera (2nd ed.)
