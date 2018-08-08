fluidPage(
  navbarPage("My Movie Critic", id = 'inTabset', theme = shinytheme('cerulean'),
             # Welcome tab
             tabPanel(title = "Welcome!", value = "welcome",
                      fluidRow(
                        h2('Welcome to My Movie Critic', style = 'text-align:center'),
                        h3('The movie critic matching application!', style = 'text-align:center'),
                        tags$img(src = 'movie.jpg', width = 450, height = 300, style="display: block; margin-left: auto; margin-right: auto;"),
                        h4('This application is designed to compare ratings you assign to five different movies to the ratings of\
                              professional movies critics. This method finds the movie critics whose taste in movies are most aligned with\
                              your own!'),
                        h4('Unlike other algorithms that simply suggest movies you might enjoy, this application directly\
                              suggests real critics who you can follow. This technique adds the advantage of seeing a critic\'s detailed review\
                              of a movie and what they liked or disliked about it. Now you can know why you might like a movie, not just\
                              whether or not (for some unknown reason) it might interest you!'),
                        br(),
                        h4('Press the "Get Started" button below.')
                      ),
                      br(),
                      fluidRow(
                        actionButton("toChoose", "Get Started", icon("arrow-right"), 
                                     style="color: #318fe0; background-color: #337ab7; border-color: #318fe0")
                      )
             ),
             # Choose movies tab
             tabPanel(title = "Choose Your Movies", value = 'choose',
                      h2('Choose Your Movies', style = 'text-align:center'),
                      h4('Please choose FIVE (5) UNIQUE movies from the table below. You can use the search function\
                             to find specific titles. Clicking the rows in the table will automatically add the movie title to the text boxes.'),
                      h4('If you enter the titles manually, please make sure to ENTER THE TITLES EXACTLY AS YOU SEE THEM in the table!'),
                      h4('You can click the "Clear Selected Movies" button to clear the movies you have entered.'),
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
             ),
             # Rate movies tab
             tabPanel(title = "Rate", value = 'rate',
                      fluidRow(
                        h2('Rate Your Movies'),
                        h4('Please rate each movie on a scale of 0 to 10 (0 is worst, 10 is best).')
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
                        actionButton("toMatches", "Submit", icon("arrow-right"), 
                                     style="color: #318fe0; background-color: #337ab7; border-color: #318fe0"),
                        actionButton("clearRating", "Reset Ratings", icon("eraser"),
                                     style="color: #318fe0; background-color: #337ab7; border-color: #318fe0")
                      ),
                      fluidRow(
                        h4('Loading progress will be shown in bottom right corner.'),
                        h4('Please be patient, this may take a few seconds...')
                      ),
                      br()
             ),
             # Show results tab
             tabPanel(title = "Your Matches", value = 'matches',
                      fluidRow(
                        h2('We found your matched critics!', style = 'text-align:center'),
                        h3('Here\'s a breakdown of the information you see below:'),
                        h4('This data table shows your matched critics. They are ordered by  the sum of squared\
                            distance between scores (i.e. (your score - critic score)^2). The lower the score,\
                            the closer the match. Absolute distance is another measure of rating difference,\
                            but larger differences are weighted the same as smaller ones.'),
                        h4('The "How Many of Your Movies Reviewed?" column shows you have many of the movies you\
                            picked were reviewed by that critic. A 5 means all five of your movies were reviewed,\
                            while a 3 means only three were. Critics matches with a reivew count of 5 will probably\
                            be more accurate.'),
                        br(),
                        DT::dataTableOutput("match_table"), width = 12, title = 'Your Closest Matched Critics'),
                      fluidRow(
                        h2(textOutput('selected_critic'), style = 'text-align:center'),
                        h4('You can click a row in the data table above to update these two tables below. These tables\
                           show the highest and lowest rated movies in the data set by this critic. Since you were matched\
                           to these critics, maybe you should check out the movies on the left and avoid the movies on the right!'),
                        h4('When you\'re done, click the "Continue" button below to continue to the next page.'),
                        actionButton("toCritic", "Continue", icon("arrow-right"), 
                                     style="color: #318fe0; background-color: #337ab7; border-color: #318fe0")),
                      fluidRow(
                        column(h3('Movies to See', style = 'text-align:center'),
                               DT::dataTableOutput('see_movies'), width = 6),
                        column(h3('Movies to Avoid', style = 'text-align:center'),
                               DT::dataTableOutput('avoid_movies'), width = 6))
                      ),
             # Show critic specific tab
             tabPanel(title = 'Your Critic', value = 'your_critic',
                      fluidRow(
                        h3('Here you can select from your matched critics to find movies you normally wouldn\'t think to watch!'),
                        h4('The table on the left shows movies where your selected critic rated the movie much higher than the average\
                            critic. This might indicate a movie that many people didn\'t like but that you might enjoy. Conversely, the right\
                            table shows movies that were generally rated highly but was rated low by your selected critic. Although people\
                            may recommend this movie to you, you may not enjoy it as much as the average person.'),
                        br(),
                        uiOutput('inspect_critic')),
                      fluidRow(
                        column(h2('Critic Rating High / Average Rating Low', style = 'text-align:center'),
                               h3('Unpopular Movies to Check Out', style = 'text-align:center'),
                               DT::dataTableOutput('critic_high'), width = 6),
                        column(h2('Critic Rating Low / Average Rating High', style = 'text-align:center'),
                               h3('Popular Movies to Avoid', style = 'text-align:center'),
                               DT::dataTableOutput('critic_low'), width = 6))
             ),
             # About me tab
             tabPanel(title = "About", value = 'about',
                      h2('Thanks for using my application!', style = 'text-align:center'),
                      tags$img(src = 'alexb_headshot.jpg', width = 300, height = 300, style="display: block; margin-left: auto; margin-right: auto;"),
                      h4('My name is Alex Baransky (alex.baransky@gmail.com). I graduated from Columbia University\
                          in 2017 with a major in Environmental Biology. Before that, I had completed three years\
                          of a Computer Engineering degree from Columbia\'s Fu Foundation School of Engineering\
                          and Applied Science.'),
                      br(),
                      h4('I created this application as a project for the NYC Data Science Academy Immersive\
                          Data Science Bootcamp. Using the scrapy python package, I extracted the data that the\
                          app uses behind the scenes to perform the critic match. This application uses movie review\
                          data from RottenTomatoes.com to calculate the matches. The data consists of over 1,000 movies\
                          and ratings for each movie from almost 3,500 certified movie critics. The movies include\
                          top rated films between the years 2000 and 2018 and only those films that were reviewed by\
                          100 or more critics.'),
                      br(),
                      h4('If you would like view my code, please visit my github repository here:'),
                      a("My GitHub Repo", href="https://github.com/alex-baransky/my_movie_critic")
             )
  )
)
