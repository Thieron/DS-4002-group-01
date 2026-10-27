# What Will a Home Cost Next Year? Forecasting Monthly Home Prices in Philadelphia's 19147 ZIP Code

**Group:** Lanturns, DS 4002-002
**Members:** Ethan Wang (Leader), Caroline Clippinger, Thieron Cook

## Contents of This Repository

This repository holds the data, code, and outputs for Project 2 of DS 4002. We build a monthly series of median home sale prices for Philadelphia's 19147 ZIP code from the City of Philadelphia's public Real Estate Transfers records, then fit a SARIMA model in R to the 2000–2015 data and forecast the 12 months of 2016. Our goal is a 2016 forecast with a MAPE of 10% or less, compared against a seasonal naive baseline.

- `DATA/` holds the instructions for downloading the raw data, the cleaned deed-level data, the cleaning log, the final monthly series, and the data's metadata.
- `SCRIPTS/` holds the Python notebook that cleans the data, the R script that makes the exploratory plots, and the R Markdown file that fits, checks, and evaluates the model.
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

`eda_plots.R` uses base R only. The packages below are for `sarima_analysis.Rmd`.

| Package | Version | Used for |
|---|---|---|
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
│   │                                  #   download the raw CSV
│   ├── downlaodData.png               # Screenshot showing where to download the raw CSV
│   ├── rtt_summary.csv                # Raw all-years Real Estate Transfers CSV. NOT in the
│   │                                  #   repo: you download it in Step 1 (~5.2M rows, too
│   │                                  #   large for GitHub)
│   ├── rtt_19147_clean.csv            # Written by code.ipynb: cleaned deed-level records for
│   │                                  #   ZIP 19147, 1999–2016 (1999 is dropped later, in the
│   │                                  #   model, for better performance)
│   ├── cleaning_steps_log.csv         # Written by code.ipynb: rows removed by each cleaning rule
│   └── rtt_19147_monthly.csv          # Written by code.ipynb: monthly median price and sale
│                                      #   count. This is the series the model uses.
├── SCRIPTS/
│   ├── code.ipynb                     # Step 2: cleans the raw CSV and builds the monthly series
│   ├── eda_plots.R                    # Step 3: exploratory figures (Figures 1 and 2); pulls its
│   │                                  #   own data from the city's API
│   ├── raw_19147_deeds.csv            # NOT in the repo: written when you run eda_plots.R
│   │                                  #   (its API pull of 19147 deeds, 1999–2016)
│   ├── monthly_19147.csv              # NOT in the repo: written when you run eda_plots.R
│   │                                  #   (its own monthly series, for Figure 2 only; the
│   │                                  #   model uses DATA/rtt_19147_monthly.csv)
│   ├── sarima_analysis.Rmd            # Step 4: SARIMA order selection, fitting, diagnostics,
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

Steps 2 and 4 must run in order, because the model in Step 4 reads the monthly series that Step 2 writes. Step 3 only makes the two exploratory figures. It pulls its own data from the city's API, so it can run any time after Step 1.

### Step 1: Get the code and the raw data

1. Clone this repository and open the `project2` folder:
   ```bash
   git clone https://github.com/Thieron/DS-4002-group-01.git
   cd DS-4002-group-01/project2
   ```
2. Install the software and packages listed in Section 1.
3. Download the raw Real Estate Transfers CSV. The file has about 5.2 million rows and is too large for GitHub.
   - See `DATA/data.md` for instructions.
   - Save it in the `DATA/` folder as `rtt_summary.csv`. The notebook looks for the file there under that name, so do not rename it.

### Step 2: Clean the data and build the monthly series (Python)

1. Start Jupyter from the `SCRIPTS/` folder and open `code.ipynb`:
   ```bash
   cd SCRIPTS
   jupyter notebook code.ipynb
   ```
2. Run all cells in order. Reading the full CSV can take a few minutes and a few GB of memory.
3. The notebook keeps only deeds dated January 1, 1999 through December 31, 2016 whose ZIP code starts with 19147. It then drops records with no price, records under the $10,000 price floor, same-day groups of records sharing one identical price (bulk sales), and sales more than three standard deviations from their year's mean log price. Finally it takes each month's median price and sale count, filling any empty month by linear interpolation.
4. Check that these three files now exist in `DATA/`:
   - `rtt_19147_clean.csv`, the cleaned deed-level records
   - `cleaning_steps_log.csv`, the number of rows each cleaning rule removed
   - `rtt_19147_monthly.csv`, 216 rows (January 1999 to December 2016) with the monthly median price and sale count

### Step 3: Make the exploratory figures (R)

`eda_plots.R` does not read the files from Step 2, and nothing in Step 4 reads the files it writes.

1. Open `SCRIPTS/eda_plots.R` in RStudio and click **Source**. The script uses base R only, so it needs no extra packages. When sourced from RStudio, it sets the working directory to its own folder, so every file it writes lands in `SCRIPTS/`. (Outside RStudio, run it from `SCRIPTS/` to get the same result.)
2. On its first run, the script pulls every 19147 deed dated 1999–2016 from the City of Philadelphia's Carto SQL API (the same Real Estate Transfers data), so the first run needs an internet connection. It saves the pull as `raw_19147_deeds.csv`, and later runs reuse that file. Set `REFRESH <- TRUE` at the top of the script to pull fresh data.
3. The script prints how many deeds each cleaning rule removed, builds its own monthly series, and writes these to `SCRIPTS/`:
   - `monthly_19147.csv`, its monthly median price and sale count
   - `fig1_raw_price_distribution.png` and `fig2_monthly_median.png`
4. Copy the two figures into `OUTPUT/` to match the repository.

`raw_19147_deeds.csv` and `monthly_19147.csv` are created when you run the script and are not included in the repository.

**How this script's cleaning differs from the notebook's:** it keeps only single-property deeds (`property_count == 1`), and it treats a group as a bulk sale only when 5 or more records share the same day and price (the notebook uses 2 or more). Its interpolation (`approx()`) also does not fill empty months at the very start or end of the series. Because of this, `monthly_19147.csv` and Figure 2 can differ slightly from `DATA/rtt_19147_monthly.csv`, which is the series the model uses.

### Step 4: Fit, check, and evaluate the SARIMA model (R)

1. Open `SCRIPTS/sarima_analysis.Rmd` in RStudio.
2. Click **Knit** (or run `rmarkdown::render("sarima_analysis.Rmd")` from the `SCRIPTS/` folder).
3. The R Markdown file:
   - turns `DATA/rtt_19147_monthly.csv` into a monthly time series and estimates the Box-Cox lambda to decide on a transformation;
   - splits the data into a training set (2000–2015) and a test set (2016);
   - uses an STL decomposition and an ADF test (α = 0.05) to inform the differencing orders d and D;
   - uses ACF and PACF plots of the differenced training data to choose p, q, P, and Q, and compares them with `auto.arima`;
   - fits the SARIMA model and checks its residuals (histogram, Q-Q plot, residual time plot, residuals vs. fitted, residual ACF, and a Ljung-Box test at α = 0.05);
   - forecasts the 12 months of 2016 and reports RMSE and MAPE for both the SARIMA model and a seasonal naive baseline.
4. Knitting writes `sarima_analysis.md` and its figures to `SCRIPTS/`, and saves the model figures (STL decomposition, ACF/PACF, residual plots, Q-Q plot, model comparisons, and forecast vs. observed) to `OUTPUT/`.

### Step 5: Check the results

Compare your figures in `OUTPUT/` and the RMSE and MAPE values printed in `sarima_analysis.md` with ours. `OUTPUT/Explanation.md` explains what each figure shows and whether the model met the goal of a 2016 MAPE of 10% or less.

**Our results:**
| Model | Train RMSE | Test RMSE | Train MAPE | Test MAPE |
|---|---|---|---|---|
| Manually Selected SARIMA(0,1,1)(1,0,0)[12] | 28279.53 | 27285.84 | 9.54 | 6.31 |
| Automatically Selected SARIMA(0,1,1)(2,0,0)[12] | 27436.47 | 30593.66 | 9.40 | 6.78 |
| Seasonal Naive | 42335.81 | 40275.55 | 13.72 | 9.21 |

## References

[1] City of Philadelphia, Department of Records, "Real estate transfers," OpenDataPhilly. [Online]. Available: https://opendataphilly.org/datasets/real-estate-transfers/ [Accessed Oct. 13, 2026].

[2] pandas development team, "pandas - Python Data Analysis Library," pandas, 2026. [Online]. Available: https://pandas.pydata.org/ [Accessed Oct. 15, 2026].

[3] R Core Team, "stats: The R Stats Package," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/doc/manuals/r-patched/packages/stats/refman/stats.html [Accessed Oct. 12, 2026].

[4] R. J. Hyndman et al., "forecast: Forecasting Functions for Time Series and Linear Models," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/web/packages/forecast/index.html [Accessed Oct. 12, 2026].

[5] A. Trapletti and K. Hornik, "tseries: Time Series Analysis and Computational Finance," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/web/packages/tseries/index.html [Accessed Oct. 12, 2026].

[6] H. Wickham et al., "ggplot2: Create Elegant Data Visualisations Using the Grammar of Graphics," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/web/packages/ggplot2/index.html [Accessed Oct. 20, 2026].

[7] T. L. Pedersen, "patchwork: The Composer of Plots," Comprehensive R Archive Network (CRAN). [Online]. Available: https://cran.r-project.org/web/packages/patchwork/index.html [Accessed Oct. 20, 2026].

[8] R. J. Hyndman and G. Athanasopoulos, *Forecasting: Principles and Practice*, 3rd ed. Melbourne, Australia: OTexts, 2021. [Online]. Available: https://otexts.com/fpp3/ [Accessed Oct. 12, 2026].

[9] City of Philadelphia, "Carto SQL API," City of Philadelphia. [Online]. Available: https://phl.carto.com/api/v2/sql [Accessed Oct. 27, 2026].