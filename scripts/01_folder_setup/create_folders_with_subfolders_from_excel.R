# Title: R Script to Create Folders from an Excel List
# --- Library Management ---
# This script requires the 'readxl' package to read Excel files.
# The following code checks if it's installed and installs it if not.
if (!requireNamespace("readxl", quietly = TRUE)) {
  install.packages("readxl")
}
library(readxl)


# --- Configuration ---

# 1. Set the path to your input Excel file.
#    Replace "data.xlsx" with the actual path to your file.
excel_file_path <- "C:/path/to/your/file.xlsx"

# 2. Set the path where you want to create the new folders.
#    Replace "output_folders" with your desired directory path.
output_directory_path <- "C:/path/to/your/folder"

# 3. Define the subfolders you want to create in each main folder.
subfolder_names <- c(
  "Aerial Orthoimage",
  "Aoi",
  "Digital Surface Model (DSM)",
  "Digitized Parcels",
  "Ecw",
  "Ground Control Points (GCP)"
)


# --- Script Logic ---

# Check if the output directory exists, if not, create it.
if (!dir.exists(output_directory_path)) {
  cat("Output directory not found. Creating it now at:", output_directory_path, "\n")
  dir.create(output_directory_path, recursive = TRUE)
}

# Try to read the Excel file, and handle potential errors.
tryCatch({
  # Read the data from the Excel file.
  # Assumes your Excel sheet has columns named 'OID' and 'Name'.
  # If your column names are different, change them in the code below.
  data <- read_excel(excel_file_path)
  
  # Check if required columns exist
  if (!("OID" %in% names(data) && "Name" %in% names(data))) {
    stop("The Excel file must contain 'OID' and 'Name' columns.")
  }
  
  cat("Successfully read", nrow(data), "rows from", excel_file_path, "\n\n")
  
  # Loop through each row of the data frame.
  for (i in 1:nrow(data)) {
    # Get the OID and Name from the current row.
    current_id <- data$OID[i]
    current_name <- data$Name[i]
    
    # Create a clean and valid folder name (e.g., "1_112_Tanween").
    # The gsub function removes characters that are problematic in folder names.
    clean_name <- gsub("[[:punct:] ]+", "_", current_name)
    folder_name <- paste(current_id, clean_name, sep = "_")
    
    # Construct the full path for the new folder.
    full_folder_path <- file.path(output_directory_path, folder_name)
    
    # Check if the main folder already exists before creating it.
    if (!dir.exists(full_folder_path)) {
      dir.create(full_folder_path)
      cat("Created main folder:", full_folder_path, "\n")
    } else {
      cat("Main folder already exists:", full_folder_path, "\n")
    }
    
    # --- Create Subfolders ---
    # Loop through the list of subfolder names and create them.
    for (subfolder in subfolder_names) {
      full_subfolder_path <- file.path(full_folder_path, subfolder)
      if (!dir.exists(full_subfolder_path)) {
        dir.create(full_subfolder_path)
        cat("  - Created subfolder:", subfolder, "\n")
      } else {
        cat("  - Subfolder already exists:", subfolder, "\n")
      }
    }
    cat("\n") # Add a blank line for better readability in the console
  }
  
  cat("Folder creation process completed successfully.\n")
  
}, error = function(e) {
  # This block runs if an error occurs (e.g., file not found).
  cat("An error occurred:", e$message, "\n")
})
