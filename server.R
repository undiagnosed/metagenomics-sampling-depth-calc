#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(scales)

# log tick functions from:
# stackoverflow.com/questions/30179442/
# plotting-minor-breaks-on-a-log-scale-with-ggplot
log_breaks = function(maj, radix=10) {
  function(x) {
    minx         = floor(min(logb(x,radix), na.rm=T)) - 1
    maxx         = ceiling(max(logb(x,radix), na.rm=T)) + 1
    n_major      = maxx - minx + 1
    major_breaks = seq(minx, maxx, by=1)
    if (maj) {
      breaks = major_breaks
    } else {
      steps = logb(1:(radix-1),radix)
      breaks = rep(steps, times=n_major) +
        rep(major_breaks, each=radix-1)
    }
    radix^breaks
  }
}
scale_x_log_eng = function(..., radix=10) {
  scale_x_continuous(...,
                     trans=log_trans(radix),
                     breaks=log_breaks(TRUE, radix),
                     minor_breaks=log_breaks(FALSE, radix))
}
scale_y_log_eng = function(..., radix=10) {
  scale_y_continuous(...,
                     trans=log_trans(radix),
                     breaks=log_breaks(TRUE, radix),
                     minor_breaks=log_breaks(FALSE, radix))
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$prob <- renderText({
    # numerical approximation for now from:
    # stackoverflow.com/questions/20124305/
    # is-there-a-function-or-package-in-r-that-can-get-lambda-of-poisson-distribution
    f2 <- function(l,r,p) ppois(q=r, lambda=l, lower.tail = FALSE) - p
    a <- uniroot(f2, c(0, 10), r=input$min_reads-1,p=input$probability,extendInt = "yes")
    r <- round(a$root/(input$target_abundance/100))
    paste("Minimum number of reads needed at",input$probability,"probability level:",r,sep=" ")
  })
   
  output$prob_plot <- renderPlot({
    # Poisson CDF X >= k
    # 1-P(X <= k-1)
    # subsample reads, normalize to 10000
    reads <- seq(from = 1000, to = input$max_reads, by = input$max_reads/10000)
    lambda <- reads*(input$target_abundance/100)
    probability <- ppois(q=input$min_reads-1, lambda=lambda, lower.tail = FALSE)
    
    df = data.frame(reads, probability) 
    (ggplot(df, aes(reads,probability)) 
      + ggtitle(paste("Probability of getting",input$min_reads,"or more on-target reads",sep=" ")) 
      + geom_line() 
      + geom_hline(yintercept=c(input$probability), linetype="dotted")
      + scale_x_log_eng()
      + scale_y_continuous(breaks=seq(0,1,0.1))
      )
  })
})
