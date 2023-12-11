# load packages ----------------------------------------------------------------
suppressWarnings(suppressMessages(library(shiny)))
suppressWarnings(suppressMessages(library(DT)))
suppressWarnings(suppressMessages(library(readxl)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(plotly)))
suppressWarnings(suppressMessages(library(shinyjs)))
suppressWarnings(suppressMessages(library(lubridate)))
suppressWarnings(suppressMessages(library(scales)))
suppressWarnings(suppressMessages(library(echarts4r)))
suppressWarnings(suppressMessages(library(shinyWidgets)))
suppressWarnings(suppressMessages(library(stringr)))
suppressWarnings(suppressMessages(library(tidyr)))

# load functions ---------------------------------------------------------------
source("functions/custom_functions.R")

# load data into global environment --------------------------------------------
data <- read_excel('data/Supplementary_Table_3_list_of_included_publications.xlsx', skip = 1)

version_vep_finder <- '1.0.6'

top_variation_types <- get_data_chart_topVariantTypes(data)
included_publications_not_1_1 <- get_data_chart_vepPlot(data)
included_publications <- get_data_chart_vepYears(data)
top_consequences <- get_data_topFunctionalImpacts(data)
