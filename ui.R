#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  titlePanel("Metagenomics Sampling Depth Calculator"),
  
  sidebarLayout(
    sidebarPanel(
      #numericInput("target_size", label = "Target Genome Size (bp)", value=10000),
      numericInput("target_abundance", label = "Target Abundance (%)", value=0.05),
      #numericInput("read_length", label = "Read Length (bp)", value=150),
      #helpText("Note: If using paired-end reads, enter",
      #         "the sum of the forward and reverse",
      #         "read length."),
      numericInput("max_reads", label = "Maximum Number Reads", value=10000000),
      helpText("Note: number of sequencing reads generated,",
               "controls what is plotted on graph."),
      numericInput("min_reads", label = "Target Min Number Reads", value=5),
      numericInput("probability", label = "Probability Level", value=0.95),
      helpText("Note: update fields to appropriate values, then click",
               "the Calculate button to update the graph and",
               "probability output."),
      submitButton("Calculate")
    ),
    
    mainPanel(
       plotOutput("prob_plot"),
       helpText('Read statistics:'),
       verbatimTextOutput('prob')
    )
  )
))
