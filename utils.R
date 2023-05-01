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

# CLEAN TESLA DATA #############################################################
# Takes as input the source data from the cache directory and returns the same
# data in clean format
clean_tesla_data <- function(data) {
  require(dplyr)
  require(lubridate)
  
  df <- data %>%
    select(api_request_date,
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
    distinct()
}

# GOOGLE AUTHENTICATION ########################################################
# Function allows user to authenticate with Google Drive and Google Sheets
google_auth <- function() {
  require(googledrive)
  require(googlesheets4)
  
  drive_auth(path = Sys.getenv("GOOGLE_AUTHENTICATION_CREDENTIALS"))
  gs4_auth(token = drive_token())
}

# CREATE GOOGLE DIRECTORY ######################################################
# Function creates a new directory for this project in Google Drive. Checks
# first for presence of directory with specified name. If exists, does not 
# create a new directory.
make_gdrive_folder <- function(name, gcp) {
  require(googledrive)
  
  # Check if folder already exists (0 = FALSE, >0 = TRUE)
  dir_flg <- nrow(drive_find(name))
  
  if (dir_flg == 0) {
    drive_mkdir(name) %>% 
      drive_share_anyone() %>% 
      drive_share(
        role = "writer",
        type = "user",
        emailAddress = gcp
      )
    cat("Folder", name, "created successfully.")
  } else {
    cat("Folder", name, "already exists. No need to recreate.")
  }
}

make_gdrive_cache <- function(name, gcp) {
  require(googledrive)
  
  # Check if folder already exists (0 = FALSE, >0 = TRUE)
  dir_flg <- nrow(drive_ls(basename(name),"cache"))
  
  if (dir_flg == 0) {
    drive_mkdir(paste0(name,"/cache")) %>% 
      drive_share_anyone() %>% 
      drive_share(
        role = "writer",
        type = "user",
        emailAddress = gcp
      )
    cat("Folder", name, "created successfully.")
  } else {
    cat("Folder", name, "already exists. No need to recreate.")
  }
}

# CREATE GOOGLE SHEET ##########################################################
# Function creates a new sheet for this project in Google Drive. Checks
# first for presence of sheet with specified name. If exists, does not 
# create a new sheet
write_gdrive_cache <- function(name, path, df) {
  require(googledrive)
  require(googlesheets4)
  
  ss <- gs4_create(
    name = paste0(name,"-",gsub("\\D+","",Sys.time())),
    sheets = list(Sheet1 = df)
  ) %>% 
  drive_mv(path = as_dribble(path))
  cat("Cache file created successfully.")
}

make_gdrive_sheet <- function(name, path) {
  require(googledrive)
  
  # Check if folder already exists (0 = FALSE, >0 = TRUE)
  dir_flg <- nrow(drive_ls(basename(path),name))
  
  if (dir_flg == 0) {
    drive_create(
      name = name,
      path = as_dribble(path),
      type = "spreadsheet"
    )
    cat("Sheet", name, "created successfully.")
  } else {
    cat("Sheet", name, "already exists. No need to recreate.")
  }
}