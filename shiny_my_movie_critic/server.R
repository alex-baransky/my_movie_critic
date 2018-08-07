function(input, output, session) {
  
  # Creates vector of user selected movies
  movie_vec = reactive({
    return(c(input$movie1, input$movie2, input$movie3, input$movie4, input$movie5))
  })
  
  # Creates vector of user selected ratings
  score_vec = reactive({
    return(c(as.numeric(input$rating1)/10, as.numeric(input$rating2)/10, as.numeric(input$rating3)/10, as.numeric(input$rating4)/10, as.numeric(input$rating5)/10))
  })
  
  # Performs a number of opertaions to create a critic match dataframe
  critic_match_df = reactive({
    # Creates a dataframe that includes observations of only the five movies chosen by the user
    my_movies = filter_movies(movie_df, movie_vec())
    # See funtion in global.R
    total_scores = create_total_score_list(my_movies, just_critics)
    
    # Creates column vectors for critic names, count of user movies reviewed, and movies scores based
    # on data in total_scores
    critic_col = character()
    org_col = character()
    count_col = numeric()
    movie1_col = numeric()
    movie2_col = numeric()
    movie3_col = numeric()
    movie4_col = numeric()
    movie5_col = numeric()
    
    for (i in 1:length(total_scores)){
      critic_col = c(critic_col, total_scores[[i]][[1]])
      count_col = c(count_col, total_scores[[i]][[2]])
      movie1_col = c(movie1_col, total_scores[[i]][[3]][[1]][[2]])
      movie2_col = c(movie2_col, total_scores[[i]][[3]][[2]][[2]])
      movie3_col = c(movie3_col, total_scores[[i]][[3]][[3]][[2]])
      movie4_col = c(movie4_col, total_scores[[i]][[3]][[4]][[2]])
      movie5_col = c(movie5_col, total_scores[[i]][[3]][[5]][[2]])
    }
    # Creates org column vector to display critic associated orgs
    for (name in just_critics){
      org_col = c(org_col, paste(unique(filter(movie_df, critic == name)$org), collapse = '|'))
    }
    # Creates a dataframe using columns above
    critic_df = data.frame(critic = critic_col, orgs = org_col, user_movies_reviewed = count_col, movie1 = movie1_col,
                           movie2 = movie2_col, movie3 = movie3_col, movie4 = movie4_col,
                           movie5 = movie5_col)
    # Filters above dataframe by user movies reviewed = 5, finds difference in user and critic scores,
    # and sums them up to show total distance between all user and critic scores. Then returns lowest 5 sums.
    usermovies5 = critic_df %>%
      filter(user_movies_reviewed == 5) %>% 
      mutate(movie1_diff = abs(score_vec()[1] - movie1)*10, movie2_diff = abs(score_vec()[2] - movie2)*10,
             movie3_diff = abs(score_vec()[3] - movie3)*10, movie4_diff = abs(score_vec()[4] - movie4)*10,
             movie5_diff = abs(score_vec()[5] - movie5)*10) %>%
      rowwise() %>% 
      mutate(diff_sum = sum(movie1_diff, movie2_diff, movie3_diff, movie4_diff, movie5_diff, na.rm = TRUE)) %>% 
      select(critic, orgs, user_movies_reviewed, diff_sum) %>%
      as.data.table() %>% 
      top_n(-5, diff_sum)
    # Does the same as above except for user movies reviewed = 4 
    usermovies4 = critic_df %>%
      filter(user_movies_reviewed == 4) %>% 
      mutate(movie1_diff = abs(score_vec()[1] - movie1)*10, movie2_diff = abs(score_vec()[2] - movie2)*10,
             movie3_diff = abs(score_vec()[3] - movie3)*10, movie4_diff = abs(score_vec()[4] - movie4)*10,
             movie5_diff = abs(score_vec()[5] - movie5)*10) %>%
      rowwise() %>% 
      mutate(diff_sum = sum(movie1_diff, movie2_diff, movie3_diff, movie4_diff, movie5_diff, na.rm = TRUE)) %>% 
      select(critic, orgs, user_movies_reviewed, diff_sum) %>%
      as.data.table() %>% 
      top_n(-5, diff_sum)
    # Does the same as above except for user movies reviewed = 3
    usermovies3 = critic_df %>%
      filter(user_movies_reviewed == 3) %>% 
      mutate(movie1_diff = abs(score_vec()[1] - movie1)*10, movie2_diff = abs(score_vec()[2] - movie2)*10,
             movie3_diff = abs(score_vec()[3] - movie3)*10, movie4_diff = abs(score_vec()[4] - movie4)*10,
             movie5_diff = abs(score_vec()[5] - movie5)*10) %>%
      rowwise() %>% 
      mutate(diff_sum = sum(movie1_diff, movie2_diff, movie3_diff, movie4_diff, movie5_diff, na.rm = TRUE)) %>% 
      select(critic, orgs, user_movies_reviewed, diff_sum) %>%
      as.data.table() %>% 
      top_n(-5, diff_sum)
    
    # Combines the above 3 dataframes
    critic_match_df = rbind(usermovies5, usermovies4, usermovies3)
    # Orders resulting dataframe based on greatest user movies reviewed, then by lowest sum
    critic_match_df = critic_match_df[with(critic_match_df, order(-user_movies_reviewed, diff_sum)),]
    critic_match_df = critic_match_df %>%
      select('Critic Name' = critic, 'Organisation(s)' = orgs, 'How Many of Your Movies Scored?' = user_movies_reviewed,
             'Critic Match Score' = diff_sum)
    return(critic_match_df)
  })
  
  # Creates a proxy table for clearing rows
  proxy = dataTableProxy('movie_table')
  
  # Initialize equivalent variables in UI for movie title
  output$movie1 = renderText({ input$movie1 })
  output$movie2 = renderText({ input$movie2 })
  output$movie3 = renderText({ input$movie3 })
  output$movie4 = renderText({ input$movie4 })
  output$movie5 = renderText({ input$movie5 })
  
  # When submit button is clicked, change tab
  observeEvent(input$toChoose, {
    updateTabsetPanel(session, 'inTabset',
                      selected = 'choose')
  })
  
  # Allows user to clear selected rows from the movie table. Also resets
  # textInput box text to default
  observeEvent(input$clearRows, {
    proxy %>% selectRows(NULL)
    updateTextInput(session, 'movie1', value = '---First Movie---')
    updateTextInput(session, 'movie2', value = '---Second Movie---')
    updateTextInput(session, 'movie3', value = '---Third Movie---')
    updateTextInput(session, 'movie4', value = '---Fourth Movie---')
    updateTextInput(session, 'movie5', value = '---Fifth Movie---')
  })
  
  # Allows user to reset selected ratings to default
  observeEvent(input$clearRating, {
    updatePrettyRadioButtons(session, 'rating1', selected = 0)
    updatePrettyRadioButtons(session, 'rating2', selected = 0)
    updatePrettyRadioButtons(session, 'rating3', selected = 0)
    updatePrettyRadioButtons(session, 'rating4', selected = 0)
    updatePrettyRadioButtons(session, 'rating5', selected = 0)
    })
  
  # Updates movie selection based on data table rows selected
  observeEvent(input$movie_table_rows_selected, {
    rows = input$movie_table_rows_selected
    if (length(rows) == 1){
      updateTextInput(session, 'movie1', value = just_movies$`Movie Title`[rows[1]])
    }
    
    else if (length(rows) == 2){
      updateTextInput(session, 'movie1', value = just_movies$`Movie Title`[rows[1]])
      updateTextInput(session, 'movie2', value = just_movies$`Movie Title`[rows[2]])
    }
    
    else if (length(rows) == 3){
      updateTextInput(session, 'movie1', value = just_movies$`Movie Title`[rows[1]])
      updateTextInput(session, 'movie2', value = just_movies$`Movie Title`[rows[2]])
      updateTextInput(session, 'movie3', value = just_movies$`Movie Title`[rows[3]])
    }
    
    else if (length(rows) == 4){
      updateTextInput(session, 'movie1', value = just_movies$`Movie Title`[rows[1]])
      updateTextInput(session, 'movie2', value = just_movies$`Movie Title`[rows[2]])
      updateTextInput(session, 'movie3', value = just_movies$`Movie Title`[rows[3]])
      updateTextInput(session, 'movie4', value = just_movies$`Movie Title`[rows[4]])
    }
    
    else if (length(rows) == 5){
      updateTextInput(session, 'movie1', value = just_movies$`Movie Title`[rows[1]])
      updateTextInput(session, 'movie2', value = just_movies$`Movie Title`[rows[2]])
      updateTextInput(session, 'movie3', value = just_movies$`Movie Title`[rows[3]])
      updateTextInput(session, 'movie4', value = just_movies$`Movie Title`[rows[4]])
      updateTextInput(session, 'movie5', value = just_movies$`Movie Title`[rows[5]])
    }
  })
  
  # Checks if user movie selections are invalid, if true display error message and ask user to try again
  # if false, continue to rate tab
  observeEvent(input$toRate, {
    default_movies = c('---First Movie---', '---Second Movie---', '---Third Movie---', '---Fourth Movie---', '---Fifth Movie---')
    # Check if error producing input exists, produces error message if true, continues if false
    if ((length(unique(movie_vec())) != 5) | (any(movie_vec() %in% default_movies))){
      output$wrongMovies = renderText({'Please select FIVE (5) UNIQUE movies and then click "Submit" again!'})
    }
    else{
      output$wrongMovies = renderText({NULL})
      updateTabsetPanel(session, 'inTabset',
                        selected = 'rate')
    }
  })
  
  # Render movie title table
  output$movie_table = DT::renderDataTable({
    datatable(just_movies, rownames = FALSE)
  })
  
  # Creates the critic match dataframe and changes to results tab
  observeEvent(input$toResults, {
    # Create critic match dataframe
    table = critic_match_df()
    # Render match table using critic match dataframe
    output$match_table = DT::renderDataTable({
      datatable(table, rownames = FALSE, selection = list(mode='single',
                                                          selected = 1))
    })
    # Change tab to results
    updateTabsetPanel(session, 'inTabset',
                      selected = 'results')
  })
  
  # If user selects a row in match table, create dataframe of that critic's top rated movies
  # and display below
  observeEvent(input$match_table_rows_selected, {
    row = input$match_table_rows_selected

    output$temp_table = DT::renderDataTable({
      top_movies = movie_df[movie_df$critic == critic_match_df()$`Critic Name`[row],] %>%
        filter(score >= .8) %>%
        select(movie, score)
      top_movies = top_movies[order(-top_movies$score),] %>%
        mutate(score = paste(score*10, '10', sep = '/')) %>%
        select('Movie Title' = movie, 'Critic Score' = score)
      datatable(top_movies, rownames = FALSE, selection = 'none')
    })
  })
}