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
  ),
  
  fluidRow(),
  tags$footer(
    tags$p("Supported by: Monash Proteomics and Metabolomics Platform & Monash Bioinformatics Platform, Monash University"),
    align = "center",
    style = "
      font-size: 14px;
      background-color: #f8f9fa;
      border-top: 1px solid #e9ecef;
      position: fixed;
      bottom: 0;
    width: 100%; "
    ),
  shiny.info::version(position = "bottom right")
)