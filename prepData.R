# Title:        Prep Data
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-03-13

# SUMMARY ######################################################################
# This script cleans and prepares data needed for Tesla Inventory project

# SETUP ########################################################################
library(lubridate)
library(purrr)
library(tidyr)

source("getData.R")

# COMBINE MULTIPLE API REQUESTS AND CLEAN ######################################
files <- list.files(path = "./data/tmp",
                    full.names = TRUE)

inventory <- do.call(bind_rows, lapply(files, read_csv))

inventory <- inventory %>%
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

# EXPORT TO CSV ################################################################
dir.create(
  file.path("data", "cln"),
  recursive = TRUE
)

write_csv(inventory,
          file = "./data/cln/inventory.csv",
          na = "")