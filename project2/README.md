# What Will a Home Cost Next Year? Forecasting Monthly Home Prices in Philadelphia's 19147 ZIP Code

**Group:** Lanturns, DS 4002-002
**Members:** Ethan Wang (Leader), Caroline Clippinger, Thieron Cook

## Contents of This Repository

This repository holds the data, code, and outputs for Project 2 of DS 4002. We build a monthly series of median home sale prices for Philadelphia's 19147 ZIP code from the City of Philadelphia's public Real Estate Transfers records, then fit a SARIMA model in R to the 2000–2015 data and forecast the 12 months of 2016. Our goal is a 2016 forecast with a MAPE of 10% or less, compared against a seasonal naive baseline.

- `DATA/` holds the instructions for downloading the raw data, the cleaned deed-level data, the final monthly series, and the data's metadata.
- `SCRIPTS/` holds the Python notebook that cleans the data and the R scripts that make the exploratory plots and fit, check, and evaluate the model.
- `OUTPUT/` holds every figure the scripts produce and a written explanation of the results.

## Section 1: Software and Platform

**Software**
- Python 3 (run in Jupyter Notebook) for downloading, cleaning, and aggregating the data
- R 4.5.3 (run in RStudio, or any R setup that can knit R Markdown) for exploratory plots and the SARIMA analysis

**Python packages**

| Package | Version | Used for |
|---|---|---|
| `pandas` | 2.3.2 | Reading, filtering, and aggregating the CSV |
| `numpy` | 2.3.3 | Log prices and outlier calculations |

**R packages**

| Package | Version | Used for |
|---|---|---|
| `stats` | 4.5.3 (included with R) | `ts`, `stl`, `acf`, `pacf`, `arima`, `Box.test` |
| `forecast` | 9.0.2 | `auto.arima`, `forecast`, `accuracy`, `snaive`, `checkresiduals`, `BoxCox.lambda` |
| `tseries` | 0.10.63 | `adf.test` (Augmented Dickey-Fuller test) |
| `dplyr` | 1.2.1 | Data manipulation |
| `ggplot2` | 4.0.3 | Plotting |
| `scales` | 1.4.0 | Formatting axis labels (dollar amounts, dates) |
| `patchwork` | 1.3.2 | Combining several plots into one figure |
| `here` | 1.0.2 | Building file paths from the project root |

`rmarkdown` and `knitr` are also needed to knit `sarima_analysis.Rmd`; RStudio installs them automatically.

Install them with:

```bash
pip install pandas==2.3.2 numpy==2.3.3 jupyter
```

```r
install.packages(c("forecast", "tseries", "dplyr", "ggplot2", "scales",
                   "patchwork", "here", "rmarkdown", "knitr"))
```


## Section 2: Map of Documentation

```
project2/
├── README.md                          # This file: orientation and reproduction steps
├── LICENSE.md                         # MIT License
├── DATA/
│   ├── data.md                        # Metadata: summary, provenance, license, ethics,
│   │                                  #   data dictionary, exploratory plots, and how to
│   │                                  #   download the raw CSV (too large for GitHub)
│   ├── downlaodData.png               # Screenshot showing where to download the raw CSV
│   ├── rtt_19147_clean.csv            # Cleaned deed-level records for ZIP 19147, 1999–2016 (1999 was dropped later for better preforemence)
│   └── rtt_19147_monthly.csv          # Final analyzed data: monthly median price and sale count
├── SCRIPTS/
│   ├── code.ipynb                     # Step 1: cleans the raw CSV and builds the monthly series
│   ├── eda_plots.R                    # Step 2: exploratory figures (Figures 1 and 2)
│   ├── sarima_analysis.Rmd            # Step 3: SARIMA order selection, fitting, diagnostics,
│   │                                  #   forecast, and evaluation
│   ├── sarima_analysis.md             # Knitted (GitHub-rendered) output of sarima_analysis.Rmd
│   └── sarima_analysis_files/
│       └── figure-gfm/                # Figures knitr creates for sarima_analysis.md
│           ├── unnamed-chunk-2-1.png
│           ├── unnamed-chunk-2-2.png
│           ├── unnamed-chunk-4-1.png
│           ├── unnamed-chunk-7-1.png
│           ├── unnamed-chunk-11-1.png
│           ├── unnamed-chunk-11-2.png
│           ├── unnamed-chunk-11-3.png
│           ├── unnamed-chunk-12-1.png
│           └── unnamed-chunk-15-1.png
└── OUTPUT/
    ├── Explanation.md                         # Written walkthrough of the results
    ├── fig1_raw_price_distribution.png        # Histogram/box plot of prices before cleaning
    ├── fig2_monthly_median.png                # Monthly median price series after cleaning
    ├── monthly_median_price_time_series.png   # Training series used for the model
    ├── monthly_median_price_sqrt_time_series.png  # Series after variance-stabilizing transform
    ├── stl_decomposition.png                  # Trend, seasonal, and remainder components
    ├── acf_and_pacf.png                       # ACF/PACF of the differenced training data
    ├── model_comparisons.png                  # Manual vs. auto.arima vs. grid-search models
    ├── residuals_plots.png                    # Residual time plot, ACF, and histogram
    ├── residuals_vs_fitted.png                # Standardized residuals vs. fitted values
    ├── qq_plot.png                            # Normal Q-Q plot of residuals
    └── sarima_vs_observed.png                 # 2016 SARIMA forecast vs. observed prices
```

## Section 3: Instructions for Reproducing Our Results

Run the steps in order. Each step reads files the step before it writes.

### Step 1: Get the code and the raw data

1. Clone this repository and open the `project2` folder:
   ```bash
   git clone https://github.com/Thieron/DS-4002-group-01.git
   cd DS-4002-group-01/project2
   ```
2. Install the software and packages listed in Section 1.
3. Download the raw Real Estate Transfers CSV. The file has about 5.2 million rows and is too large for GitHub.s 
    - see `DATA/data.md` for instructions
    
### Step 2: Clean the data and build the monthly series (Python)

1. Start Jupyter from the `SCRIPTS/` folder and open `code.ipynb`:
   ```bash
   cd SCRIPTS
   jupyter notebook code.ipynb
   ```
2. Run all cells in order. note Reading the full CSV can takes a few minutes and a few GB of memory.
3. The notebook keeps only deeds dated January 1, 1999 through December 31, 2016 whose ZIP code starts with 19147. It then drops records with no price, records under the $10,000 price floor, same-day groups of records sharing one identical price (bulk sales), and sales more than three standard deviations from their year's mean log price. Finally it takes each month's median price and sale count, filling any empty month by linear interpolation.
4. Check that these two files now exist in `DATA/`:
   - `rtt_19147_clean.csv`, the cleaned deed-level records
   - `rtt_19147_monthly.csv`, 216 rows (January 1999 to December 2016) with the monthly median price and sale count

### Step 3: Make the exploratory figures (R)

1. Open the R script from inside the cloned repository. The scripts use the `here` package to find files relative to the project root, so you don't need to set a working directory by hand.
2. Run `eda_plots.R`
3. This writes `fig1_raw_price_distribution.png` and `fig2_monthly_median.png` to `OUTPUT/`.

### Step 4: Fit, check, and evaluate the SARIMA model (R)

1. Open `SCRIPTS/sarima_analysis.Rmd` in RStudio.
2. Click **Knit** (or run `rmarkdown::render("sarima_analysis.Rmd")` from the `SCRIPTS/` folder).
3. The R Markdown file:
   - turns `rtt_19147_monthly.csv` into a monthly time series and estimates the Box-Cox lambda to decide on a transformation;
   - splits the data into a training set (2000–2015) and a test set (2016);
   - uses an STL decomposition and an ADF test (α = 0.05) to set the differencing orders d and D;
   - uses ACF and PACF plots of the differenced training data to choose p, q, P, and Q, and compares them with `auto.arima`;
   - fits the SARIMA model and checks its residuals (histogram, Q-Q plot, residual time plot, residuals vs. fitted, residual ACF, and a Ljung-Box test at α = 0.05);
   - forecasts the 12 months of 2016 and reports RMSE and MAPE for both the SARIMA model and a seasonal naive baseline.
4. Knitting writes `sarima_analysis.md` and its figures to `SCRIPTS/`, and saves the model figures (STL decomposition, ACF/PACF, residual plots, Q-Q plot, model comparisons, and forecast vs. observed) to `OUTPUT/`.

### Step 5: Check the results

Compare your figures in `OUTPUT/` and the RMSE and MAPE values printed in `sarima_analysis.md` with ours. `OUTPUT/Explanation.md` explains what each figure shows and whether the model met the goal of a 2016 MAPE of 10% or less.

## References

[1] City of Philadelphia, Department of Records, "Real estate transfers," OpenDataPhilly. [Online]. Available: https://opendataphilly.org/datasets/real-estate-transfers/ [Accessed Oct. 13, 2026].

[2] pandas development team, "pandas - Python Data Analysis Library," pandas, 2026. [Online]. Available: https://pandas.pydata.org/ [Accessed Oct. 15, 2026].

[3] R Core Team, "stats: The R Stats Package," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/doc/manuals/r-patched/packages/stats/refman/stats.html [Accessed Oct. 12, 2026].

[4] R. J. Hyndman et al., "forecast: Forecasting Functions for Time Series and Linear Models," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/web/packages/forecast/index.html [Accessed Oct. 12, 2026].

[5] A. Trapletti and K. Hornik, "tseries: Time Series Analysis and Computational Finance," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/web/packages/tseries/index.html [Accessed Oct. 12, 2026].

[6] H. Wickham et al., "ggplot2: Create Elegant Data Visualisations Using the Grammar of Graphics," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/web/packages/ggplot2/index.html [Accessed Oct. 20, 2026].

[7] T. L. Pedersen, "patchwork: The Composer of Plots," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/web/packages/patchwork/index.html [Accessed Oct. 20, 2026].

[8] R. J. Hyndman and G. Athanasopoulos, *Forecasting: Principles and Practice*, 3rd ed. Melbourne, Australia: OTexts, 2021. [Online]. Available: https://otexts.com/fpp3/ [Accessed Oct. 12, 2026].