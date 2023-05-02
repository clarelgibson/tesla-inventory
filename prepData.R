# Title:        Prep Data
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-03-23

# SUMMARY ######################################################################
# This script reads data needed for Tesla Inventory project

# SETUP ########################################################################
# > Packages
writeLines("Loading packages...")
library(dplyr)
library(googledrive)
writeLines("Packages loaded.")

# > Scripts ====================================================================
writeLines("Sourcing utils.R...")
source("utils.R")
writeLines("utils.R sourced.")

# > Variables ==================================================================
writeLines("Assigning variables...")
gdrive_dir <- "tesla-inventory"
gdrive_cache <- paste0(gdrive_dir,"/cache")
gdrive_sheet <- "inventory"
gcp_service_account <- "tpa-service-account@tableau-public-autorefresh.iam.gserviceaccount.com"
timestamp <- Sys.time()
writeLines("Variables assigned.")

# GET DATA FROM API ############################################################
writeLines("Running API queries...")
queries <- list(
  df_pa = get_tesla_data(),                       # price ascending
  df_pd = get_tesla_data(order = "desc"),         # price descending
  df_ya = get_tesla_data(arrangeby = "Year"),     # year ascending
  df_yd = get_tesla_data(arrangeby = "Year",
                          order = "desc"),        # year descending
  df_ma = get_tesla_data(arrangeby = "Mileage"),  # mileage ascending
  df_md = get_tesla_data(arrangeby = "Mileage",
                          order = "desc")         # mileage descending 
)
writeLines("API queries completed successfully.")

# BIND ALL API CALLS ###########################################################
writeLines("Binding API queries...")
df <- bind_tesla_data(queries) %>% 
  mutate(api_request_date = timestamp)
writeLines("API queries bound successfully.")

# CLEAN DATA ###################################################################
writeLines ("Cleaning API data...")
df.cln <- clean_tesla_data(df)
writeLines("API data cleaned.")

# EXPORT DATA TO GOOGLE DRIVE ##################################################
# > Connect to Google ==========================================================
writeLines("Authenticating with Google...")
google_auth()
writeLines("Google authentication complete.")

# > Make project folder ========================================================
writeLines("Making Google Drive repository folder...")
make_gdrive_folder(gdrive_dir,
                   gcp_service_account)
writeLines("Google drive repository folder step complete.")

# > Make cache folder ==========================================================
writeLines("Making Google Drive cache folder...")
make_gdrive_cache(gdrive_dir,
                  gcp_service_account)
writeLines("Google Drive cache folder step complete.")

# > Load df into Google Drive cache ============================================
writeLines("Writing data to the cache...")
write_gdrive_cache(
  name = gdrive_sheet,
  path = gdrive_cache,
  df = df.cln,
  timestamp = timestamp
)
writeLines("Cache data writing complete.")

# CLEAN INVENTORY ##############################################################
writeLines("Binding cached inventory data...")
gdrive_cache_ids <- drive_ls(gdrive_cache)$id

df.tab <-
  gdrive_cache_ids %>% 
  lapply(read_sheet) %>% 
  bind_rows() %>% 
  group_by(vin) %>%
  mutate(
    vehicle_first_report_date = min(api_request_date),
    vehicle_last_report_date = max(api_request_date)
    ) %>%
  slice_max(api_request_date) %>%
  ungroup() %>%
  mutate(
    is_current_inventory = if_else(
      vehicle_last_report_date == max(api_request_date),
      TRUE,
      FALSE
      )
    )
writeLines("Cache binding complete.")

# ADD CLEAN INVENTORY TO GOOGLE DRIVE ##########################################
# > Make sheet if required =====================================================
writeLines("Making Google Sheet for inventory data...")
make_gdrive_sheet(
  name = "inventory",
  path = gdrive_dir
)
writeLines("Google Sheet step complete.")

# > Append data to inventory ===================================================
writeLines("Writing inventory data to Google Sheet...")
inventory_id <- drive_get("inventory")$id
cat("Inventory ID is", inventory_id)

sheet_write(
  data = df.tab,
  ss = inventory_id,
  sheet = "Sheet1"
)
writeLines("Google Sheet writing complete.")