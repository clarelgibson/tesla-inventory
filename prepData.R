# Title:        Prep Data
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-03-23

# SUMMARY ######################################################################
# This script reads data needed for Tesla Inventory project

# SETUP ########################################################################
# > Scripts ====================================================================
source("utils.R")

# > Variables ==================================================================
#cache_dir <- file.path("data", "tmp")
gdrive_dir <- "tesla-inventory"
gdrive_sheet <- "inventory"

# > Storage ====================================================================
# dir.create(
#   cache_dir,
#   recursive = TRUE
# )

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
  mutate(api_request_date = Sys.time())

# # WRITE TO TEMP CSV ##########################################################
# cache_tesla_data(data = df,
#                  dir = cache_dir)

# CLEAN DATA ###################################################################
inventory <- clean_tesla_data(df)

# EXPORT DATA TO GOOGLE DRIVE ##################################################
# > Connect to Google ==========================================================
google_auth()

# > Make project folder ========================================================
make_gdrive_folder(gdrive_dir)

# > Make google sheet file =====================================================
make_gdrive_sheet(
  name = gdrive_sheet,
  path = gdrive_dir
)

# > Store id of new file =======================================================
gdrive_sheet_id <- as_dribble(gdrive_sheet)$id

# > Append data into sheet =====================================================
sheet_append(
  ss = as_dribble(gdrive_sheet),
  data = df,
  sheet = "Sheet1"
)
