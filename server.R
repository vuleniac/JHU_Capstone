
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)


shinyServer(function(input, output) {
    dataInput <- reactive({
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        
        progress$set(message = "predicting", value = 3)
        
            x <-(suggestGram(input$entry, n = input$n))
            gsub(toString(x),pattern = ",", replacement = " ")

            
    })
    output$text <- renderText({
        dataInput()
    })
    output$sent <- renderText({
        exit <- normText(input$entry, rmVulgar = profanity)
        if(exit==""){
            "No nGram generated"
        }else{
            exit
        }
    })
})