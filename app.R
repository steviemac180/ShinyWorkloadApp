# Load necessary libraries
library(shiny)
library(readxl)
library(dplyr)

# Source UI and server module files
source("modules/ui_data_upload.R")
source("modules/server_data_upload.R")
source("modules/ui_workload_summary.R")
source("modules/server_workload_summary.R")

# Define the User Interface (UI) of the application
ui <- fluidPage(
  titlePanel("Laboratory Data Analysis App"),
  sidebarLayout(
    sidebarPanel(
      ui_data_upload("data_upload")  # File upload UI
    ),
    mainPanel(
      ui_workload_summary("workload_summary")  # Plot output should be part of this module UI
    )
  )
)

# Define the server logic of the application
server <- function(input, output, session) {
  # Call the server module for data upload and store the uploaded data
  uploaded_data <- callModule(server_data_upload, "data_upload")
  
  # Call the server module for workload summary, passing the uploaded data as an argument
  callModule(server_workload_summary, "workload_summary", data = uploaded_data)
}

# Run the application
shinyApp(ui = ui, server = server)
