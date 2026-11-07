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

# 3. Define the source directories for your data.
#    IMPORTANT: The names on the left (e.g., "Aerial Orthoimage") MUST EXACTLY
#    match the subfolder names defined below.
#    Update the paths on the right to point to your source data folders.
source_directories <- list(
  "Aerial Orthoimage" = "source_orthoimages",
  "Aoi" = "C:/path/to/your/folder", # <-- ADD THE PATH TO YOUR AOI FOLDER HERE
  "Digital Surface Model (DSM)" = "source_dsm",
  "Digitized Parcels" = "gdb_source_files", # This was the original GDB source
  "Ecw" = "source_ecw",
  "Ground Control Points (GCP)" = "source_gcp"
)

# 4. Define the subfolders you want to create in each main folder.
subfolder_names <- names(source_directories)


# --- Script Logic ---

# Create the main output directory if it doesn't exist.
if (!dir.exists(output_directory_path)) {
  cat("Output directory not found. Creating it now at:", output_directory_path, "\n")
  dir.create(output_directory_path, recursive = TRUE)
}

# Check that all source directories exist before starting.
for (path in source_directories) {
  if (!dir.exists(path)) {
    warning("Source directory not found: ", path, ". The script will continue but may not find files to copy.")
  }
}

# Initialize a vector to store the paths of any subfolders that remain empty.
empty_folders_report <- c()

# Try to read the Excel file and process the data.
tryCatch({
  data <- read_excel(excel_file_path)
  
  # Check if required columns exist in the Excel file.
  if (!("OID" %in% names(data) && "Name" %in% names(data))) {
    stop("The Excel file must contain 'OID' and 'Name' columns.")
  }
  
  cat("Successfully read", nrow(data), "rows from", excel_file_path, "\n\n")
  
  # Loop through each row of the data frame (each location).
  for (i in 1:nrow(data)) {
    current_id <- data$OID[i]
    current_name <- data$Name[i]
    clean_name <- gsub("[[:punct:] ]+", "_", current_name)
    folder_name <- paste(current_id, clean_name, sep = "_")
    full_folder_path <- file.path(output_directory_path, folder_name)
    
    # Create the main folder for the location.
    if (!dir.exists(full_folder_path)) {
      dir.create(full_folder_path)
      cat("Created main folder:", full_folder_path, "\n")
    } else {
      cat("Main folder already exists:", full_folder_path, "\n")
    }
    
    # --- Create Subfolders and Copy Data ---
    for (subfolder in subfolder_names) {
      # Create the subfolder.
      full_subfolder_path <- file.path(full_folder_path, subfolder)
      if (!dir.exists(full_subfolder_path)) {
        dir.create(full_subfolder_path)
        cat("  - Created subfolder:", subfolder, "\n")
      } else {
        cat("  - Subfolder already exists:", subfolder, "\n")
      }
      
      # --- Copy corresponding data ---
      source_dir <- source_directories[[subfolder]]
      if (dir.exists(source_dir)) {
        # Define the file pattern to look for (e.g., "1_112_Tanween")
        file_pattern <- paste0(current_id, "_", current_name)
        all_source_contents <- list.files(source_dir)
        
        # Find all files/folders in the source directory that match the pattern.
        contents_to_copy <- all_source_contents[startsWith(all_source_contents, file_pattern)]
        
        if (length(contents_to_copy) > 0) {
          for (item_name in contents_to_copy) {
            source_item_path <- file.path(source_dir, item_name)
            is_dir <- dir.exists(source_item_path)
            
            # Use file.copy to copy the item. 'recursive=TRUE' is needed for directories.
            if (file.copy(from = source_item_path, to = full_subfolder_path, recursive = is_dir)) {
              cat("    - Copied:", item_name, "\n")
            } else {
              cat("    - FAILED to copy:", item_name, "\n")
            }
          }
        } else {
          cat("    - No matching files found in", source_dir, "for pattern:", file_pattern, "\n")
        }
      }
    }
    cat("\n")
  }
  
  cat("Folder creation and file copying process completed.\n\n")
  
  # --- Final Check for Empty Folders ---
  cat("--- Checking for empty subfolders ---\n")
  for (i in 1:nrow(data)) {
    current_id <- data$OID[i]
    current_name <- data$Name[i]
    clean_name <- gsub("[[:punct:] ]+", "_", current_name)
    folder_name <- paste(current_id, clean_name, sep = "_")
    full_folder_path <- file.path(output_directory_path, folder_name)
    
    for (subfolder in subfolder_names) {
      full_subfolder_path <- file.path(full_folder_path, subfolder)
      if (length(list.files(full_subfolder_path)) == 0) {
        empty_folders_report <- c(empty_folders_report, full_subfolder_path)
      }
    }
  }
  
  # --- Display Final Report ---
  if (length(empty_folders_report) > 0) {
    cat("\nWARNING: The following subfolders were found to be empty:\n")
    for (empty_path in empty_folders_report) {
      cat("- ", empty_path, "\n")
    }
  } else {
    cat("\nSUCCESS: All created subfolders contain files or directories.\n")
  }
  
}, error = function(e) {
  cat("An error occurred:", e$message, "\n")
})
