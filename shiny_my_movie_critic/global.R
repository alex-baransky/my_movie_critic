library(shiny)
library(dplyr)
library(DT)
library(data.table)
library(shinythemes)
library(shinyWidgets)

# load intial data table
movie_df = read.csv('./movie_df.csv', stringsAsFactors = FALSE)
# data table containing just movie titles, sorted alphabetically
just_movies = movie_df[order(movie_df$movie),] %>% 
              select(`Movie Title` = movie) %>%
              unique()