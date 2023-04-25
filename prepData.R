# Title:        Prep Data
# Project:      Tesla Inventory
# Author:       Clare Gibson
# Date Created: 2023-03-23

# SUMMARY ######################################################################
# This script reads data needed for Tesla Inventory project

# SETUP ########################################################################
# > Packages ===================================================================
library(argparse)

# > Scripts ====================================================================
source("utils.R")

# > Command Line Args ==========================================================
parser <- ArgumentParser()

parser$add_argument(
  "-b",
  "--batch",
  action="store_true",
  default=FALSE,
  dest="batch",
  help="No user prompting during execution"
)

args <- parser$parse_args()

# > Variables ==================================================================
cache_dir <- file.path("data", "tmp")
clean_dir <- file.path("data", "cln")
gdrive_dir <- "tesla-inventory"

# > Storage ====================================================================
dir.create(
  cache_dir,
  recursive = TRUE
)

if ( args$batch ) {
  dir.create(
    clean_dir,
    recursive = TRUE
  )
}

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
df <- bind_tesla_data(queries)

# WRITE TO TEMP CSV ############################################################
cache_tesla_data(data = df,
                 dir = cache_dir)

# COMBINE MULTIPLE API REQUESTS AND CLEAN ######################################
inventory.src <- stack_tesla_data(cache_dir)
inventory <- clean_tesla_data(inventory.src)

# WRITE TO CLEAN CSV ###########################################################

if ( args$batch ) {
  write_tesla_data(
    data = inventory,
    dir = clean_dir
  )
} else {
  write_tesla_sheet(
    data = inventory,
    dir = gdrive_dir
  )
}
