# Title: R Script to Normalize and Organize Digitized Parcels
# Description: This script performs a two-step process:
#              1. RENAMES all files/folders in a source directory by replacing
#                 spaces with underscores to ensure consistent naming.
#              2. MOVES the renamed items into the correct 'Digitized Parcels'
#                 subfolder within a target project structure.
# Version: 2.0 (with robust error handling)

# --- Library Management ---
if (!requireNamespace("fs", quietly = TRUE)) {
  install.packages("fs")
}
library(fs)

# --- Configuration ---

# 1. Path to the folder containing your source files (shapefiles, GDBs, etc.).
source_dir <- "C:/path/to/your/folder"

# 2. Path to the main directory containing your project folders (e.g., "OID_Names").
target_dir <- "C:/path/to/your/folder" #<-- Assumed from history

# 3. The name of the specific subfolder where these files should be placed.
subfolder_to_move_into <- "Digitized Parcels"

# --- Script Logic ---

if (!dir_exists(source_dir)) {
  stop("Error: The source directory does not exist: ", source_dir)
}

# --- STEP 1: NORMALIZE FILENAMES (Replace Spaces with Underscores) ---
cat("--- Step 1: Normalizing filenames in source directory ---\n")

all_items_in_source <- dir_ls(source_dir)
renamed_count <- 0

for (item_path in all_items_in_source) {
  original_name <- path_file(item_path)
  
  if (grepl(" ", original_name, fixed = TRUE)) {
    new_name <- gsub(" ", "_", original_name)
    new_path <- path(path_dir(item_path), new_name)
    
    tryCatch({
      file_move(item_path, new_path)
      cat("✅ Renamed:", original_name, "→", new_name, "\n")
      renamed_count <- renamed_count + 1
    }, error = function(e) {
      cat(
        "❌ FAILED to rename:", original_name, "\n",
        "   Reason:", e$message, "\n",
        "   Suggestion: Please close any programs using this file and try again.\n"
      )
    })
  }
}
if (renamed_count == 0) {
  cat("No files needed renaming.\n")
}
cat("--- Step 1 Complete ---\n\n")


# --- STEP 2: ORGANIZE NORMALIZED FILES INTO PROJECT FOLDERS ---
cat("--- Step 2: Organizing files into project folders ---\n")

items_to_move <- dir_ls(source_dir, regexp = "\\.(gdb|shp|shx|dbf|prj|sbn|sbx|cpg|xml)$")

if (length(items_to_move) == 0) {
  cat("No parcel files or folders found to organize.\n")
} else {
  cat("Found", length(items_to_move), "items to organize...\n\n")
  
  for (current_item_path in items_to_move) {
    item_name <- path_file(current_item_path)
    main_folder_name <- path_ext_remove(item_name)
    
    target_main_folder_path <- path(target_dir, main_folder_name)
    
    if (dir_exists(target_main_folder_path)) {
      destination_subfolder_path <- path(target_main_folder_path, subfolder_to_move_into)
      dir_create(destination_subfolder_path)
      
      tryCatch({
        file_move(current_item_path, destination_subfolder_path)
        cat("✅ Moved:", item_name, "→", main_folder_name, "/", subfolder_to_move_into, "\n")
      }, error = function(e) {
        cat(
          "❌ FAILED to move:", item_name, "\n",
          "   Reason:", e$message, "\n",
          "   Suggestion: Please close any programs (like ArcGIS) using this file and try again.\n"
        )
      })
      
    } else {
      cat("❌ Error: Main folder '", main_folder_name, "' not found for item '", item_name, "'. Skipping.\n", sep = "")
    }
  }
}

cat("\n--- Step 2 Complete. Organization process finished. ---\n")
