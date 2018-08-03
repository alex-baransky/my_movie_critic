function(input, output, session) {
  
  # When submit button is clicked, change tab
  observeEvent(input$toChoose, {
    updateTabsetPanel(session, 'inTabset',
                      selected = 'choose')
  })
  observeEvent(input$toRate, {
    updateTabsetPanel(session, 'inTabset',
                      selected = 'rate')
  })
  observeEvent(input$toResults, {
    updateTabsetPanel(session, 'inTabset',
                      selected = 'results')
  })
  
  # Render movie list table
  output$movie_table = DT::renderDataTable({
    datatable(just_movies, rownames=FALSE)
  })
  
  # Initialize equivalent variables in UI for movie title
  output$movie1 = renderText({ input$movie1 })
  output$movie2 = renderText({ input$movie2 })
  output$movie3 = renderText({ input$movie3 })
  output$movie4 = renderText({ input$movie4 })
  output$movie5 = renderText({ input$movie5 })
}