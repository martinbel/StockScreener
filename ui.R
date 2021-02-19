ticker_choices = names(data)
screen_choices = c("Base Pattern"="base_stats", 
                   "High-Momentum"="long_trend_high_momentum", 
                   "Low-Volatility"="long_trend_low_vol", 
                   "Weekly-Rotation"="weekly_rotation", 
                   "Mean Reversion Long"="mean_reversion")


dtquery = "ret_period < 0.1 & enterprise_value >= 10000 & rev_growth_3y > 0.1 & operating_margin > 0.1 & net_margin > 0"

# & coef_atr < -0.5 & vol_end_start < -0.001 &

shinyUI(navbarPage("Trading",
   tabPanel("Performance",
      fluidRow(
        column(3, selectInput("performance_ticker", "Ticker", ticker_choices, 
                              selected=c('ADBE', "AVGO", "MO", "UNP", "MA", "MCO", "TMO"), 
                              multiple=TRUE)),
        column(3, selectInput("performance_index", "Benchmark", c("QQQ", "SPY", "IWM"), selected=c("QQQ"))),
        column(3, textInput("performance_date_range", "Date Range", value="2015/"))
        #column(3, numericInput("stop_atr_multiple", "ATR Multiple", value=1.5, min=0.5, max=10))
      ), 
      fluidRow(
        column(6,  dataTableOutput("performance_table")),
        column(6,  plotOutput("performance_chart", height = 700))
      )
   ),
   tabPanel("Screener",
      fluidRow(
        column(3, selectInput("screen_strategy", "Screener", screen_choices, 
                              selected='base_stats', selectize=TRUE)),
        column(3, radioButtons("screen_universe", "Universe", 
                               choices=c("S&P 500"='spy', "QQQ"='qqq', "Russel-1000"='iwb', 
                                         "Russel-2000"='iwm', "Russel-3000"='all'), 
                               selected="spy")),
        column(3, textInput("screen_dtquery", "Query", value=dtquery))
      ), 
      fluidRow(
        column(6, dataTableOutput("screen_results"))
      )
   ),
   tabPanel("Stop Loss",
      fluidRow(
        column(3, selectInput("stop_ticker", "Ticker", ticker_choices, 
                              selected=c('ADBE', "AVGO", "MO", "UNP", "MA", "MCO", "TMO"), 
                              selectize=TRUE, multiple=TRUE)),
        column(3, numericInput("stop_n_days", "Number of days", value=21, min=5, max=1000, step=1)),
        column(3, numericInput("stop_atr_multiple", "ATR Multiple", value=2, min=0.5, max=10))
      ), 
      fluidRow(
        column(6, dataTableOutput("stoploss"))
      )
   ),
   tabPanel("Bonds",
      fluidRow(
        uiOutput("bonds_description_ui"),
        column(3, selectInput("bonds_sp_ratings", label = "S&P Rating", sp_ratings, 
                              selected=grep("B", sp_ratings, v=T), multiple=T)),
        column(3, selectInput("bonds_moodys_ratings", label = "Moody's Rating", moodys_ratings,
                              selected=grep("B", moodys_ratings, v=T), multiple=T)),
        column(3, textInput("bonds_dtquery", "Query", value=""))
      ),
      fluidRow(
        column(9, dataTableOutput("bonds_DT"))
      ), br(),
      fluidRow(
        column(6, dataTableOutput("bonds_stats"))
      )
))
)