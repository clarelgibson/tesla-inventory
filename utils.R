# Title:        Utils
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-04-01

# SUMMARY ######################################################################
# This script contains formulas needed to run the other scripts

# SETUP ########################################################################
get_tesla_data <- function(
    api = "https://www.tesla.com/inventory/api/v1/inventory-results",
    model = "m3",
    condition = "used",
    arrangeby = "Price",
    order = "asc",
    offset = 0) {
  
  require(glue)
  require(tibble)
  require(httr)
  require(jsonlite)
  require(dplyr)
  require(janitor)
  
  x <- '?query={{"query":{{"model":"{model}","condition":"{condition}","options":{{}},"arrangeby":"{arrange}","order":"{order}","market":"GB","language":"en","super_region":"north%20america","lng":-0.7295,"lat":51.2521,"zip":"GU12","range":0,"region":"ON"}},"offset":{offset},"count":50,"outsideOffset":0,"outsideSearch":false}}'
  df <- tibble()
  qry <- glue(
    api,
    x,
    model = model,
    condition = condition,
    arrange = arrangeby,
    order = order,
    offset = offset
  )
  
  res <- GET(qry)
  data <- fromJSON(rawToChar(res$content), flatten = TRUE)
  matches <- as.integer(data$total_matches_found) - 1
  iterations <- ceiling(matches/50)
  
  for (i in 1:iterations) {
    qry <- glue(
      api,
      x,
      model = model,
      condition = condition,
      arrange = arrangeby,
      order = order,
      offset = offset
    )
    
    res <- GET(qry)
    data <- fromJSON(rawToChar(res$content), flatten = TRUE)
    
    df <- df %>% 
      bind_rows(data$results)
    
    offset <- offset + 50
  }
  
  df <- df %>% 
    clean_names() %>% 
    mutate(
      across(
        where(is.list),
        as.character
      )
    )
}