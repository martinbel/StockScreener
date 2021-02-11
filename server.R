shinyServer(function(input, output, session) {
  
  # input=list(); input$stop_ticker=c("WMT", "COST", "AAPL", "MSFT")
  # input$performance_index = "QQQ"; input$performance_ticker = c("WMT", "COST", "AAPL", "MSFT")
  # input$performance_date_range = '2020/'
  
  ### Performance
  performance_tbl = reactive({
    perf_index = input$performance_index
    perf_ticker = input$performance_ticker
    perf_daterange = input$performance_date_range
    #data = #get_price_data(tickers, from='2005-01-01', to=Sys.Date())
    
    tickers=c(perf_index, perf_ticker)
    
    ret = list_to_returns(data[tickers])
    # head(ret, 1); cat("\n"); tail(ret, 1)
    start_dates = get_start_dates(data[tickers])
    print(start_dates)
    
    res = performance(ret, 
                      date_range=perf_daterange, 
                      tickers=c(perf_index, perf_ticker),
                      combine=setdiff(tickers, perf_index), 
                      plot=FALSE, 
                      index=perf_index)
    res
  })
  
  
  output$performance_chart <- renderPlot({
    charts.PerformanceSummary(performance_tbl()$ret_mat,
                                   main="",
                                   geometric=TRUE, 
                                   wealth.index=FALSE)
  })
  
  output$performance_table <- renderDataTable({
    tbl = performance_tbl()$tbl
    metrics = cbind(`Metric`=rownames(tbl), data.table(round(tbl, 5)))
    #gt(metrics)
    
    DT::datatable(tbl, options = list(dom = 't')) %>%
      formatRound(columns=colnames(tbl), digits=3)
  })
  
  ### Screener
  run_screener <- reactive({
    all_tickers = intersect(ticker_lkp[index == "iwb", ticker], names(data))
    
    if(input$screen_strategy == "base_stats"){
      res = lapply(all_tickers, function(ticker){
        try(base_stats(data, ticker, trailing_days = 8*21), silent=T)
      })
      classes = sapply(res, function(x) class(x)[1])
      res = res[classes == "data.table"]
      res = unique(rbindlist(res))
      
      screen_cols = c("ticker", "avg_volume", "ret_period", "coef_atr", "vol_end_start")
      res = res[, screen_cols, with=F]
      
    } else if(input$screen_strategy == "weekly_rotation"){
      res = lapply(all_tickers, function(ticker){
        weekly_rotation(data, ticker, n_return = 200)
      })
      classes = sapply(res, function(x) class(x)[1])
      res = rbindlist(res[classes == "data.table"])
      
      # Filter top-10
      res = res[rsi <= 50]     # 1. RSI lower than 50
      res = res[avg_vol > 1]   # 2. Average volume > 1MM
      res = res[order(-R_200)] # 3. Rank by R_200  
      screen_cols = names(res)
      
    } else if(input$screen_strategy == "mean_reversion"){
      res = lapply(all_tickers, function(ticker){
        mean_reversion(data, ticker)
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
      screen_cols = names(res)

    } else if(input$screen_strategy == "long_trend_high_momentum"){
      res = lapply(all_tickers, function(ticker){
        long_trend_high_momentum(data, ticker, n_return = 200)
      })
      classes = sapply(res, function(x) class(x)[1])
      res = rbindlist(res[classes == "data.table"])
      
      res = res[test_sma25_sma50 == TRUE & test_close_higher5 == TRUE & test_volume == TRUE]
      set(res, j=c("test_sma25_sma50", "test_close_higher5", "test_volume"), value=NULL)
      screen_cols = names(res)
    } else{
      res = lapply(all_tickers, function(ticker){
        long_trend_low_vol(data, ticker, n_return = 200)
      })
      classes = sapply(res, function(x) class(x)[1])
      res = rbindlist(res[classes == "data.table"])
      # ADV >= $50MM
      res = res[close > sma200 & avg_volume >= 100 & 
                  volatility %between% c(0.1, 0.4)][order(rsi4)]
      screen_cols = names(res)
    }
    
    if(class(res)[1] == "list"){
      res = res[!is.na(res)]
      res = unique(rbindlist(res))
    }
    
    list(res=res, screen_cols=screen_cols)
  })
  
  observeEvent(input$screen_strategy, {
    if(input$screen_strategy == "base_stats"){
      value = "ret_period < 0.1 & enterprise_value >= 10000 & rev_growth_3y > 0.1 & operating_margin > 0.1"
    } else {
      value = "enterprise_value >= 10000 & rev_growth_3y > 0.1 & operating_margin > 0.1"
    }
    updateTextInput(session, "screen_dtquery", "Query", value)
  })
  

  screener <- reactive({
    res = run_screener()$res
    screen_cols = run_screener()$screen_cols
    
    res = df_fund[res, on=.(ticker)]
    res[, EY:=round(1/ev_ebit, 5)]
    
    fund_cols = c("enterprise_value", "EY","rev_growth_3y", 
                  "eps_growth_3y", "operating_margin", "net_margin")
    
    dt_query = input$screen_dtquery
    res = res[eval(parse(text=dt_query))]
    res = res[, intersect(names(res), c(screen_cols, fund_cols)), wi=F]
    res
  })
  
  output$screen_results = renderDataTable({
    df_screener = screener()
    classes = sapply(df_screener, class)
    num_vars = names(classes[!(classes %in% c("character", "factor"))])

    # dom = 't',
    DT::datatable(df_screener, options = list(pageLength = 25)) %>%
      formatRound(columns=num_vars, digits=3) 
  })
  
  
  
  # Stop Loss screen
  df_stoploss = reactive({
    # Compute stop loss
    df_stop = lapply(input$stop_ticker, function(tk){
      try(atr_stoploss(data, ticker=tk, 
                       n_days=input$stop_n_days, 
                       atr_multiple=input$stop_atr_multiple), silent=TRUE)
    })
    
    classes = sapply(df_stop, function(x) class(x)[1])
    df_stop = rbindlist(df_stop[classes != 'try-error'])
    df_stop
  })
  
  
  output$stoploss = renderDataTable({
    df_stop = df_stoploss()
    df_stop = df_stop[, .(Ticker=ticker, 
                          Close=close, 
                          Stop=stop,
                          ATR=atr, 
                          `% ATR`=atr_pct)]
    
    DT::datatable(df_stop, options = list(dom = 't')) %>%
      formatRound(columns=names(df_stop)[2:4], digits=2) %>%
      formatPercentage(columns="% ATR", digits=2)
    
  })
  
  
 
  
})