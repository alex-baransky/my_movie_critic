function(input, output, session) {
  
  # Photo of me for "About" tab
  # output$me = renderUI({
  #   img(src = 'alexb_headshot.jpg',
  #       width = 500,
  #       style ="display: block; margin-left: auto; margin-right: auto;")
  # })
  
  output$me = renderImage({

    list(src = 'alexb_headshot.jpg', style = "display: block; margin-left: auto; margin-right: auto;")
  }, deleteFile = FALSE)
  
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
    # Produces a progress bar to let user know something is happening in the app
    withProgress(message = 'Creating match table', value = 0, {
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
        incProgress(0, detail = paste("Converting critic scores to dataframe"))
      }
      # Creates org column vector to display critic associated orgs
      for (name in just_critics){
        org_col = c(org_col, paste(unique(filter(movie_df, critic == name)$org), collapse = '|'))
        incProgress(1/length(just_critics), detail = paste("Creating organization column for", name))
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
        mutate(movie1_sq = ((score_vec()[1] - movie1)*10)^2, movie2_sq = ((score_vec()[2] - movie2)*10)^2,
               movie3_sq = ((score_vec()[3] - movie3)*10)^2, movie4_sq = ((score_vec()[4] - movie4)*10)^2,
               movie5_sq = ((score_vec()[5] - movie5)*10)^2) %>%
        rowwise() %>% 
        mutate(diff_sum = sum(movie1_diff, movie2_diff, movie3_diff, movie4_diff, movie5_diff, na.rm = TRUE)) %>% 
        mutate(sq_sum = sum(movie1_sq, movie2_sq, movie3_sq, movie4_sq, movie5_sq, na.rm = TRUE)) %>% 
        select(critic, orgs, user_movies_reviewed, diff_sum, sq_sum) %>%
        as.data.table() %>% 
        top_n(-5, diff_sum)
      # Does the same as above except for user movies reviewed = 4 
      usermovies4 = critic_df %>%
        filter(user_movies_reviewed == 4) %>% 
        mutate(movie1_diff = abs(score_vec()[1] - movie1)*10, movie2_diff = abs(score_vec()[2] - movie2)*10,
               movie3_diff = abs(score_vec()[3] - movie3)*10, movie4_diff = abs(score_vec()[4] - movie4)*10,
               movie5_diff = abs(score_vec()[5] - movie5)*10) %>%
        mutate(movie1_sq = ((score_vec()[1] - movie1)*10)^2, movie2_sq = ((score_vec()[2] - movie2)*10)^2,
               movie3_sq = ((score_vec()[3] - movie3)*10)^2, movie4_sq = ((score_vec()[4] - movie4)*10)^2,
               movie5_sq = ((score_vec()[5] - movie5)*10)^2) %>%
        rowwise() %>% 
        mutate(diff_sum = sum(movie1_diff, movie2_diff, movie3_diff, movie4_diff, movie5_diff, na.rm = TRUE)) %>% 
        mutate(sq_sum = sum(movie1_sq, movie2_sq, movie3_sq, movie4_sq, movie5_sq, na.rm = TRUE)) %>% 
        select(critic, orgs, user_movies_reviewed, diff_sum, sq_sum) %>%
        as.data.table() %>% 
        top_n(-5, diff_sum)
      # Does the same as above except for user movies reviewed = 3
      usermovies3 = critic_df %>%
        filter(user_movies_reviewed == 3) %>% 
        mutate(movie1_diff = abs(score_vec()[1] - movie1)*10, movie2_diff = abs(score_vec()[2] - movie2)*10,
               movie3_diff = abs(score_vec()[3] - movie3)*10, movie4_diff = abs(score_vec()[4] - movie4)*10,
               movie5_diff = abs(score_vec()[5] - movie5)*10) %>%
        mutate(movie1_sq = ((score_vec()[1] - movie1)*10)^2, movie2_sq = ((score_vec()[2] - movie2)*10)^2,
               movie3_sq = ((score_vec()[3] - movie3)*10)^2, movie4_sq = ((score_vec()[4] - movie4)*10)^2,
               movie5_sq = ((score_vec()[5] - movie5)*10)^2) %>%
        rowwise() %>% 
        mutate(diff_sum = sum(movie1_diff, movie2_diff, movie3_diff, movie4_diff, movie5_diff, na.rm = TRUE)) %>% 
        mutate(sq_sum = sum(movie1_sq, movie2_sq, movie3_sq, movie4_sq, movie5_sq, na.rm = TRUE)) %>% 
        select(critic, orgs, user_movies_reviewed, diff_sum, sq_sum) %>%
        as.data.table() %>% 
        top_n(-5, diff_sum)
      
      # Combines the above 3 dataframes
      critic_match_df = rbind(usermovies5, usermovies4, usermovies3)
      # Orders resulting dataframe based on greatest user movies reviewed, then by lowest sum
      critic_match_df = critic_match_df[with(critic_match_df, order(-user_movies_reviewed, sq_sum, diff_sum)),]
      critic_match_df = critic_match_df %>%
        mutate(sq_sum = round(sq_sum, digits = 3)) %>% 
        select('Critic Name' = critic, 'Organisation(s)' = orgs, 'How Many of Your Movies Reviewed?' = user_movies_reviewed,
               'Squared Distance Score' = sq_sum, 'Absolute Distance Score' = diff_sum)
      return(critic_match_df)
    })
  })
  
  # Creates a proxy table for clearing rows
  proxy = dataTableProxy('movie_table')
  
  # Initialize equivalent variables in UI for movie title
  output$movie1 = renderText({ input$movie1 })
  output$movie2 = renderText({ input$movie2 })
  output$movie3 = renderText({ input$movie3 })
  output$movie4 = renderText({ input$movie4 })
  output$movie5 = renderText({ input$movie5 })
  
  # When submit button is clicked, change tab to choose
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
  
  # Checks if user movie selections are valid, if true contiue to next tab,
  # if false, print out one of several error messages and ask user to retry
  observeEvent(input$toRate, {
    default_movies = c('---First Movie---', '---Second Movie---', '---Third Movie---', '---Fourth Movie---', '---Fifth Movie---')
    
    if ((length(unique(movie_vec())) == 5) & (all(movie_vec() %in% just_movies$`Movie Title`))){
      output$wrongMovies = renderText({NULL})
      # Change tab to rate
      updateTabsetPanel(session, 'inTabset',
                        selected = 'rate')
    }
    else if (length(unique(movie_vec())) != 5){
      output$wrongMovies = renderText({'Please select five UNIQUE movies and then click "Submit" again!'})
    }
    else if (any(movie_vec() %in% default_movies)){
      output$wrongMovies = renderText({'One or more of your movies have not been selected, please select five movies, then click "Submit" again!'})
    }
    else if (any(movie_vec() %in% c('', ' ', '   '))){
      output$wrongMovies = renderText({'One of the input boxes is empty, please select five movies, then click "Submit" again!'})
    }
    else{
      output$wrongMovies = renderText({'There is a strange error with your movie input, please check that your selected movies are correct, then click "Submit" again!'})
    }
  })
  
  # Render movie title table
  output$movie_table = DT::renderDataTable({
    datatable(just_movies, rownames = FALSE)
  })
  
  # Creates a selectizeInput to pick critics to inspect
  output$inspect_critic = renderUI({
    critic_names = as.character(critic_match_df()$`Critic Name`)
    selectizeInput(inputId = 'your_critic', label = 'Select a critic to inspect more closely:',
                   choices = critic_names)
  })
  
  # Creates the critic match dataframe and changes to matches tab
  observeEvent(input$toMatches, {
    # Create critic match dataframe
    table = critic_match_df()
    # Render match table using critic match dataframe
    output$match_table = DT::renderDataTable({
      datatable(table, rownames = FALSE, selection = list(mode='single',
                                                          selected = 1))
    })
    # Change tab to matches
    updateTabsetPanel(session, 'inTabset',
                      selected = 'matches')
  })
  
  # If user selects a critic in selectizeInput, change the two data tables on "Your Critic"
  # tab accordingly
  observeEvent(input$toCritic, {
    # Change tab to your critic
    updateTabsetPanel(session, 'inTabset',
                      selected = 'your_critic')
  })
  
  # If user selects a row in match table, create dataframe of that critic's top rated movies
  # and lowest rated movies and display below
  observeEvent(input$match_table_rows_selected, {
    row = input$match_table_rows_selected
    
    output$selected_critic = renderText({ as.character(critic_match_df()$`Critic Name`[row]) })
    
    output$see_movies = DT::renderDataTable({
      top_movies = movie_df[movie_df$critic == critic_match_df()$`Critic Name`[row],] %>%
        filter(score >= .8) %>%
        select(movie, score)
      top_movies = top_movies[order(-top_movies$score, top_movies$movie),] %>%
        mutate(score = paste(score*10, '10', sep = '/')) %>%
        select('Movie Title' = movie, 'Critic Score' = score)
      datatable(top_movies, rownames = FALSE, selection = 'none')
    })
    
    output$avoid_movies = DT::renderDataTable({
      bottom_movies = movie_df[movie_df$critic == critic_match_df()$`Critic Name`[row],] %>%
        filter(score <= .3) %>%
        select(movie, score)
      bottom_movies = bottom_movies[order(bottom_movies$score, bottom_movies$movie),] %>%
        mutate(score = paste(score*10, '10', sep = '/')) %>%
        select('Movie Title' = movie, 'Critic Score' = score)
      datatable(bottom_movies, rownames = FALSE, selection = 'none')
    })
  })
  
  observeEvent(input$your_critic, {
    critic = input$your_critic
    
    # Creates a dataframe containing movies reviewed by the currently selected critic where
    # the critic's rating is higher than the average rating
    output$critic_high = DT::renderDataTable({
      high_df = movie_df[movie_df$critic == critic,] %>%
        filter((score - avg_rating) >= .3) %>%
        select(movie, score, avg_rating)
      high_df = high_df[order(-high_df$score, high_df$movie),] %>%
        mutate(score = paste(score*10, '10', sep = '/'), avg_rating = paste(avg_rating*10, '10', sep = '/')) %>%
        select('Movie Title' = movie, 'Critic Score' = score, 'Average Rating' = avg_rating)
      datatable(high_df, rownames = FALSE, selection = 'none')
    })
    
    # Creates a dataframe containing movies reviewed by the currently selected critic where
    # the critic's rating is higher than the average rating
    output$critic_low = DT::renderDataTable({
      high_df = movie_df[movie_df$critic == critic,] %>%
        filter((avg_rating - score) >= .3) %>%
        select(movie, score, avg_rating)
      high_df = high_df[order(-high_df$score, high_df$movie),] %>%
        mutate(score = paste(score*10, '10', sep = '/'), avg_rating = paste(avg_rating*10, '10', sep = '/')) %>%
        select('Movie Title' = movie, 'Critic Score' = score, 'Average Rating' = avg_rating)
      datatable(high_df, rownames = FALSE, selection = 'none')
    })
  })
}