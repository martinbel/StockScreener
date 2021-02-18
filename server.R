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
    #all_tickers = intersect(ticker_lkp[index == "iwb", ticker], names(data))
    
    if(input$screen_strategy == "base_stats"){
      res = copy(all_screens[['res_base']])
    } else if(input$screen_strategy == "weekly_rotation"){
      res = copy(all_screens[['res_weekly_rotation']])
    } else if(input$screen_strategy == "mean_reversion"){
      res = copy(all_screens[['res_mean_reversion']])
    } else if(input$screen_strategy == "long_trend_high_momentum"){
      res = copy(all_screens[['res_long_trend_high_momentum']])
    } else{
      res = copy(all_screens[['res_long_trend_low_vol']])
    }
    screen_cols = names(res)
    
    list(res=res, screen_cols=screen_cols)
  })
  
  observeEvent(input$screen_strategy, {
    if(input$screen_universe %in% c("all", "iwb")){
      query_enterprise_value = "enterprise_value >= 1000"
    } else {
      query_enterprise_value = "enterprise_value >= 10000"
    }
    
    if(input$screen_strategy == "base_stats"){
      value = sprintf("%s & rev_growth_3y > 0.1 & operating_margin > 0.1 & ret_period < 0.1", query_enterprise_value)
    } else {
      value = sprintf("%s & rev_growth_3y > 0.1 & operating_margin > 0.1", query_enterprise_value)
    }
    updateTextInput(session, "screen_dtquery", "Query", value)
  })
  

  screener <- reactive({
    res = run_screener()$res
    screen_cols = run_screener()$screen_cols
    
    # Filter stocks based on index
    if(input$screen_universe != "all"){
      keep_tickers = ticker_lkp[index %in% input$screen_universe, ticker]
      res = res[ticker %in% keep_tickers]
    }
    
    # Join with fundamental data - keep order
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