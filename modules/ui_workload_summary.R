# UI function for workload summary
ui_workload_summary <- function(id) {
  ns <- NS(id)  # Namespace function for modularity, helps keep UI components unique
  
  tagList(
    # Dropdown menu (selectInput) for selecting an Internal Classification category
    selectInput(
      ns("classification2"),  # Input ID for server-side reference
      "Select Internal Classification",  # Label displayed to the user
      choices = NULL  # Initially NULL; will be updated dynamically based on uploaded data
    ),
    
    # Plot output that will display the dynamic plot created in the server function
    plotOutput(ns("workload_summary_plot"))  # Correct namespaced ID for plot output
  )
}
