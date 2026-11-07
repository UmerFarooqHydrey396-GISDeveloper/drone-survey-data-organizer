# Title: R Script to Create a Main Folder and Subfolders from Filenames
# Description: This script reads filenames from a source directory, creates a 
#              main parent folder for each unique filename, and then creates a 
#              pre-defined set of subfolders within each main folder.

# --- Library Management ---
# Uses the 'fs' package for modern and reliable file system operations.
if (!requireNamespace("fs", quietly = TRUE)) {
  install.packages("fs")
}
library(fs)


# --- Configuration ---

# 1. Set the path to the folder containing your files (e.g., "1_Project_Alpha.tif").
#    Replace this with the actual path to your files.
source_directory_path <- "C:/path/to/your/folder"

# 2. Set the path where you want to create the new main folders.
#    This can be the same as the source directory or a different one.
output_directory_path <- "C:/path/to/your/folder"


# 3. Define the list of subfolders to be created inside EACH main folder.
#    You can add or remove names from this list as needed.
subfolder_names <- c(
  "Aerial Orthoimage",
  "Aoi",
  "Digital Surface Model (DSM)",
  "Digitized Parcels",
  "Ecw",
  "Ground Control Points (GCP)"
)


# --- Script Logic ---

# Stop if the source directory doesn't exist.
if (!dir_exists(source_directory_path)) {
  stop("Error: The source directory does not exist at: ", source_directory_path)
}

# Create the main output directory if it doesn't exist.
if (!dir_exists(output_directory_path)) {
  cat("Output directory not found. Creating it at:", output_directory_path, "\n\n")
  dir_create(output_directory_path)
}

# Get a list of all files in the source directory.
all_files <- dir_ls(source_directory_path, type = "file")

if (length(all_files) == 0) {
  cat("No files found in the source directory. Exiting script.\n")
} else {
  # Extract the unique base names (e.g., "10_1_Jalalpur_Sobtain").
  file_base_names <- path_ext_remove(path_file(all_files))
  unique_main_folder_names <- unique(file_base_names)
  
  cat("Found", length(unique_main_folder_names), "unique names to create project folders for.\n\n")
  
  # --- Main Loop: Create folder structure for each unique name ---
  for (main_name in unique_main_folder_names) {
    
    # 1. Create the full path for the main project folder.
    main_folder_path <- path(output_directory_path, main_name)
    
    # Create the main folder if it doesn't exist.
    if (!dir_exists(main_folder_path)) {
      dir_create(main_folder_path)
      cat("✅ Created main folder:", main_name, "\n")
    } else {
      cat("- Main folder already exists:", main_name, "\n")
    }
    
    # 2. Loop through the subfolder list and create them inside the main folder.
    for (sub_name in subfolder_names) {
      subfolder_path <- path(main_folder_path, sub_name)
      
      if (!dir_exists(subfolder_path)) {
        dir_create(subfolder_path)
        # The "└──" makes the output easier to read.
        cat("  └── Created subfolder:", sub_name, "\n")
      }
    }
    cat("\n") # Add a space for readability in the console.
  }
  
  cat("Folder creation process complete.\n")
}
