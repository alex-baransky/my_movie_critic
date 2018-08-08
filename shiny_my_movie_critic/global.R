library(shiny)
library(dplyr)
library(DT)
library(data.table)
library(shinythemes)
library(shinyWidgets)

# Load intial data table
movie_df = read.csv('./movie_df.csv', stringsAsFactors = FALSE, encoding = 'UTF-8')
# Dataframe containing just movie titles, sorted alphabetically,
# used for showing movies in datatable
just_movies = movie_df[order(movie_df$movie),] %>% 
              select(`Movie Title` = movie) %>%
              unique()
# Dataframe containing just critics
just_critics = unique(movie_df$critic)

# Filters the dataframe by movies chosen by the user
filter_movies = function(df, movie_vec){
  temp = df %>% 
    filter(movie %in% movie_vec)
  return (temp)
}

# Creates a nested list containing movie title, its assocaited score,
# critic's name, and the count of movies (of those chosen by the user)
# reviewed for a given critic
create_score_list = function(df, critic_name){
  count = 0
  i = 1
  score_list = list()
  # For every movie title in the dataframe
  for (title in unique(df$movie)){
    # If the critic reviewed the movie, add movie title and score 
    if (critic_name %in% df[df$movie == title,]$critic){
      score_list[[i]] = list(title, df[(df$movie == title) & (df$critic == critic_name),]$score[1])
      count = count + 1
    }
    else{
      score_list[[i]] = list(title, NA)
    }
    i = i + 1
  }
  return(list(critic_name, count, score_list))
}

# Creates a list of lists containing movie title, its assocaited score,
# critic name, and the count of movies (of those chosen by the user)
# reviewed for every critic
create_total_score_list = function (df, critic_vec){
  return (lapply(critic_vec, function(x) create_score_list(df, x)))
}
