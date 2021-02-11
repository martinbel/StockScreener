## Stock Screener

This app implements a few tools I normally use to find stocks. 

[1. Performance evaluation](https://github.com/martinbel/StockScreener/blob/master/imgs/Performance.jpeg): Select a ticker and get performance metrics in a table as output.

[2. Screener](https://github.com/martinbel/StockScreener/blob/master/imgs/Screener.jpeg): Run a set of predefined screeners. It allows filtering the results using the available columns also. 

[3. Stop Loss](https://github.com/martinbel/StockScreener/blob/master/imgs/StopLoss.jpeg): It helps define a stop-loss based on volatility using the ATR indicator. 

## Data

Price data is downloaded from yahoo-finance. For my needs I use the stocks in the Russel-3000 index. 
That's often more than I need. 

The script: jobs/get_historical_prices.R downloads the data the app needs to work faster. It will save a file in data/prices.rds

## Installation

1. Download the repository and unzip it. 
2. Install R
3. Install R packages needed for the app. Run the install_packages.R script.
4. Run the script: jobs/get_historical_prices.R 
This downloads the data the app needs to work faster. It will save a file in data/prices.rds
5. Open in RStudio and click Run App. 

## Disclosure

This content is educational. Use at your own care. 
