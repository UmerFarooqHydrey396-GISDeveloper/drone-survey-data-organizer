# ==========================================
# 1. SETUP & LIBRARIES
# ==========================================
if (!require("fs")) install.packages("fs")
if (!require("stringr")) install.packages("stringr")
if (!require("writexl")) install.packages("writexl")

library(fs)
library(stringr)
library(writexl)

# ==========================================
# 2. CONFIGURATION: PATHS
# ==========================================

paths_to_check <- c(
  "C:/path/to/your/folder_1",
  "C:/path/to/your/folder_2"
)

# Output Path (Ensure user has permission to write here)
output_excel_path <- "C:/path/to/your/file.xlsx" 


# ==========================================
# 3. HELPER FUNCTION: CHECK STATUS
# ==========================================
# This checks if a folder exists and if it has content
get_folder_status <- function(parent_dir, subfolder_name, specific_ext = NULL) {
  
  target <- path(parent_dir, subfolder_name)
  
  if (!dir_exists(target)) {
    return("MISSING FOLDER")
  }
  
  # List files inside
  if (!is.null(specific_ext)) {
    # If checking for specific extension (like .ecw)
    files <- dir_ls(target, regexp = specific_ext, ignore.case = TRUE)
  } else {
    # Otherwise check for ANY file
    files <- dir_ls(target)
  }
  
  if (length(files) > 0) {
    return("OK")
  } else {
    return("FOLDER EMPTY")
  }
}

# ==========================================
# 4. MAIN PROCESSING FUNCTION
# ==========================================

process_single_path <- function(target_path) {
  
  # Safety Check
  if (!dir_exists(target_path)) {
    warning(paste("Path not found:", target_path))
    return(data.frame(Folder_Name = "PATH NOT FOUND", Extracted_ID = NA, Path_Location = target_path))
  }
  
  # Get Main Folders
  main_folders <- dir_ls(target_path, type = "directory")
  
  # Initialize Lists to build DataFrame later
  results_list <- list()
  
  for (folder in main_folders) {
    
    folder_name <- path_file(folder)
    
    # --- A. ID EXTRACTION LOGIC ---
    id_pattern <- "\\d+_\\d+"
    extracted_id <- str_extract(folder_name, id_pattern)
    
    # Check inside ECW folder for ID if missing in folder name
    ecw_path <- path(folder, "ECW")
    if (is.na(extracted_id) && dir_exists(ecw_path)) {
      ecw_files <- dir_ls(ecw_path, regexp = "\\.ecw$", ignore.case = TRUE)
      if (length(ecw_files) > 0) {
        extracted_id <- str_extract(path_file(ecw_files[1]), id_pattern)
      }
    }
    if (is.na(extracted_id)) extracted_id <- "No ID Found"
    
    # --- B. CHECK SUBFOLDERS ---
    
    # 1. Aerial Orthoimage
    stat_ortho <- get_folder_status(folder, "Aerial Orthoimage")
    
    # 2. Drone Imagery Output
    stat_drone <- get_folder_status(folder, "Drone Imagery Output")
    
    # 3. Digital Surface Model (DSM)
    stat_dsm_long <- get_folder_status(folder, "Digital Surface Model (DSM)")
    
    # 4. DSM (Short name check)
    stat_dsm_short <- get_folder_status(folder, "DSM")
    
    # 5. Digitized Parcels
    stat_parcels <- get_folder_status(folder, "Digitized Parcels")
    
    # 6. ECW (Strict check for .ecw extension)
    stat_ecw <- get_folder_status(folder, "ECW", specific_ext = "\\.ecw$")
    
    
    # --- C. SAVE ROW ---
    results_list[[length(results_list) + 1]] <- data.frame(
      Folder_Name = folder_name,
      Extracted_ID = extracted_id,
      Aerial_Orthoimage = stat_ortho,
      Drone_Imagery_Output = stat_drone,
      Digital_Surface_Model_DSM = stat_dsm_long,
      DSM = stat_dsm_short,
      Digitized_Parcels = stat_parcels,
      ECW_Status = stat_ecw,
      Path_Location = target_path,
      stringsAsFactors = FALSE
    )
  }
  
  # Combine all rows
  if (length(results_list) > 0) {
    return(do.call(rbind, results_list))
  } else {
    return(data.frame(Status = "No subfolders found", Path = target_path))
  }
}

# ==========================================
# 5. EXECUTION LOOP
# ==========================================

print("Starting Multi-District QC Check...")
final_sheets_list <- list()

for (i in seq_along(paths_to_check)) {
  
  current_path <- paths_to_check[i]
  print(paste("Processing [", i, "/", length(paths_to_check), "]:", path_file(current_path)))
  
  # Run Analysis
  folder_data <- process_single_path(current_path)
  
  # Name the Sheet (cleaned)
  sheet_name <- str_sub(path_file(current_path), 1, 30) # Limit to 30 chars for Excel
  sheet_name <- str_replace_all(sheet_name, "[^[:alnum:]]", "_") # Remove special chars
  
  # Handle duplicates
  if (sheet_name %in% names(final_sheets_list)) {
    sheet_name <- paste(sheet_name, i, sep = "_")
  }
  
  final_sheets_list[[sheet_name]] <- folder_data
}

# ==========================================
# 6. EXPORT
# ==========================================

print("Writing to Excel...")
write_xlsx(final_sheets_list, output_excel_path)

print("---------------------------------------------------")
print(paste("✅ QC Complete! Report saved to:", output_excel_path))
