library("shiny")
library("shinyjs")
library("bslib")
library("tidyverse")
library("DT")
library("DEP")
library("ggplot2")
library("boot")

source("R/functions.R")
options(DT.options = list(scrollX = TRUE,
                          pageLength = 15,  # Show 15 rows by default
                          columnDefs= list(list(targets = 1,
                                                render = JS(
                                                  "function(data, type, row, meta) {",
                                                  "return type === 'display' && data.length > 30 ?",
                                                  "'<span title=\"' + data + '\">' + data.substr(0, 30) + '...</span>' : data;",
                                                  "}")),
                                           list(targets = 2:(ncol(data) - 1), #  "_all" apply to all
                                                render = JS(
                                                  "function(data, type, row, meta) {",
                                                  "return type === 'display' && data.length > 15 ?",
                                                  "'<span title=\"' + data + '\">' + data.substr(0, 15) + '...</span>' : data;",
                                                  "}"))
                          )
))

# Define UI ----
ui <- page_sidebar(
  # App title ----
  title = "CurveLine",
  # Sidebar panel for inputs ----
  sidebar = sidebar(
    # Input: file upload
    fileInput("file1", label = "protein file"),
    fileInput("file2", label = "experimental design file"),
    
    helpText(
      "Select the x-values and group columns from experimental design file for the plot"
    ),
    
    selectInput(inputId = "var",
                label = "Choose the x-value",
                choices = "",
                selected = NULL,
                multiple = FALSE),
    
    selectInput(inputId = "group",
                label = "Choose the group",
                choices = "",
                selected = NULL,
                multiple = FALSE),
    
    tags$hr(),
    actionButton("analyze", "Start Plot")
  ),
  # Output: Line plots with bootsctraps ci ----
  useShinyjs(),  
  tags$head(
    tags$style(HTML("
      # .centered-table {
      #   display: flex;
      #   justify-content: center;
      # }
      .bottom-right {
        text-align: right;
      }
    "))
  ),
  fluidRow(
    column(6,
           DT::dataTableOutput("contents")
    ),
    column(6,
           plotOutput(outputId = "curve_plot"),
           div(class = "bottom-right",shinyjs::hidden(downloadButton('download_svg', "Save svg"))),
           tableOutput("results")
           # div(class = "centered-table", tableOutput("results"))
           
    )
  )
)