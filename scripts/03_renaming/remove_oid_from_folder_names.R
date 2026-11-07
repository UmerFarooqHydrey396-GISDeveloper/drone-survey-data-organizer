# ============================================================
# CONFIGURATION
# ============================================================
# 1. Set your path here (Keep your path exactly as you had it before)
main_directory <-"C:/path/to/your/folder"

# 2. SAFETY LOCK IS NOW OFF
dry_run <- FALSE 

# ============================================================
# SCRIPT
# ============================================================

folders <- list.dirs(path = main_directory, full.names = TRUE, recursive = FALSE)
count <- 0

message("Starting renaming process...")
message("---------------------")

for (folder_path in folders) {
  
  old_name <- basename(folder_path)
  parent_dir <- dirname(folder_path)
  
  # Check for pattern: Digits_Digits_Name (e.g., 7_14_Name)
  if (grepl("^\\d+_\\d+_", old_name)) {
    
    # Remove the "7_14_" part
    clean_name <- sub("^\\d+_\\d+_", "", old_name)
    
    # Clean up spaces
    clean_name <- trimws(clean_name)
    clean_name <- sub("^_", "", clean_name)
    
    new_full_path <- file.path(parent_dir, clean_name)
    
    # Rename if the names are different
    if (old_name != clean_name) {
      if (dry_run) {
        message(paste("[PREVIEW] Would rename:", old_name, " -> ", clean_name))
      } else {
        # Check if destination already exists to prevent errors
        if (dir.exists(new_full_path)) {
          warning(paste("SKIPPED:", old_name, "-> Target folder '", clean_name, "' already exists."))
        } else {
          # PERFORM THE RENAME
          file.rename(from = folder_path, to = new_full_path)
          count <- count + 1
          message(paste("Renamed:", old_name, " -> ", clean_name))
        }
      }
    }
  }
}

message("---------------------")
message(paste("Success! Renamed", count, "folders."))
