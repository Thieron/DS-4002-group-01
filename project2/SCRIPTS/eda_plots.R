# Exploratory plots for DS 4002 Project 2 (19147 home prices)
#
# Makes the two exploratory figures and saves them to OUTPUT/:
#   fig1_raw_price_distribution.png  histogram + box plot of adjusted cash
#                                    consideration for 19147 deeds BEFORE cleaning
#   fig2_monthly_median.png          monthly median price AFTER cleaning
#
# Data sources:
#   Figure 1 needs the raw, uncleaned prices. It pulls every 19147 deed dated
#   1999-2016 from the City of Philadelphia's Carto SQL API (the same Real
#   Estate Transfers table as DATA/rtt_summary.csv, but only the 19147 deeds,
#   so it avoids loading the full 5.2-million-row file into R). The pull is
#   saved to DATA/raw_19147_deeds.csv and reused on later runs. No cleaning
#   is applied to it.
#   Figure 2 reads DATA/rtt_19147_monthly.csv, the series written by
#   SCRIPTS/code.ipynb. This script does NOT clean the data itself, so
#   Figure 2 shows exactly the series the SARIMA model uses.
#
# Packages: `here` (builds file paths from the repository root, as in
# sarima_analysis.Rmd). Everything else is base R.
# Run it from anywhere inside the cloned repository, e.g. open it in RStudio
# and click "Source", or run `Rscript project2/SCRIPTS/eda_plots.R`.

library(here)

REFRESH <- FALSE   # set to TRUE to re-pull fresh data from the API for Figure 1

# ---- File paths (all relative to the repository root) ---------------------
raw_csv     <- here("project2", "DATA", "raw_19147_deeds.csv")    # API pull (Figure 1)
monthly_csv <- here("project2", "DATA", "rtt_19147_monthly.csv")  # written by code.ipynb (Figure 2)
fig1_png    <- here("project2", "OUTPUT", "fig1_raw_price_distribution.png")
fig2_png    <- here("project2", "OUTPUT", "fig2_monthly_median.png")

price_floor <- 10000   # same floor code.ipynb uses; drawn on Figure 1 for reference

api_url <- "https://phl.carto.com/api/v2/sql"
query <- "SELECT document_id, document_type, document_date, zip_code,
                 property_count, adjusted_cash_consideration
          FROM rtt_summary
          WHERE document_type = 'DEED'
            AND left(zip_code, 5) = '19147'
            AND document_date >= '1999-01-01'
            AND document_date <  '2017-01-01'"

comma <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE)

# ---- 1. Pull raw deeds for Figure 1 ---------------------------------------
# Same filters as the first steps of code.ipynb: DEED documents, ZIP starting
# with 19147, dated 1999-01-01 through 2016-12-31.
if (REFRESH || !file.exists(raw_csv)) {
  cat("Pulling 19147 deeds from the City of Philadelphia API...\n")
  q <- gsub("\\s+", " ", query)
  url <- paste0(api_url, "?format=csv&q=", URLencode(q, reserved = TRUE))
  download.file(url, raw_csv, mode = "wb", quiet = TRUE)
} else {
  cat("Using saved pull:", raw_csv, "\n")
}
raw <- read.csv(raw_csv, stringsAsFactors = FALSE)
cat("Raw 19147 deeds, 1999-2016:", comma(nrow(raw)), "\n")

# ---- 2. Figure 1: price distribution before cleaning ----------------------
p <- raw$adjusted_cash_consideration[!is.na(raw$adjusted_cash_consideration)]
n_under1 <- sum(p < 1)
lp <- log10(pmax(p, 1))   # $0 deeds can't sit on a log axis; show them at $1
tick_at  <- 0:8
tick_lab <- c("$1", "$10", "$100", "$1K", "$10K", "$100K", "$1M", "$10M", "$100M")

png(fig1_png, width = 8, height = 6, units = "in", res = 200)
layout(matrix(1:2, ncol = 1), heights = c(3, 1.2))
par(mar = c(1, 5, 3, 1))
hist(lp, breaks = seq(0, 8, by = 1/6), col = "steelblue", border = "white",
     xlim = c(0, 8), xaxt = "n", xlab = "", ylab = "Number of deeds",
     main = "Adjusted cash consideration, 19147 deeds, 1999-2016 (before cleaning)")
abline(v = log10(price_floor), lty = 2)
text(log10(price_floor), par("usr")[4] * 0.92, "  $10,000 floor", adj = 0, cex = 0.8)
par(mar = c(5, 5, 0.5, 1))
boxplot(lp, horizontal = TRUE, ylim = c(0, 8), axes = FALSE, col = "gray90", pch = 20, cex = 0.4)
abline(v = log10(price_floor), lty = 2)
axis(1, at = tick_at, labels = tick_lab)
box()
title(xlab = paste0("Adjusted cash consideration (log scale; ", comma(n_under1),
                    " deeds under $1 shown at $1)"))
invisible(dev.off())
cat("Saved", fig1_png, "\n")

# ---- 3. Read the cleaned monthly series from code.ipynb -------------------
# Columns: month_year (YYYY-MM), median_price (empty months already filled by
# the notebook's linear interpolation), sale_count, interpolated (True/False).
monthly <- read.csv(monthly_csv, stringsAsFactors = FALSE)
cat("Monthly series:", nrow(monthly), "months | interpolated months:",
    paste(monthly$month_year[monthly$interpolated == "True"], collapse = ", "), "\n")

# ---- 4. Figure 2: monthly median after cleaning ---------------------------
d <- as.Date(paste0(monthly$month_year, "-01"))
png(fig2_png, width = 9, height = 4, units = "in", res = 200)
par(mar = c(4.5, 6, 3, 1))
plot(d, monthly$median_price, type = "n", xaxt = "n", yaxt = "n",
     xlim = as.Date(c("1999-01-01", "2017-01-01")),
     xlab = "Month", ylab = "",
     main = "Monthly median home sale price, 19147, Jan 1999 - Dec 2016 (after cleaning)")
rect(as.Date("2016-01-01"), par("usr")[3], as.Date("2016-12-31"), par("usr")[4],
     col = "gray88", border = NA)
grid(nx = NA, ny = NULL, col = "gray85", lty = 1)
lines(d, monthly$median_price, col = "steelblue", lwd = 1.3)
yt <- axTicks(2)
axis(2, at = yt, labels = paste0("$", yt / 1000, "K"), las = 1)
axis(1, at = as.Date(paste0(seq(2000, 2016, 2), "-01-01")), labels = seq(2000, 2016, 2))
mtext("Median adjusted cash consideration", side = 2, line = 4.5)
legend("topleft", legend = "Test set (2016)", fill = "gray88", border = NA, bty = "n")
box()
invisible(dev.off())
cat("Saved", fig2_png, "\n")
