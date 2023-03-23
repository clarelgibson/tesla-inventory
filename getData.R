# Title:        Get Data
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-03-23

# SUMMARY ######################################################################
# This script reads data needed for Tesla Inventory project

# SETUP ########################################################################
library(httr)
library(jsonlite)
library(tibble)
library(dplyr)
library(readr)
library(janitor)
library(glue)

# GET DATA FROM API ############################################################
api <- "https://www.tesla.com/inventory/api/v1/inventory-results"
qry <- '?query={{"query":{{"model":"m3","condition":"used","options":{{}},"arrangeby":{arrange},"order":{order},"market":"GB","language":"en","super_region":"north%20america","lng":-0.7295,"lat":51.2521,"zip":"GU12","range":0,"region":"ON"}},"offset":{offset},"count":50,"outsideOffset":0,"outsideSearch":false}}'
request_time <- Sys.time()

# Price Ascending ==============================================================
df_pa <- tibble()
offset_pa <- 0

qry_pa <- glue(
  api,
  qry,
  arrange = '"Price"',
  order = '"asc"',
  offset = offset_pa
)

res_pa <- GET(qry_pa)
data_pa <- fromJSON(rawToChar(res_pa$content), flatten = TRUE)
matches_pa <- as.integer(data_pa$total_matches_found) - 1
iterations_pa <- ceiling(matches_pa/50)

for (i in 1:iterations_pa) {
  qry_pa <- glue(
    api,
    qry,
    arrange = '"Price"',
    order = '"asc"',
    offset = offset_pa
  )
  
  res_pa <- GET(qry_pa)
  data_pa <- fromJSON(rawToChar(res_pa$content), flatten = TRUE)
  
  df_pa <- df_pa %>% 
    bind_rows(data_pa$results)
  
  offset_pa <- offset_pa + 50
}

df_pa <- df_pa %>% 
  clean_names() %>% 
  mutate(
    across(
      where(is.list),
      as.character
    )
  ) %>% 
  mutate(request_time = request_time)

# Price Descending =============================================================
df_pd <- tibble()
offset_pd <- 0

qry_pd <- glue(
  api,
  qry,
  arrange = '"Price"',
  order = '"desc"',
  offset = offset_pd
)

res_pd <- GET(qry_pd)
data_pd <- fromJSON(rawToChar(res_pd$content), flatten = TRUE)
matches_pd <- as.integer(data_pd$total_matches_found) - 1
iterations_pd <- ceiling(matches_pd/50)

for (i in 1:iterations_pd) {
  qry_pd <- glue(
    api,
    qry,
    arrange = '"Price"',
    order = '"desc"',
    offset = offset_pd
  )
  
  res_pd <- GET(qry_pd)
  data_pd <- fromJSON(rawToChar(res_pd$content), flatten = TRUE)
  
  df_pd <- df_pd %>% 
    bind_rows(data_pd$results)
  
  offset_pd <- offset_pd + 50
}

df_pd <- df_pd %>% 
  clean_names() %>% 
  mutate(
    across(
      where(is.list),
      as.character
    )
  ) %>% 
  mutate(request_time = request_time)

# Year Ascending ===============================================================
df_ya <- tibble()
offset_ya <- 0

qry_ya <- glue(
  api,
  qry,
  arrange = '"Year"',
  order = '"asc"',
  offset = offset_ya
)

res_ya <- GET(qry_ya)
data_ya <- fromJSON(rawToChar(res_ya$content), flatten = TRUE)
matches_ya <- as.integer(data_ya$total_matches_found) - 1
iterations_ya <- ceiling(matches_ya/50)

for (i in 1:iterations_ya) {
  qry_ya <- glue(
    api,
    qry,
    arrange = '"Year"',
    order = '"asc"',
    offset = offset_ya
  )
  
  res_ya <- GET(qry_ya)
  data_ya <- fromJSON(rawToChar(res_ya$content), flatten = TRUE)
  
  df_ya <- df_ya %>% 
    bind_rows(data_ya$results)
  
  offset_ya <- offset_ya + 50
}

df_ya <- df_ya %>% 
  clean_names() %>% 
  mutate(
    across(
      where(is.list),
      as.character
    )
  ) %>% 
  mutate(request_time = request_time)

# Year Descending ==============================================================
df_yd <- tibble()
offset_yd <- 0

qry_yd <- glue(
  api,
  qry,
  arrange = '"Year"',
  order = '"desc"',
  offset = offset_yd
)

res_yd <- GET(qry_yd)
data_yd <- fromJSON(rawToChar(res_yd$content), flatten = TRUE)
matches_yd <- as.integer(data_yd$total_matches_found) - 1
iterations_yd <- ceiling(matches_yd/50)

for (i in 1:iterations_yd) {
  qry_yd <- glue(
    api,
    qry,
    arrange = '"Year"',
    order = '"desc"',
    offset = offset_yd
  )
  
  res_yd <- GET(qry_yd)
  data_yd <- fromJSON(rawToChar(res_yd$content), flatten = TRUE)
  
  df_yd <- df_yd %>% 
    bind_rows(data_yd$results)
  
  offset_yd <- offset_yd + 50
}

df_yd <- df_yd %>% 
  clean_names() %>% 
  mutate(
    across(
      where(is.list),
      as.character
    )
  ) %>% 
  mutate(request_time = request_time)

# Mileage Ascending ============================================================
df_ma <- tibble()
offset_ma <- 0

qry_ma <- glue(
  api,
  qry,
  arrange = '"Mileage"',
  order = '"asc"',
  offset = offset_ma
)

res_ma <- GET(qry_ma)
data_ma <- fromJSON(rawToChar(res_ma$content), flatten = TRUE)
matches_ma <- as.integer(data_ma$total_matches_found) - 1
iterations_ma <- ceiling(matches_ma/50)

for (i in 1:iterations_ma) {
  qry_ma <- glue(
    api,
    qry,
    arrange = '"Mileage"',
    order = '"asc"',
    offset = offset_ma
  )
  
  res_ma <- GET(qry_ma)
  data_ma <- fromJSON(rawToChar(res_ma$content), flatten = TRUE)
  
  df_ma <- df_ma %>% 
    bind_rows(data_ma$results)
  
  offset_ma <- offset_ma + 50
}

df_ma <- df_ma %>% 
  clean_names() %>% 
  mutate(
    across(
      where(is.list),
      as.character
    )
  ) %>% 
  mutate(request_time = request_time)

# Mileage Descending ===========================================================
df_md <- tibble()
offset_md <- 0

qry_md <- glue(
  api,
  qry,
  arrange = '"Mileage"',
  order = '"desc"',
  offset = offset_md
)

res_md <- GET(qry_md)
data_md <- fromJSON(rawToChar(res_md$content), flatten = TRUE)
matches_md <- as.integer(data_md$total_matches_found) - 1
iterations_md <- ceiling(matches_md/50)

for (i in 1:iterations_md) {
  qry_md <- glue(
    api,
    qry,
    arrange = '"Year"',
    order = '"desc"',
    offset = offset_md
  )
  
  res_md <- GET(qry_md)
  data_md <- fromJSON(rawToChar(res_md$content), flatten = TRUE)
  
  df_md <- df_md %>% 
    bind_rows(data_md$results)
  
  offset_md <- offset_md + 50
}

df_md <- df_md %>% 
  clean_names() %>% 
  mutate(
    across(
      where(is.list),
      as.character
    )
  ) %>% 
  mutate(request_time = request_time)


# BIND ALL API CALLS ###########################################################
df <- df_pa %>% 
  bind_rows(df_pd) %>% 
  bind_rows(df_ya) %>% 
  bind_rows(df_yd) %>% 
  bind_rows(df_ma) %>% 
  bind_rows(df_md) %>% 
  distinct()

# WRITE TO TEMP CSV ############################################################
write_csv(
  x = df,
  file = paste0("./data/tmp/m3-",
                str_replace_all(as.character(Sys.time()),"\\D",""),
                ".csv"),
  append = FALSE
)