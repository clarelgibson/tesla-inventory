# Title:        Get Data
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-03-23

# SUMMARY ######################################################################
# This script reads data needed for Tesla Inventory project

# SETUP ########################################################################
library(readr)
library(janitor)
library(glue)
library(stringr)

source("utils.R")

# GET DATA FROM API ############################################################
api <- "https://www.tesla.com/inventory/api/v1/inventory-results"
qry <- '?query={{"query":{{"model":"m3","condition":"used","options":{{}},"arrangeby":{arrange},"order":{order},"market":"GB","language":"en","super_region":"north%20america","lng":-0.7295,"lat":51.2521,"zip":"GU12","range":0,"region":"ON"}},"offset":{offset},"count":50,"outsideOffset":0,"outsideSearch":false}}'
request_time <- Sys.time()

df_pa <- get_tesla_data()                       # price ascending
df_pd <- get_tesla_data(order = "desc")         # price descending
df_ya <- get_tesla_data(arrangeby = "Year")     # year ascending
df_yd <- get_tesla_data(arrangeby = "Year",
                        order = "desc")         # year descending
df_ma <- get_tesla_data(arrangeby = "Mileage")  # mileage ascending
df_md <- get_tesla_data(arrangeby = "Mileage",
                        order = "desc")         # mileage descending

# BIND ALL API CALLS ###########################################################
df <- df_pa %>% 
  bind_rows(df_pd) %>% 
  bind_rows(df_ya) %>% 
  bind_rows(df_yd) %>% 
  bind_rows(df_ma) %>% 
  bind_rows(df_md) %>% 
  distinct() %>% 
  mutate(request_time = request_time)

# WRITE TO TEMP CSV ############################################################
write_csv(
  x = df,
  file = paste0("./data/tmp/m3-",
                str_replace_all(as.character(Sys.time()),"\\D",""),
                ".csv"),
  append = FALSE
)