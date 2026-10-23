# Output Visualization Explanations
This file explains each figure in `OUTPUT/`. The model is trained on monthly median sale prices from 2000 to 2015 and tested on 2016.

# Exploratory Data Visualizations
![Raw Price Distribution](fig1_raw_price_distribution.png)

**Figure 1.** Histogram and box plot of adjusted cash consideration for 19147 deeds, 1999–2016, before cleaning, on a log scale. Most prices fall between 100K and 1M (real sales), but there is a separate cluster at 1 or less (nominal transfers, such as tax-exempt family transfers). The dashed 10,000 floor sits in the gap between the two and removes these non-sales.

![Monthly Median After Cleaning](fig2_monthly_median.png)

**Figure 2.** Monthly median sale price after cleaning, 1999–2016; the shaded year (2016) is the test set. The series shows an upward trend, a yearly seasonal cycle, and very jagged values in 1999, when the city's records contain only a few deeds per month. Because of that, the model starts in 2000.

# Initial Time-Series Visualizations
![Price Time Series](monthly_median_price_time_series.png)

The original price series from 2000 to 2016. The size of the peaks and valleys changes over time (non-constant variance), which SARIMA does not allow, so a transformation is needed.

![Square Root Price Time Series](monthly_median_price_sqrt_time_series.png)

The price series after a square root transformation. A Box-Cox test gave λ = 0.416, which is closest to 0.5 (a square root), so we used a square root transformation to stabilize the variance. The swings are more even afterward, and all later modeling uses this series.

# Parameter-related Visualizations
## STL Decomposition
![STL Decomposition](stl_decomposition.png)

An STL decomposition splits the series into a trend, a seasonal pattern, and the remainder (leftover noise). It was done on the square-root-transformed data.
- **Data (row 1):** The level shifts over time, so the series is likely not stationary.
- **Trend (row 2):** A long-term upward trend suggests d = 1.
- **Seasonal (row 3):** A repeating yearly pattern suggests D = 1. Because the pattern is small, our final model uses D = 0 and models the seasonality with a seasonal AR term instead.
- **Remainder (row 4):** The noise looks random, so outliers are not a concern.

## ACF and PACF Plots
![ACF and PACF](acf_and_pacf.png)

Both plots use the differenced training data. Spikes that cross the dashed bands are significant.

**ACF Plot (left):** The ACF shows how strongly the series correlates with its own past values at each lag. The last significant early lag is lag 1, suggesting q = 1. The small positive spike at lag 12 suggests P = 1 and Q = 0. Because the spike is small, these could be flipped, but P and Q are each between 0 and 1.

**PACF Plot (right):** The PACF shows the direct correlation with each lag after removing the effect of shorter lags. The last significant lag is lag 2, suggesting p = 2. However, the PACF tails off while the ACF cuts off after lag 1, which suggests p = 0. We chose p = 0 for the manual model because the simpler model is less likely to overfit.

This gave the manual model **SARIMA(0,1,1)(1,0,0)[12]**. `auto.arima` chose **SARIMA(0,1,1)(2,0,0)[12]**, which agrees on every setting except P, supporting our choices.

# Model Diagnostic Plots
## Residual Time Plot (top), ACF of Residuals (left), Histogram of Residuals (right)
![Core Residuals Plots](residuals_plots.png)

**Residuals vs. Time (Top):** Checks homoscedasticity. The residuals form a roughly rectangular band around zero with consistent spikes, so there is no violation.

**ACF of Residuals (Left):** Checks for autocorrelation. Two spikes are significant, but a Ljung-Box test gave a p-value of 0.157 (> 0.05), so we fail to reject the null hypothesis that the residuals are not autocorrelated. The residuals behave like white noise.

**Histogram of Residuals (Right):** Checks normality. The residuals are roughly bell-shaped and centered on zero; we confirm this with the Q-Q plot below.

## Q-Q Plot
![Q-Q Plot](qq_plot.png)

The residuals hug the reference line, so they are approximately normally distributed.

## Standardized Residuals vs. Fitted Values
![Standardized Residuals vs. Fitted Values](residuals_vs_fitted.png)

The residuals form a rectangular band instead of fanning out, confirming homoscedasticity. The fitted line has no U-shape, so we can assume linearity.

# Forecast Plots
## Manual Model Forecast vs. Observed
![Manual SARIMA Forecast](sarima_vs_observed.png)

The SARIMA(0,1,1)(1,0,0)[12] model's 12-month forecast for 2016 compared with the observed 2016 prices. The 2016 data was not used to fit the model.

## All Model Comparisons
![Model Comparisons](model_comparisons.png)

This plot shows how the manually selected SARIMA(0,1,1)(1,0,0)[12] model's 12-month horizon forecast compares with the automatically selected SARIMA(0,1,1)(2,0,0)[12] model and the seasonal naive model, which forecasts to be equal to the actual observed value from the last corresponding season (from 2015). These are all compared to the observed values for that 12-month horizon (2016). Overall, the automatic model tends to overestimate actual prices, and the seasonal naive is unstable, frequently underestimating.