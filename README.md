# Analyzing the Response of Investor Inflation Expectations

## 1	Introduction
TBD

## 2	Software Dependencies
*	MATLAB 2020a with the following toolboxes (Econometrics, Optimization, Financial)
*	Python 3.6 with the following toolboxes (Pandas)
*	Bloomberg Professional Services for historical data
*	MATLAB system environment with at least 5 GB of memory

## 3	Code Structure

### 3.1 	`/Code` 

All project code is stored in the `/Code` folder for generating figures and performing analysis. Refer to the headline comment string in each file for a general description of the purpose of the script in question.

* `/.../lib/` stores functions derived from academic papers or individual use to compute statistical tests or perform complex operations

### 3.2 	`/Input`

Folder for all unfiltered, raw input data for financial time series.

* `/.../options/` stores inflation option price series for USD CPI caps and floors for YoY (year-over-year) and ZC (zero-coupon)
* `/.../swaps/`  stores inflation swap price series for USD, UK (United Kingdom), EUR (Euro-Zone), and FRA (France) structures
* **tips-curve.csv** historical timeseries data of the 2y-20y U.S. TIPS, taken from the Federal Reserve
* **treasury-curve.csv** historical timeseries data of the 1y-30y U.S. Treasury, taken from the Federal Reserve
* **nakamura_steinsson_shocks.xlsx** monetary shocks series taken from Nakamura a& Steinsson's 2018 paper entitled High Frequency Identification of Monetary Non-Neutrality: The Information Effect 
* **bloomberg_economic_releases.csv** historical data of economic announcements, including forecast average, standard deviation, etc.

### 3.3 	`/Temp`

Folder for storing data files after being read and cleaned of missing/obstructed values.

* `/.../options/` stores inflation option price series for USD CPI caps and floors for YoY (year-over-year) and ZC (zero-coupon)
* **DATA.mat** price series including data from FRED, monetary shocks, and U.S. GSW rates
* **OPTIONS.mat** option price series for USD inflation options covering both YoY and ZC caps and floors  
* **PROBA.mat** 
* **SWAPS.mat** inflation swap price series for USD, UK, EUR, and FRA inflation measures 

### 3.4 	`/Output`

Folder and sub-folders are provided to store graphs and tables for forecasts, regressions, etc.

* `/.../macro_response/`
* `/.../market_implied_probability/`
* `/.../market_implied_probability_buckets/`
* `/.../regressions/` stores coefficients for changes in volatility measures regressed on macro-economic announcements. For more detailed overview of the code responsible for constructing these measures refer to macro_regress.m.

## 4	Running Code

**Data Fields that are automatically updated from HTML connections**

* [The U.S. Treasury Yield Curve: 1961 to the Present](https://www.federalreserve.gov/pubs/feds/2006/200628/200628abs.html), taken from Federal Reserve website and stored under the `treasury-curve.csv` file in the `Input` folder
* [TIPS Yield Curve and Inflation Compensation](https://www.federalreserve.gov/data/tips-yield-curve-and-inflation-compensation.htm), taken from Federal Reserve website and stored under the `tips-curve.csv` file in the `Input` folder

**Data Fields that are manually updated by the user**

1. Login into your Bloomberg Professional Service account, you will need it to retrieve historical data. 
2. Open the `/Input/options/..` file and systematically update each spreadsheet with the latest price series as follows - go to the Bloomberg tab on Excel and click the **Refresh Worksheets** icon to update the Bloomberg formulas. *Note if working on a separate server or cluster, these refreshed worksheets will need to be transferred to the designated workstation*
3. Repeat Step 2 (above) for the files within the `/Input/swaps` folder
4. To update the data series entitled `bloomberg_economic_releases.csv`, refer this [repo](https://github.com/raj-rao-rr/BBG-ECO-EXCEL). Simply transfer the `Output` series from the BBG-ECO-EXCEL project to the `Input` folder of this repo. 
5. Download the updated [Nakamura and Steinsson (2018)](http://www.columbia.edu/~jma2241/replication/NS.xlsx) shocks from Miguel Acosta's website. In future this link may change so refer to [Emi Nakamura](https://eml.berkeley.edu/~enakamura/papers.html) personal website for further details. 

Prior to runing the `main.m` file we will need to modify a few paths to point the directory to the correct python compiler on your machine. 

1. In the `data_gather.m` file, modify the paths on line [INSERT LINE NUMBER] expressed path is of the form [compiler path] -b [script path]
```
% e.g. compiler path with accompanying script path for the python file in lib (i.e., library) folder
!/apps/Anaconda3-2019.03/bin/python -b '/home/../../../../Code/lib/option_remapping.py'
```

2. Once all data has been updated, and paths are set, you are free to run the entire project base. You may opt to run the main.m file in a MATLAB interactive session or via terminal on your local machine or HPC cluster.
```
% %    e.g., running code via batch on the FRBNY RAN HPC Cluster
$ matlab20a-batch-withemail 5 main.m 
```

## 5	Possible Extensions

* TBD

## 6	Contributors
* [Rajesh Rao](https://github.com/raj-rao-rr) (Sr. Research Analyst)
