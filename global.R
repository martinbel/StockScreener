library(TradingTools)
library(xts)
library(data.table)
library(quantmod)
library(TTR)

library(shiny)
library(DT)
library(markdown)

#library(gt)
library(glue)
library(stringi)

prop_case <- function(s) {
  trimws(stri_trans_totitle(gsub("_", " ", s)))
}

### Bonds Data
dt_bonds = readRDS('data/bonds_data.rds')
dt_bonds = dt_bonds[!is.na(price)]
dt_bonds = dt_bonds[date == max(date)]

sp_ratings = dt_bonds[, sort(unique(sp_rating))]
moodys_ratings = dt_bonds[, sort(unique(moodys_rating))]

# Clean company names
company_list = dt_bonds[, description]
company_list = trimws(gsub("[[:digit:]].*|[[:punct:]]", "", company_list))

### Price Data
# setwd("app/")
data = readRDS("data/prices.rds")
data$LOW = NULL
data$FLOW = NULL
data$PLOW = NULL

data = lapply(data, function(x){
  adjustOHLC(na.omit(x), use.Adjusted=TRUE)
})

ticker_lkp = fread("data/ticker_lkp.csv")
ticker_lkp = ticker_lkp[sector != 'Cash and/or Derivatives']

df_fund = read_fund_data("data/funddata.rds", ticker_lkp)

cols = c("rev_growth_3y", "operating_margin", "net_margin", "roa", "roe")
for(j in cols){
  set(df_fund, j=j, value=ifelse(df_fund[[j]] != 0, df_fund[[j]]/100, df_fund[[j]]))
}

### Run Screeners

run_basescreen <- function(data){
  cat("Running Base Screen\n")
  all_tickers = names(data)
  res = lapply(all_tickers, function(ticker){
    try(base_stats(data, ticker, trailing_days = 8*21), silent=T)
  })
  classes = sapply(res, function(x) class(x)[1])
  res = res[classes == "data.table"]
  res = unique(rbindlist(res))
  
  screen_cols = c("ticker", "avg_volume", "ret_period", "coef_atr", "vol_end_start")
  res[, screen_cols, with=F]
}


run_weekly_rotation <- function(data){
  cat("Running Weekly Rotation Screen\n")
  all_tickers = names(data)
  res = lapply(all_tickers, function(ticker){
    try(weekly_rotation(data, ticker, n_return = 200), silent=T)
  })
  classes = sapply(res, function(x) class(x)[1])
  res = rbindlist(res[classes == "data.table"])
  
  # Filter top-10
  res = res[rsi <= 50]     # 1. RSI lower than 50
  res = res[avg_vol > 1]   # 2. Average volume > 1MM
  res = res[order(-R_200)] # 3. Rank by R_200  
  screen_cols = names(res)
  res[, screen_cols, with=F]
}

run_mean_reversion <- function(data){
  cat("Running mean reversion Screen\n")
  all_tickers = names(data)
  res = lapply(all_tickers, function(ticker){
    try(mean_reversion(data, ticker), silent=T)
  })
  classes = sapply(res, function(x) class(x)[1])
  res = rbindlist(res[classes == "data.table"])
  
  # Filter top-10
  res = res[close >= sma150]   # 1. Long-Term Trend
  if(nrow(res[adx7 >= 45 & atr10 >= 0.04 & rsi3 <= 30]) < 5){
    res = res[atr10 >= 0.04 & rsi3 <= 30][order(rsi3)]
  } else {
    res = res[adx7 >= 45 & atr10 >= 0.04 & rsi3 <= 30][order(rsi3)]
  }
  res
}

run_long_trend_high_momentum <- function(data){
  cat("Running momentum Screen\n")
  all_tickers = names(data)
  res = lapply(all_tickers, function(ticker){
    try(long_trend_high_momentum(data, ticker, n_return = 200), silent=F)
  })
  classes = sapply(res, function(x) class(x)[1])
  res = rbindlist(res[classes == "data.table"])
  
  res = res[test_sma25_sma50 == TRUE & test_close_higher5 == TRUE & test_volume == TRUE]
  set(res, j=c("test_sma25_sma50", "test_close_higher5", "test_volume"), value=NULL)
  res = res[order(-return_200d)]
  res
}


run_long_trend_low_vol <- function(data){
  cat("Running low volatility Screen\n")
  all_tickers = names(data)
  res = lapply(all_tickers, function(ticker){
    try(long_trend_low_vol(data, ticker, n_return = 200), silent=T)
  })
  classes = sapply(res, function(x) class(x)[1])
  res = rbindlist(res[classes == "data.table"])
  # ADV >= $50MM
  res = res[close > sma200 & avg_volume >= 100 & 
              volatility %between% c(0.1, 0.4)][order(rsi4)]
  res
}

# Most recent price data
last_date_prices = as.Date(index(tail(data[['AAPL']], 1)))

# Decide to recompute screen or not
fl_screens = 'data/all_screens.rds'
screen_run_date = as.Date(file.info(fl_screens)$ctime)
diff_days = as.numeric(screen_run_date - last_date_prices)

if(diff_days > 2){
  res_base = run_basescreen(data)
  res_weekly_rotation = run_weekly_rotation(data)
  res_mean_reversion = run_mean_reversion(data)
  res_long_trend_high_momentum = run_long_trend_high_momentum(data)
  res_long_trend_low_vol = run_long_trend_low_vol(data)
  
  all_screens = list(res_base=res_base, 
                     res_weekly_rotation=res_weekly_rotation, 
                     res_mean_reversion=res_mean_reversion,
                     res_long_trend_high_momentum=res_long_trend_high_momentum,
                     res_long_trend_low_vol=res_long_trend_low_vol)
  saveRDS(all_screens, file=fl_screens)
} else {
  all_screens = readRDS(fl_screens)
}

