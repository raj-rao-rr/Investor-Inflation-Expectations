# Analyzing the Response of Investor Inflation Expectations

## 1	Introduction
The primary function of this project is to construct measures of inflation expectations from USD inflation options (i.e., caps and floors). We construct implied probability density measures from option butterflies and perform regression analysis examining the response of these expectations to changes in FOMC signaling and macroeconomic announcements.

## 2	Software Dependencies
*	MATLAB 2020a with the following toolboxes (Econometrics, Optimization, Financial)
*	Python 3.6 with the following toolboxes (Pandas)
*	Bloomberg Professional Services for historical data
*	MATLAB system environment with at least 5 GB of memory

## 3	Code Structure

### 3.1 	`/Code` 

All project code is stored in the `/Code` folder for generating figures and performing analysis. Refer to the headline comment string in each file for a general description of the purpose of the script in question.

* `/.../lib/` stores functions derived from academic papers or individual use to compute statistical tests or perform complex operations. Please refer to the in function documentation for each `.m` function for granular detail on function arguments and returns. 
  
  * `cusip_generator.py` this file is preserved in the code library, but is not run when calling the `main.m` file. This scipt was used to develop the Excel files within the options folder and **SHOULD NOT** be run unless those files are missing or have been deleted.  

### 3.2 	`/Input`

Folder for all unfiltered, raw input data for financial time series.

* `/.../options/` stores inflation option price series for USD CPI caps and floors for YoY (year-over-year) and ZC (zero-coupon)
* `/.../swaps/`  stores inflation swap price series for USD, UK (United Kingdom), EUR (Euro-Zone), and FRA (France) structures
* ***tips-curve.csv*** historical timeseries data of the 2y-20y U.S. TIPS, taken from the Federal Reserve
* ***treasury-curve.csv*** historical timeseries data of the 1y-30y U.S. Treasury, taken from the Federal Reserve
* ***nakamura_steinsson_shocks.xlsx*** monetary shocks series taken from Nakamura a& Steinsson's 2018 paper entitled High Frequency Identification of Monetary Non-Neutrality: The Information Effect 
* ***bloomberg_economic_releases.csv*** historical data of economic announcements, including forecast average, standard deviation, etc.

### 3.3 	`/Temp`

Folder for storing data files after being read and cleaned of missing/obstructed values.

* `/.../options/` stores inflation option price series for USD CPI caps and floors for YoY (year-over-year) and ZC (zero-coupon)
* `DATA.mat` price series including data from FRED, monetary shocks, and U.S. GSW rates
* `OPTIONS.mat` option price series for USD inflation options covering both YoY and ZC caps and floors  
* `PROBA.mat` inflation probabilibies for options tenors (1-30y)
* `SWAPS.mat` inflation swap price series for USD, UK, EUR, and FRA inflation measures 

### 3.4 	`/Output`

Folder and sub-folders are provided to store graphs and tables for forecasts, regressions, etc.

* `/.../macro_response/` stores png images displaying the price effect that various macro-economic annoucements have on the inflation basis, we observe both the cummulative and the absolute change in the return series  
* `/.../market_implied_probability/` stores csv files with the implied inflation probabilites constructured from integer [butterfly-spreads](https://www.investopedia.com/terms/b/butterflyspread.asp#:~:text=A%20butterfly%20spread%20is%20an,move%20prior%20to%20option%20expiration.) as well as a smoothed cubic spline fit
* `/.../market_implied_probability_buckets/` stores png images of the implied inflation rate and implied inflation probabilites for particular rates (e.g. probability of inflation being 3% or higher)
* `/.../regressions/` stores coefficients for changes in volatility measures regressed on macro-economic announcements. For more detailed overview of the code responsible for constructing these measures refer to macro_regress.m.

## 4	Running Code

**Data Fields that are automatically updated from HTML connections**

* [The U.S. Treasury Yield Curve: 1961 to the Present](https://www.federalreserve.gov/pubs/feds/2006/200628/200628abs.html), taken from Federal Reserve website and stored under the `treasury-curve.csv` file in the `Input` folder
* [TIPS Yield Curve and Inflation Compensation](https://www.federalreserve.gov/data/tips-yield-curve-and-inflation-compensation.htm), taken from Federal Reserve website and stored under the `tips-curve.csv` file in the `Input` folder
* [Swanson's FOMC](http://www.socsci.uci.edu/~swanson2/papers/pre-and-post-ZLB-factors-extended.xlsx) shock series, taken from his [website](http://www.socsci.uci.edu/~swanson2/) under his published paper, “Measuring the Effects of Federal Reserve Forward Guidance and Asset Purchases on Financial Markets”  

**Data Fields that are manually updated by the user**

1. Login into your Bloomberg Professional Service account, you will need it to retrieve historical data. 
2. Open the `/Input/options/..` file and systematically update each spreadsheet with the latest price series as follows - go to the Bloomberg tab on Excel and click the **Refresh Worksheets** icon to update the Bloomberg formulas. *Note if working on a separate server or cluster, these refreshed worksheets will need to be transferred to the designated workstation*
3. Repeat Step 2 (above) for the files within the `/Input/swaps` folder (these store international inflation swaps prices)
4. To update the data series entitled `bloomberg_economic_releases.csv`, refer this [repo](https://github.com/raj-rao-rr/BBG-ECO-EXCEL). Simply transfer the `Output` series from the BBG-ECO-EXCEL project to the `Input` folder of this repo. 
5. Download the updated [Nakamura and Steinsson (2018)](http://www.columbia.edu/~jma2241/replication/NS.xlsx) shocks from Miguel Acosta's website and rename the file as **nakamura_steinsson_shocks.xlsx**. In future this link may change so refer to [Emi Nakamura](https://eml.berkeley.edu/~enakamura/papers.html) personal website for further details. 

Prior to runing the `main.m` file we will need to modify a few paths to point the directory to the correct python compiler on your machine. 

1. You may opt to run the `main.m` file in a MATLAB interactive session or via terminal on your local machine or HPC cluster.
```
%% e.g. running code via batch on the FRBNY RAN HPC Cluster
$ matlab20a-batch-withemail 5 main.m 
```

## 5	Possible Extensions

* TBD

## 6	Contributors
* [Rajesh Rao](https://github.com/raj-rao-rr) (Sr. Research Analyst)
