ticker_choices = names(data)
screen_choices = c("base_stats", "long_trend_high_momentum", 
                   "long_trend_low_vol", "weekly_rotation", "mean_reversion")


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
        column(6, textInput("screen_dtquery", "Query", value=dtquery))
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
   )
))



# column(2, radioButtons("fl_standardize", "Stz", c(TRUE, FALSE), selected=TRUE)),
# column(2, radioButtons("roll_join", "Roll", c(TRUE, FALSE), selected=TRUE)),
# column(2, selectInput("variable1", "Variable 1", numeric_variables, selected='eps_1y')),
# column(2, selectInput("variable2", "Variable 2", numeric_variables, selected='dividend')),
# uiOutput("ui_year")