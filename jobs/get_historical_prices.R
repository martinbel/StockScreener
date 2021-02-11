rm(list = ls(all = TRUE)); gc()

library(quantmod)
library(data.table)
library(PerformanceAnalytics)
library(MASS)
library(magrittr)
library(httr)
library(future.apply)
plan(multicore)

# ETFs
etf_lkp = fread('data/ETFs.csv')
etf_tickers = etf_lkp[, ticker]

# Indexes
ticker_lkp = fread('data/ticker_lkp.csv')
ticker_lkp[, ticker:=ifelse(ticker == 'BRKB', "BRK-B", ticker)]

# extra companies
extra_companies = readLines("data/extra_companies.txt")

# List all tickers
tickers = c(ticker_lkp[nchar(ticker) > 0, unique(ticker)], etf_tickers)
tickers = c(tickers, extra_companies)

options("getSymbols.warning4.0"=FALSE)

# Get prices as xts
data = list()
for (i in seq_along(tickers)) {
  Sys.sleep(0.005)
  ticker = tickers[i]
  cat(i, " - ", ticker, "\n")
  from = "2005-01-01"
  to = as.character(Sys.Date())
  data[[ticker]] = try(getSymbols(ticker, from=from, to=to, auto.assign = FALSE, src='yahoo'), silent=TRUE)
}
names(data) = ticker

# Remove empty data
classes = sapply(data, function(x) class(x)[1])
data = data[which(classes != 'try-error')]
names(data) = tickers[which(classes != 'try-error')]
saveRDS(data, file="data/prices.rds")
