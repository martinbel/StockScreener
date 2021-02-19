## Stock Screener

This app implements a few tools I normally use to find stocks. 

[1. Performance evaluation](https://github.com/martinbel/StockScreener/blob/master/imgs/Performance.jpeg): Select a ticker and get performance metrics in a table as output.
![image](https://user-images.githubusercontent.com/4535400/108572786-d6b80100-72f1-11eb-86cf-52d7e8009926.png)

[2. Screener](https://github.com/martinbel/StockScreener/blob/master/imgs/Screener.jpeg): Run a set of predefined screeners. It allows filtering the results using the available columns also. 
![image](https://user-images.githubusercontent.com/4535400/108572899-1aab0600-72f2-11eb-82ea-669604379bbe.png)

[3. Stop Loss](https://github.com/martinbel/StockScreener/blob/master/imgs/StopLoss.jpeg): It helps define a stop-loss based on volatility using the ATR indicator. 
![image](https://user-images.githubusercontent.com/4535400/108572822-e59eb380-72f1-11eb-9013-cc52cb0dde49.png)

[4. Bonds](https://github.com/martinbel/StockScreener/blob/master/imgs/Bonds.jpeg): Allows filtering IG and HY corporative bonds using multiple variables. 
![image](https://user-images.githubusercontent.com/4535400/108572878-0830cc80-72f2-11eb-89a9-1f15cd81b339.png)

## Data

Price data is downloaded from yahoo-finance. The stock universe is the Russel-3000 index. It's possible to expand this but might need some changes to the R code.

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
