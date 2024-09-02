# ui_data_upload.R

# Function to create the user interface for the data upload module
ui_data_upload <- function(id) {
  ns <- NS(id)  # Create a namespace function for the module
  
  # UI layout for data upload
  tagList(
    # File input widget for uploading Excel files
    fileInput(ns("file1"), "Choose Excel File",
              accept = c(".xlsx")),
    # Checkbox for indicating if the file has a header row
    checkboxInput(ns("header"), "Header", TRUE),
    # Button to trigger the file upload
    actionButton(ns("uploadButton"), "Upload File"),
    # Output for displaying upload status or messages
    verbatimTextOutput(ns("uploadStatus"))
  )
}
