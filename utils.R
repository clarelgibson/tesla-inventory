# Title:        Utils
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-04-01

# SUMMARY ######################################################################
# This script contains formulas needed to run the other scripts

# GET TESLA DATA ###############################################################
# Runs an API call to the Tesla inventory API using given query parameters and 
# returns the results as a dataframe.
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

# BIND TESLA DATA ##############################################################
# Takes as input a list of df and binds the results into a single df, removing
# any duplicate rows and adding a timestamp.
bind_tesla_data <- function(data) {
  require(dplyr)
  
  df <- bind_rows(data) %>% 
    distinct() %>% 
    mutate(request_time = Sys.time())
}

# CACHE TESLA DATA #############################################################
# Takes as input a df and stores it in the defined cache location
cache_tesla_data <- function(data, dir) {
  require(readr)
  require(stringr)
  
  file <- paste0("/m3-",
                 str_replace_all(as.character(Sys.time()),"\\D",""),
                 ".csv")
  
  write_csv(
    x = data,
    file = paste0(dir,file),
    append = FALSE
  )
}

# STACK TESLA DATA #############################################################
# Reads all df in the cache directory and binds into single df
stack_tesla_data <- function(dir) {
  require(readr)
  
  files <- list.files(path = dir,
                      full.names = TRUE)
  
  df <- do.call(bind_rows, lapply(files, read_csv))
}

# CLEAN TESLA DATA #############################################################
# Takes as input the source data from the cache directory and returns the same
# data in clean format
clean_tesla_data <- function(data) {
  require(dplyr)
  require(lubridate)
  
  df <- data %>%
    select(api_request_date = request_time,
           vin,
           registration_plate = registration_details_license_plate_number,
           first_registration_date,
           trim_code = trim,
           original_delivery_date,
           year,
           odometer,
           price,
           inventory_price,
           purchase_price,
           total_price,
           on_configurator_price_percentage,
           acquisition_type,
           vehicle_history,
           title_status,
           city,
           cpo_refurbishment_status,
           has_damage_photos,
           paint,
           interior,
           wheels,
           warranty_battery_exp_date,
           warranty_vehicle_exp_date,
           warranty_drive_unit_exp_date,
           is_at_location,
           trt_name,
           vrl_name
    ) %>% 
    mutate(
      across(
        c(first_registration_date,
          original_delivery_date,
          warranty_battery_exp_date,
          warranty_drive_unit_exp_date,
          warranty_vehicle_exp_date),
        as_date
      )
    ) %>% 
    mutate(trim_name = case_when(
      trim_code == "PAWD" ~ "Performance",
      trim_code == "LRAWD" ~ "Long Range",
      trim_code == "M3RWD" ~ "Rear-Wheel Drive"
    )) %>% 
    mutate(vehicle_birthdate = coalesce(first_registration_date,
                                        original_delivery_date),
           vehicle_age_months = interval(vehicle_birthdate,
                                         today()) %/% months(1)) %>% 
    mutate(first_report_date = min(api_request_date),
           last_report_date = max(api_request_date)) %>% 
    group_by(vin) %>% 
    mutate(vehicle_first_report_date = min(api_request_date),
           vehicle_last_report_date = max(api_request_date)) %>% 
    slice_max(api_request_date) %>% 
    ungroup() %>% 
    mutate(is_current_inventory = if_else(
      vehicle_last_report_date < last_report_date,
      FALSE,
      TRUE
    ))
}

# EXPORT TESLA DATA ############################################################
# Takes as input the clean tesla data and exports it to the defined clean
# location
write_tesla_data <- function(data, dir, file = "/inventory.csv") {
  require(readr)
  
  write_csv(
    x = data,
    file = paste0(dir,file),
    append = FALSE,
    na = ""
  )
}