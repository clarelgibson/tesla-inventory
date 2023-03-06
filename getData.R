# Title:        Get Data
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-03-05

# SUMMARY ######################################################################
# This script reads data needed for Tesla Inventory project

# SETUP ########################################################################
library(httr)
library(jsonlite)
library(tibble)
library(dplyr)
library(readr)
library(janitor)
library(stringr)

# GET DATA FROM API ############################################################
url <- "https://www.tesla.com/inventory/api/v1/inventory-results?query=%7B%22query%22%3A%7B%22model%22%3A%22m3%22%2C%22condition%22%3A%22used%22%2C%22options%22%3A%7B%7D%2C%22arrangeby%22%3A%22Price%22%2C%22order%22%3A%22asc%22%2C%22market%22%3A%22GB%22%2C%22language%22%3A%22en%22%2C%22super_region%22%3A%22north%20america%22%2C%22lng%22%3A-0.7295%2C%22lat%22%3A51.2521%2C%22zip%22%3A%22GU12%22%2C%22range%22%3A0%2C%22region%22%3A%22ON%22%7D%2C%22offset%22%3A0%2C%22count%22%3A50%2C%22outsideOffset%22%3A0%2C%22outsideSearch%22%3Afalse%7D"
res <- GET(url)
data <- fromJSON(rawToChar(res$content))

# APPEND DATA TO DF ############################################################
df <- data$results %>% 
  clean_names() %>% 
  mutate(request_time = Sys.time()) %>% 
  select(request_time,
         vin,
         trim_name,
         original_delivery_date,
         year,
         odometer,
         price,
         inventory_price,
         purchase_price,
         total_price,
         on_configurator_price_percentage,
         acquisition_type,
         title_status,
         title_subtype,
         city,
         cpo_refurbishment_status,
         has_damage_photos,
         paint,
         interior,
         wheels,
         warranty_battery_exp_date,
         warranty_vehicle_exp_date)

# WRITE TO TEMP CSV ############################################################
write_csv(
  x = df,
  file = paste0("./data/tmp/m3-",
                str_replace_all(as.character(Sys.time()),"\\D",""),
                ".csv"),
  append = FALSE
)