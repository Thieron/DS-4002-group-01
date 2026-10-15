# Exploratory plots for DS 4002 Project 2 (19147 home prices)
#
# Pulls every 19147 deed dated 1999-2016 from the City of Philadelphia's
# Real Estate Transfers data (Carto SQL API), cleans it the way our MI2
# describes, and saves:
#   fig1_raw_price_distribution.png  histogram + box plot of adjusted cash
#                                    consideration BEFORE cleaning
#   fig2_monthly_median.png          monthly median price AFTER cleaning
#   raw_19147_deeds.csv              the API pull (reused on later runs)
#   monthly_19147.csv                month, median price, sale count
#
# Base R only, nothing to install. In RStudio, open this file and click "Source".

REFRESH <- FALSE   # set to TRUE to re-pull fresh data from the API

# Save outputs next to this script when run from RStudio
try(if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  p <- rstudioapi::getSourceEditorContext()$path
  if (nzchar(p)) setwd(dirname(p))
}, silent = TRUE)

api_url <- "https://phl.carto.com/api/v2/sql"
query <- "SELECT document_id, document_type, document_date, zip_code,
                 property_count, adjusted_cash_consideration
          FROM rtt_summary
          WHERE document_type = 'DEED'
            AND left(zip_code, 5) = '19147'
            AND document_date >= '1999-01-01'
            AND document_date <  '2017-01-01'"
raw_csv     <- "raw_19147_deeds.csv"
monthly_csv <- "monthly_19147.csv"
price_floor <- 10000   # nominal transfers ($1 deeds etc.) fall below this
batch_size  <- 5       # same day + same price this many times = bulk sale

comma <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE)

# ---- 1. Pull data ---------------------------------------------------------
if (REFRESH || !file.exists(raw_csv)) {
  cat("Pulling deeds from the City of Philadelphia API...\n")
  q <- gsub("\\s+", " ", query)
  url <- paste0(api_url, "?format=csv&q=", URLencode(q, reserved = TRUE))
  download.file(url, raw_csv, mode = "wb", quiet = TRUE)
} else {
  cat("Using saved pull:", raw_csv, "\n")
}
raw <- read.csv(raw_csv, stringsAsFactors = FALSE)
raw$date <- substr(raw$document_date, 1, 10)   # e.g. 2014-03-17T04:00:00Z -> 2014-03-17
raw <- raw[order(raw$date), ]
cat("Raw deeds:", comma(nrow(raw)), "\n")

# ---- 2. Figure 1: price distribution before cleaning ----------------------
p <- raw$adjusted_cash_consideration[!is.na(raw$adjusted_cash_consideration)]
n_under1 <- sum(p < 1)
lp <- log10(pmax(p, 1))   # $0 deeds can't sit on a log axis; show them at $1
tick_at  <- 0:8
tick_lab <- c("$1", "$10", "$100", "$1K", "$10K", "$100K", "$1M", "$10M", "$100M")

png("fig1_raw_price_distribution.png", width = 8, height = 6, units = "in", res = 200)
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
cat("Saved fig1_raw_price_distribution.png\n")

# ---- 3. Clean -------------------------------------------------------------
dropped <- c()
s <- raw[!is.na(raw$adjusted_cash_consideration), ]
dropped["missing price"] <- nrow(raw) - nrow(s)

n0 <- nrow(s); s <- s[s$property_count == 1, ]
dropped["multi-property deeds"] <- n0 - nrow(s)

n0 <- nrow(s); s <- s[s$adjusted_cash_consideration >= price_floor, ]
dropped[paste0("under $", comma(price_floor))] <- n0 - nrow(s)

n0 <- nrow(s)
key <- paste(s$date, s$adjusted_cash_consideration)
batch <- ave(seq_along(key), key, FUN = length)
s <- s[batch < batch_size, ]
dropped["same-day bulk batches"] <- n0 - nrow(s)

# 3 SD rule on log price, within each year (prices rose a lot over time)
n0 <- nrow(s)
s$year <- substr(s$date, 1, 4)
lps <- log10(s$adjusted_cash_consideration)
z <- (lps - ave(lps, s$year)) / ave(lps, s$year, FUN = sd)
s <- s[abs(z) <= 3, ]
dropped["over 3 SD from year's mean log price"] <- n0 - nrow(s)

for (nm in names(dropped)) cat(sprintf("  dropped %6s  %s\n", comma(dropped[[nm]]), nm))
cat("Cleaned sales:", comma(nrow(s)), "\n")

# ---- 4. Monthly series ----------------------------------------------------
s$month <- substr(s$date, 1, 7)
months <- format(seq(as.Date("1999-01-01"), as.Date("2016-12-01"), by = "month"), "%Y-%m")
med <- tapply(s$adjusted_cash_consideration, s$month, median)
cnt <- table(s$month)
monthly <- data.frame(month = months,
                      median_price = as.numeric(med[months]),
                      n_sales = as.integer(cnt[months]))
monthly$n_sales[is.na(monthly$n_sales)] <- 0L
monthly$median_price_filled <- approx(seq_along(months), monthly$median_price,
                                      xout = seq_along(months))$y
write.csv(monthly, monthly_csv, row.names = FALSE)
cat("Months:", nrow(monthly), "| months with no sales (interpolated):",
    paste(monthly$month[monthly$n_sales == 0], collapse = ", "), "\n")

# ---- 5. Figure 2: monthly median after cleaning ---------------------------
d <- as.Date(paste0(monthly$month, "-01"))
png("fig2_monthly_median.png", width = 9, height = 4, units = "in", res = 200)
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
cat("Saved fig2_monthly_median.png\n")
