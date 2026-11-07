# Title: R Script to Remove a Suffix from Folder Names
# Description: This script iterates through all folders in a specified directory
#              and removes a defined suffix (e.g., "_Ortho") from their names.

# --- Library Management ---
# Uses the 'fs' package for modern and reliable file system operations.
if (!requireNamespace("fs", quietly = TRUE)) {
  install.packages("fs")
}
library(fs)


# --- Configuration ---

# 1. Set the path to the directory containing the folders you want to rename.
parent_directory_path <- "C:/path/to/your/folder"

# 2. Define the exact suffix you want to remove.
suffix_to_remove <- "_Ortho"


# --- Script Logic ---

# Stop if the target directory doesn't exist.
if (!dir_exists(parent_directory_path)) {
  stop("Error: The specified directory does not exist: ", parent_directory_path)
}

# Get a list of all FOLDERS (not files) in the directory.
all_folders <- dir_ls(parent_directory_path, type = "directory")

if (length(all_folders) == 0) {
  cat("No folders found in the specified directory. Nothing to do.\n")
} else {
  cat("Scanning", length(all_folders), "folders to find names ending with '", suffix_to_remove, "'...\n\n", sep = "")
  
  # Loop through each folder path found.
  for (current_folder_path in all_folders) {
    
    # Get just the folder name from the full path (e.g., "Project1_Ortho").
    original_folder_name <- path_file(current_folder_path)
    
    # Check if the folder name actually ends with the specified suffix.
    if (endsWith(original_folder_name, suffix_to_remove)) {
      
      # Create the new name by removing the suffix.
      # Using gsub with "$" ensures we only match the suffix at the very end.
      new_folder_name <- gsub(paste0(suffix_to_remove, "$"), "", original_folder_name)
      
      # Construct the full new path for the renamed folder.
      new_folder_path <- path(path_dir(current_folder_path), new_folder_name)
      
      # Perform the rename operation.
      file_move(current_folder_path, new_folder_path)
      
      cat("✅ Renamed:", original_folder_name, "→", new_folder_name, "\n")
      
    } else {
      # This message is helpful for confirming the script is checking all folders.
      cat("- Skipping (name does not end with suffix):", original_folder_name, "\n")
    }
  }
  
  cat("\nFolder renaming process complete.\n")
}
