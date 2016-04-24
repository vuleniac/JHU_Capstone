

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source("./RESOURCES.R")

shinyUI(fluidPage(
    # Set the page title
    titlePanel("WORD PREDICTION ALGORITHM"),
    
    sidebarPanel(
        textInput("entry",
                  h5("Input the sentence"),
                  "Barak Obama became the"),
        numericInput("n",
                     h5("Maximum number of predicted words"),
                     value = 5),
        submitButton("SUBMIT"),
    p(""),
    p(""),
    p("By Miguel Goncalves")
 ),
    mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("PREDICTION",
                             h4("What it does:"),
                             p('This application takes the imputed text and normalizes to make it comparable with the nGrams generated in the processing of the Corpora provided by SwiftKey. This normalization process involves:'),
                               p('1. Remove punctuation'),   
                               p('2. Turn the text to lower case'),
                               p('3. Remove profanity'),   
                               p('4. Remove stop-words'),
                               p('5. Remove numbers and special characters'),
                             p('The length of the normalized text string is measured and compared to the corresponding nGrma size. The largest nGrams tokenized in the processing of the corpora were quadgrams (n=4), thus in a normalized text string of three or more words, the last three words will be compared to the first three words of the token, while the forth word of the token with the highest frequency would be the first predicted word, with the subsequent suggestions following according their frequency. If there is no match for the current nGram size, then the algorithm moves to the following nGram size (n-1). If there is no match for any of the nGrams, "No Suggestion" is return.
                               '),
                             h4("How to use it:"),
                             p('Input a sentence in the "Input the sentence" field and pick the maximum number of predicted words. Once set up, hit the submit button. The sentence is normalized creating an nGRam that the algorithm would try to match to the tokens in the database.'),
                             p('nGram the algorithm sees:'),
                             
                             tags$style(type='text/css', '#sent {background-color: rgba(0,0,255,0.10); text-align: center; color: red;font-weight: bold; font-size:25px;}'), 
                             h4(verbatimTextOutput("sent"),style = "color:blue"),                               
                             p('These are the words that match the nGRam'),
                             tags$style(type='text/css', '#text {background-color: rgba(0,0,255,0.10); text-transform: uppercase; color: blue;font-size:25px;}'),
                             span(h4(verbatimTextOutput('text'),style = "color:blue"))),
                    
                    tabPanel('ALGORITHM',
                             h4('ALGORITHM FLOW CHART'),
                             img(src='algorithm.png', align = "center")
                    )
        ))
))