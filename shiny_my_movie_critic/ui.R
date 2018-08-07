fluidPage(
  navbarPage("My Movie Critic", id = 'inTabset', theme = shinytheme('cerulean'),
             # Welcome tab
             tabPanel(title = "Welcome!", value = "welcome",
                      mainPanel(
                        fluidRow(
                          h3('Welcome to My Movie Critic, the movie critic matching application!')
                        ),
                        fluidRow(
                          actionButton("toChoose", "Get Started", icon("arrow-right"), 
                                       style="color: #318fe0; background-color: #337ab7; border-color: #318fe0")
                        )
                      )
             ),
             # Choose movies tab
             tabPanel(title = "Choose Your Movies", value = 'choose',
                      mainPanel(
                        h2('Choose Your Movies'),
                        h4('Please CHOOSE FIVE (5) UNIQUE MOVIES from the table below. You can use the search function\
                             to find specific titles. Clicking the rows will add the movie title to the text boxes.'),
                        h4('If you enter the titles manually, please make sure to ENTER THE TITLES EXACTLY AS YOU SEE THEM in the table!'),
                        br(),
                        DT::dataTableOutput("movie_table"),
                        br(),
                        fluidRow(
                          splitLayout(
                            textInput("movie1", "Movie 1", "---First Movie---"),
                            textInput("movie2", "Movie 2", "---Second Movie---")
                          )
                        ),
                        fluidRow(
                          splitLayout(
                            textInput("movie3", "Movie 3", "---Third Movie---"),
                            textInput("movie4", "Movie 4", "---Fourth Movie---")
                          )
                        ),
                        fluidRow(
                          textInput("movie5", "Movie 5", "---Fifth Movie---")
                        ),
                        fluidRow(
                          actionButton("toRate", "Submit", icon("arrow-right"), 
                                       style="color: #318fe0; background-color: #337ab7; border-color: #318fe0"),
                          actionButton("clearRows", "Clear Selected Movies", icon("eraser"),
                                       style="color: #318fe0; background-color: #337ab7; border-color: #318fe0")
                        ),
                        fluidRow(
                          h3(textOutput("wrongMovies"))
                        ),
                        br(),
                        br()
                      )
             ),
             # Rate movies tab
             tabPanel(title = "Rate", value = 'rate',
                      fluidRow(
                        h2('Rate Your Movies'),
                        h4('Please rate each movie on a scale of 0 to 10 (0 is the worst, 10 is the best).')
                      ),
                      fluidRow(
                        # Display user's selected  movies
                        textOutput('movie1'),
                        # Add radio buttons for user to rate the movie
                        prettyRadioButtons(inputId = "rating1", label = NULL,
                                           0:10, inline = TRUE, selected = 0, animation = 'pulse', icon = icon('star'))
                      ),
                      fluidRow(
                        textOutput('movie2'),
                        prettyRadioButtons(inputId = "rating2", label = NULL,
                                           0:10, inline = TRUE, selected = 0, animation = 'pulse', icon = icon('star'))
                      ),
                      fluidRow(
                        textOutput('movie3'),
                        prettyRadioButtons(inputId = "rating3", label = NULL,
                                           0:10, inline = TRUE, selected = 0, animation = 'pulse', icon = icon('star'))
                      ),
                      fluidRow(
                        textOutput('movie4'),
                        prettyRadioButtons(inputId = "rating4", label = NULL,
                                           0:10, inline = TRUE, selected = 0, animation = 'pulse', icon = icon('star'))
                      ),
                      fluidRow(
                        textOutput('movie5'),
                        prettyRadioButtons(inputId = "rating5", label = NULL,
                                           0:10, inline = TRUE, selected = 0, animation = 'pulse', icon = icon('star'))
                      ),
                      # Make movie title text larger
                      tags$head(
                        tags$style("#movie1{font-size: 18px}"),
                        tags$style("#movie2{font-size: 18px}"),
                        tags$style("#movie3{font-size: 18px}"),
                        tags$style("#movie4{font-size: 18px}"),
                        tags$style("#movie5{font-size: 18px}")
                      ),
                      # Action button to go to the next tab
                      fluidRow(
                        actionButton("toResults", "Submit", icon("arrow-right"), 
                                     style="color: #318fe0; background-color: #337ab7; border-color: #318fe0"),
                        actionButton("clearRating", "Reset Ratings", icon("eraser"),
                                     style="color: #318fe0; background-color: #337ab7; border-color: #318fe0")
                      ),
                      fluidRow(
                        h4('Please be patient, this may take a few seconds...')
                      ),
                      br(),
                      br()
             ),
             # Show results tab
             tabPanel(title = "Results", value = 'results',
                      fluidRow(
                        h3('Here are your matched critics'),
                        br(),
                        DT::dataTableOutput("match_table"), width = 12, title = 'Your Closest Matched Critics'),
                      fluidRow(
                        h2('Movie Reviews By', textOutput('selected_critic')),
                        column(h3('Movies to See'),
                        DT::dataTableOutput('see_movies'), width = 6, title = 'Movies to Check Out'),
                        column(h3('Movies to Avoid'),
                        DT::dataTableOutput('avoid_movies'), width = 6, title = 'Movies to Avoid'))
                      ),
             # About me tab
             tabPanel(title = "About", value = 'about',
                      h3('My name is Alex Baransky...')
             )
  )
)