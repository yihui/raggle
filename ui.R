library(shiny)

shinyUI(pageWithSidebar(

  headerPanel('ISU Stat 503 Million Song Dataset Challenge'),

  sidebarPanel(
    h3(textOutput('howdy')),
    selectInput('group', 'Please select your group number', 0:12),
    conditionalPanel('input.group != 0',
                     textInput('pass', 'Group password'),
                     fileInput('rdata', 'Upload your predictions (text labels)')),
    helpText('The leader board shows the prediction error rates. Group numbers
             are in the first column. NA means no attempt has been made.
             More info <a href="https://github.com/yihui/raggle#readme">here</a>.'),
    div(img(src = 'http://www.kiss925.com/files/365984-gangnam-style.jpg'))
  ),

  mainPanel(
    verbatimTextOutput('results')
  )
))
