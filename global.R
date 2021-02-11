library(TradingTools)
library(xts)
library(data.table)
library(quantmod)
library(TTR)

library(shiny)
library(DT)
library(markdown)

library(gt)
library(glue)

# setwd("app/")
data = readRDS("data/prices.rds")
data$LOW = NULL
data$FLOW = NULL
data$PLOW = NULL

data = lapply(data, function(x){
  adjustOHLC(na.omit(x), use.Adjusted=TRUE)
})

ticker_lkp = fread("data/ticker_lkp.csv")
df_fund = read_fund_data("data/funddata.rds", ticker_lkp)

cols = c("rev_growth_3y", "operating_margin", "net_margin", "roa", "roe")
for(j in cols){
  set(df_fund, j=j, value=ifelse(df_fund[[j]] != 0, df_fund[[j]]/100, df_fund[[j]]))
}
