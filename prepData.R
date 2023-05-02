# Title:        Prep Data
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-03-23

# SUMMARY ######################################################################
# This script reads data needed for Tesla Inventory project

# SETUP ########################################################################
# > Packages
library(dplyr)
library(googledrive)

# > Scripts ====================================================================
source("utils.R")

# > Variables ==================================================================
gdrive_dir <- "tesla-inventory"
gdrive_cache <- paste0(gdrive_dir,"/cache")
gdrive_sheet <- "inventory"
gcp_service_account <- "tpa-service-account@tableau-public-autorefresh.iam.gserviceaccount.com"
timestamp <- Sys.time()

# GET DATA FROM API ############################################################
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

# BIND ALL API CALLS ###########################################################
df <- bind_tesla_data(queries) %>% 
  mutate(api_request_date = timestamp)

# CLEAN DATA ###################################################################
df.cln <- clean_tesla_data(df)

# EXPORT DATA TO GOOGLE DRIVE ##################################################
# > Connect to Google ==========================================================
google_auth()

# > Make project folder ========================================================
make_gdrive_folder(gdrive_dir,
                   gcp_service_account)

# > Make cache folder ==========================================================
make_gdrive_cache(gdrive_dir,
                  gcp_service_account)

# > Load df into Google Drive cache ============================================
write_gdrive_cache(
  name = gdrive_sheet,
  path = gdrive_cache,
  df = df.cln,
  timestamp = timestamp
)

# CLEAN INVENTORY ##############################################################
gdrive_cache_ids <- drive_ls(gdrive_cache)$id

inventory <-
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

# ADD CLEAN INVENTORY TO GOOGLE DRIVE ##########################################
# > Make sheet if required =====================================================
make_gdrive_sheet(
  name = "inventory",
  path = gdrive_dir
)

# > Append data to inventory ===================================================
inventory_id <- drive_ls(gdrive_dir, "inventory")$id

sheet_write(
  data = inventory,
  ss = inventory_id,
  sheet = "Sheet1"
)