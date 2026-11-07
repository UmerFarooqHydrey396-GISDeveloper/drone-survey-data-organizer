# --- Load Libraries ---
library(fs)
library(tidyverse) # For data manipulation (dplyr, stringr, tidyr)
library(writexl)   # For writing to .xlsx files

# --- 1. Configuration ---

main_folder <- "C:/path/to/your/folder"
output_file <- "C:/path/to/your/file.xlsx"

subfolders_to_check <- c(
  "Aerial Orthoimage", 
  "Aoi", 
  "Ecw", 
  "Digital Surface Model (DSM)", 
  "Digitized parcels"
)

# --- 2. Helper Function (No changes) ---
check_status <- function(subfolder_path) {
  if (!dir_exists(subfolder_path)) {
    return("Missing")
  }
  if (length(dir_ls(subfolder_path)) == 0) {
    return("Empty")
  }
  return("OK")
}

# --- 3. Main Script Logic ---
cat("Scanning folders in:", main_folder, "\n")
main_folder_paths <- dir_ls(main_folder, type = "directory")

if (length(main_folder_paths) == 0) {
  cat("No main folders found in:", main_folder, "\n")
} else {
  cat("Found", length(main_folder_paths), "main folders to process...\n")
  
  # --- 4. Build the Data Table ---
  
  # --- Part A: Get OID, Name, and full_path (Same as before) ---
  base_data <- tibble(full_path = main_folder_paths) %>%
    mutate(
      original_filename = path_file(full_path),
      clean_name = path_ext_remove(original_filename),
      clean_name = str_remove_all(clean_name, "_Ortho$|_Aoi$"),
      OID = str_extract(clean_name, "^[0-9]+_[0-9]+"),
      Name = str_remove(clean_name, "^[0-9]+_[0-9]+_"),
      Name = str_replace_all(Name, "_", " ")
    )
  
  # --- Part B: NEW "TIDY" METHOD to get folder status ---
  
  # 1. Create all combinations of main folders and subfolders
  status_data <- expand_grid(
    full_path = main_folder_paths, 
    subfolder = subfolders_to_check
  ) %>%
    
    # 2. Build the full path for each combination
    mutate(
      full_subfolder_path = path(full_path, subfolder)
    ) %>%
    
    # 3. Apply our check_status function to every path
    #    map_chr is a fast way to apply a function and get a text result
    mutate(
      status = map_chr(full_subfolder_path, check_status)
    ) %>%
    
    # 4. We only need the main path, the subfolder name, and its status
    select(full_path, subfolder, status) %>%
    
    # 5. "Pivot" the table: make subfolder names the new columns
    pivot_wider(
      names_from = subfolder,
      values_from = status
    )
  
  # --- Part C: Join the two tables together ---
  # This merges the OID/Name data with the new Status columns
  
  report_data <- left_join(base_data, status_data, by = "full_path") %>%
    
    # Re-order the columns to be nice in Excel
    select(
      OID, 
      Name, 
      all_of(subfolders_to_check), # Puts all our new status columns here
      original_filename,
      full_path
    )
  
  # --- 5. Write to Excel (Same as before) ---
  write_xlsx(report_data, path = output_file)
  
  cat("\n✅ Success! Excel report created at:\n", output_file, "\n")
  
  # Show the first few rows of the result
  print(report_data)
}
