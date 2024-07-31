# Define server logicc----
server <- function(input, output,session) {
  options(shiny.maxRequestSize=100*1024^2)## Set maximum upload size to 100MB
  
  ## make reactive elements
  protein_input_data<-reactive({NULL})
  exp_design_input<-reactive({NULL})
  # reactive object
  protein_input_data <- eventReactive(input$analyze,{
    inFile<-input$file1
    if(is.null(inFile))
      return(NULL)
    temp_data<-read.delim(inFile$datapath,
                          header = TRUE,
                          fill= TRUE, 
                          sep = "\t",
                          check.names = F)
    return(temp_data)
  })
  
  exp_design_input<-eventReactive(input$analyze,{
    inFile<-input$file2
    if(is.null(inFile))
      return(NULL)
    temp_df <- read_exp_func(inFile)
    colnames(temp_df)[colnames(temp_df)=="column"] <- "label"
    return(temp_df)
    })
  
  exp_column_list <- reactive({
    inFile<-input$file2
    if(is.null(inFile))
      return(NULL)
    temp_df <- read_exp_func(inFile)
    column_list <- colnames(temp_df)
    return(column_list)
  })
  
  # update selections
  observe({
    req(input$file2)
    if(!is.null(exp_column_list())){
      updateSelectInput(session, 
                        "var",
                        "Choose the x-value",
                        choices = exp_column_list(),
                        selected = {
                          choices = exp_column_list()
                          if ("solv%" %in% choices) {
                            "solv%"
                          }
                        }
      )
      
      updateSelectInput(session, 
                        "group",
                        "Choose the group",
                        choices = exp_column_list(),
                        selected = {
                          choices = exp_column_list()
                          if ("treatment" %in% choices) {
                            "treatment"
                          }
                        }
      )
      
      }
  })
  
  
  # Output table
  output$contents <- DT::renderDataTable({
    if(!is.null(protein_input_data())){
      data <- protein_input_data()
      datatable(data, selection = 'single')  # Enable single row selection
    }
    
  })
  
  output$results <- renderTable({
    if(!is.null(input$contents_rows_selected) & !is.null(boot_data())){
      data <- boot_data() %>%
        dplyr::arrange(!!dplyr::sym(input$group),!!dplyr::sym(input$var)) %>%
        dplyr::mutate(
          proteinID = stringr::str_trunc(proteinID, width = 10)
        )
    }
    
  })
  
  
  boot_data <- reactive({
    req(protein_input_data())
    data <- protein_input_data()
    selected <- input$contents_rows_selected
    protein <- data[selected, "PG.ProteinGroups"]
    exp <- exp_design_input()
    if (length(selected) > 0) {
      data <- data[selected, grep("PG.Quantity", names(data))] # spectronaut output
      data <- data %>% 
        rownames_to_column() %>% 
        gather(label, intensity, -rowname) %>% 
        right_join(exp, by = join_by("label"))
      
      # data$rowname <- parse_factor(as.character(data$rowname), levels = protein)
      data[[input$group]] <- factor(data[[input$group]])
      
      # Calculate bootstrapped confidence intervals
      boot_data <- bootstrap_ci(data, "intensity", input$var, input$group)
      boot_data$proteinID <- protein
    }
    return(boot_data)
  })
  
  curve_plot_input <- reactive({
    req(boot_data())
    
    # print(boot_data())
    var <- dplyr::sym(input$var)
    group <- dplyr::sym(input$group)
    
    # Debugging
    # print(head(boot_data))
    
    p <- ggplot(boot_data(), aes(x = !!var, y = mean_abundance, color = !!group, group = !!group)) +
      geom_line() +
      geom_point() +
      geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper, fill = !!group), color = NA, alpha = 0.2) +
      geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, alpha = 0.2) +
      labs(x = "Solv%", y = "Mean Abundance", 
           title = paste0("Mean Abundance by", var, " and ", group, " with Bootstrapped CI"),
           subtitle = paste0("Target: ", boot_data()$proteinID)
           ) +
      theme_DEP1() +
      theme(legend.position = "right")
    return(p)
  })
  
  output$curve_plot <- renderPlot({
    if(!is.null(input$contents_rows_selected)){
      curve_plot_input()
    }
  })
  
  observe(
    if(!is.null(input$contents_rows_selected)){
      shinyjs::show("download_svg")
    }
  )
  
  output$download_svg<-downloadHandler(
    filename = function() { "curve_plot.svg" }, 
    content = function(file) {
      svg(file, width = 12, height = 7)
      print(curve_plot_input())
      dev.off()
    }
  )
  
}