library(fs)

# ==========================================
# CONFIGURATION
# ==========================================
main_folders_path <-"C:/path/to/your/folder"

# ==========================================
# EXECUTION
# ==========================================

# 1. Get list of all main project folders
main_folders <- dir_ls(main_folders_path, type = "directory")

# Initialize vectors to store results
empty_folders <- c()
good_folders <- 0

print(paste("Checking", length(main_folders), "folders for ECW data..."))
print("---------------------------------------------------")

for (folder in main_folders) {
  
  # Construct path to the ECW subfolder
  ecw_subfolder <- path(folder, "ECW")
  
  # Check if the ECW subfolder actually exists
  if (dir_exists(ecw_subfolder)) {
    
    # Look for actual .ecw files inside (ignoring .prj or .eww for now)
    # length() counts how many files were found
    ecw_files <- dir_ls(ecw_subfolder, regexp = "\\.ecw$", ignore.case = TRUE)
    
    if (length(ecw_files) == 0) {
      # Record the name of the folder that has no ECW
      empty_folders <- c(empty_folders, path_file(folder))
    } else {
      good_folders <- good_folders + 1
    }
    
  } else {
    # If the 'ECW' folder doesn't even exist
    empty_folders <- c(empty_folders, paste(path_file(folder), "(No ECW subfolder found)"))
  }
}

# ==========================================
# REPORT
# ==========================================

print(paste("✅ Folders with ECW files:", good_folders))
print(paste("❌ Folders MISSING ECW files:", length(empty_folders)))

if (length(empty_folders) > 0) {
  print("---------------------------------------------------")
  print("The following folders are missing .ecw files:")
  print(empty_folders)
} else {
  print("---------------------------------------------------")
  print("Great! All folders contain at least one .ecw file.")
}
