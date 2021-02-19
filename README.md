## Stock Screener

This app implements a few tools I normally use to find stocks. 

[1. Performance evaluation](https://github.com/martinbel/StockScreener/blob/master/imgs/Performance.jpeg): Select a ticker and get performance metrics in a table as output.

[2. Screener](https://github.com/martinbel/StockScreener/blob/master/imgs/Screener.jpeg): Run a set of predefined screeners. It allows filtering the results using the available columns also. 

[3. Stop Loss](https://github.com/martinbel/StockScreener/blob/master/imgs/StopLoss.jpeg): It helps define a stop-loss based on volatility using the ATR indicator. 

[4. Bonds](https://github.com/martinbel/StockScreener/blob/master/imgs/Bonds.jpeg): Allows filtering IG and HY corporative bonds using multiple variables. 

## Data

Price data is downloaded from yahoo-finance. For my needs I use the stocks in the Russel-3000 index. 
That's often more than I need. 

The script: jobs/get_historical_prices.R downloads the data the app needs to work faster. It will save a file in data/prices.rds

Bonds data is not updated automatically. I'll try to update the data/bonds_data.rds every few weeks. It's a bit harder to get that data therefore I can't put up a script to automate it. 

## Installation

1. Download the repository and unzip it. 
2. Download and Install R
3. Download and Install RStudio
4. Install R packages needed for the app. Run the install_packages.R script.
5. Run the script: jobs/get_historical_prices.R 
This downloads the data the app needs to work faster. It will save a file in data/prices.rds
6. Open Rstudio and navigate to the StockScreener folder
7. Open the server.R file
8. Click on the small arrow next to the RunApp button (top right of RStudio) and select "run external". Then the application should open in your browser. 

## Disclosure

This content is educational. Use at your own care. 
