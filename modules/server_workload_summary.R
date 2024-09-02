# Load necessary libraries
library(dplyr)   # For data manipulation
library(tidyr)   # For reshaping data
library(ggplot2) # For creating plots

# Server function for workload summary
server_workload_summary <- function(input, output, session, data) {
  ns <- session$ns  # Namespace for modularity
  
  # Reactive expression to transform the uploaded data into a 'long' format
  transformed_data <- reactive({
    req(data())  # Ensure the data is available before proceeding
    
    print("Data upload successful. Starting data transformation...")  # Debugging print
    
    # Handle missing values and convert to numeric if necessary
    data_clean <- data()
    data_clean[data_clean == "#N/A"] <- NA  # Replace "#N/A" with NA
    data_clean[, 4:ncol(data_clean)] <- lapply(data_clean[, 4:ncol(data_clean)], as.numeric)  # Convert to numeric
    
    # Convert numeric column names to date strings (Excel date serial to "MMM-YY")
    date_columns <- colnames(data_clean)[4:ncol(data_clean)]  # Identify the date columns
    colnames(data_clean)[4:ncol(data_clean)] <- format(as.Date(as.numeric(date_columns), origin = "1899-12-30"), "%b-%y")
    
    # Debugging print to confirm date conversion
    print("Column names after date conversion:")
    print(colnames(data_clean)[4:ncol(data_clean)])
    
    # Convert data to long format using headers from column 4 onwards
    data_long <- data_clean %>%
      pivot_longer(
        cols = 4:ncol(data_clean),  # Select all columns starting from the 4th one onward
        names_to = "Date",          # Use 'Date' to keep header names (MMM-YY format) in a new column
        values_to = "Workload"      # Store corresponding data in 'Workload' column
      ) %>%
      mutate(
        # Extract month and year from the 'Date' column, assuming 'Date' is 'MMM-YY' format
        Month = factor(
          substr(Date, 1, 3),  # Extract 'MMM' from 'MMM-YY'
          levels = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"),
          ordered = TRUE
        ),
        Year = paste0("20", substr(Date, 5, 6))  # Extract 'YY' from 'MMM-YY' and prepend '20'
      )
    
    # Debugging print to confirm data transformation
    print("Data transformation complete:")
    print(head(data_long))  # Print the first few rows of the transformed data
    
    # Return the transformed data
    data_long
  })
  
  # Update the dropdown choices dynamically based on the uploaded data
  observeEvent(data(), {
    req(data())  # Ensure data is available
    print("Updating dropdown choices based on uploaded data...")  # Debugging print
    updateSelectInput(session, "classification2", choices = unique(data()$InternalClassification))  # Update dropdown choices
    
    # Debugging print to confirm dropdown update
    print("Dropdown choices updated:")
    print(unique(data()$InternalClassification))
  })
  
  # Plot output
  output$workload_summary_plot <- renderPlot({
    req(input$classification2)
    
    print(paste("Rendering plot for classification:", input$classification2))  # Debugging print
    
    # Filter the transformed data based on the user's selection from the dropdown menu
    filtered_data <- transformed_data() %>%
      filter(InternalClassification == input$classification2)
    
    # Check if filtered_data is empty
    if (nrow(filtered_data) == 0) {
      print("Filtered data is empty. No plot will be generated.")
      return(NULL)  # Exit if there's no data to plot
    }
    
    # Create a line plot for the filtered data, facetted by 'Assay'
    plot <- ggplot(filtered_data, aes(x = Month, y = Workload, group = Year, color = as.factor(Year))) +
      geom_line(aes(size = Year == max(as.numeric(Year), na.rm = TRUE))) +  # Highlight the most recent year's line
      scale_size_manual(values = c(`FALSE` = 0.5, `TRUE` = 1)) +  # Set line sizes for older and most recent years
      facet_wrap(~ Assay, scales = "free_y") +  # Create separate panels for each 'Assay'
      labs(
        title = paste("Monthly Test Count for Internal Classification:", input$classification2),
        x = "Month",
        y = "Test Count",
        color = "Year"
      ) +
      theme_minimal() +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),  # Rotate x-axis labels for readability
        legend.position = "bottom"  # Place legend at the bottom of the plot
      )
    
    plot  # Return the plot
  })
}
