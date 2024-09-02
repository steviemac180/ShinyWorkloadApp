# Load necessary libraries
library(readxl)  # For reading Excel files
library(dplyr)   # For data manipulation

# Server function for data upload
server_data_upload <- function(input, output, session) {
  ns <- session$ns
  
  # Reactive value to store the uploaded data
  uploaded_data <- reactiveVal(NULL)
  
  observeEvent(input$file1, {  # Trigger on file input
    req(input$file1)  # Ensure a file has been uploaded
    
    tryCatch({
      # Determine file extension to decide which function to use for reading the file
      file_extension <- tools::file_ext(input$file1$name)
      
      # Read the file based on its extension
      if (file_extension == "xlsx") {
        # Read Excel file
        data <- read_excel(input$file1$datapath, col_names = input$header)
      } else if (file_extension == "csv") {
        # Read CSV file
        data <- read.csv(input$file1$datapath, header = input$header)
      } else {
        stop("Unsupported file type. Please upload a .xlsx or .csv file.")
      }
      
      # Debugging print
      print("File read successfully:")
      print(head(data))  # Print the first few rows of the data
      
      # Ensure required columns ("Assay", "Classification", "InternalClassification") are present
      required_columns <- c("Assay", "Classification", "InternalClassification")  # Consistent column names
      if (!all(required_columns %in% colnames(data))) {
        stop("The uploaded file must contain the following columns: Assay, Classification, InternalClassification.")
      }
      
      # Replace missing values with 0 only in numeric columns
      numeric_columns <- sapply(data, is.numeric)  # Identify numeric columns
      data[, numeric_columns] <- lapply(data[, numeric_columns], function(x) {
        x[is.na(x)] <- 0
        return(x)
      })
      
      # Store the cleaned data
      uploaded_data(data)
      showNotification("File uploaded and processed successfully!", type = "message")
      
      # Debugging print to confirm data upload
      print("Data stored in reactive value successfully.")
      
    }, error = function(e) {
      showNotification(paste("Error uploading file:", e$message), type = "error")
    })
  })
  
  return(uploaded_data)
}
