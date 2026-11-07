
# --- Libraries ---
library(fs)
library(tools) # Using tools for file_path_sans_ext

# --- Paths ---
source_dir <- "C:/path/to/your/folder"      # folder containing .tif, .tfw, etc.
target_dir <- "C:/path/to/your/folder" # main folder with matching folders

# --- Logic ---
# List all files (tif, tfw, prj)
source_files <- dir_ls(source_dir, regexp = "\\.(tif|tfw|prj)$", type = "file")

cat("Starting to process", length(source_files), "files...\n\n")

for (current_file_path in source_files) {
  file_name <- basename(current_file_path)
  
  # Extract core name (e.g., "27_14_Kammanwala_Ortho")
  file_core <- tools::file_path_sans_ext(file_name)
  
  # --- THIS IS THE KEY FIX ---
  # Remove the "_Ortho" suffix to get the matching folder name
  # e.g., "27_14_Kammanwala_Ortho" becomes "27_14_Kammanwala"
  match_name <- sub("_DSM$", "", file_core)
  
  # --- THIS IS THE SECOND FIX ---
  # Build the full path to the target folder we expect to find
  target_main_folder <- path(target_dir, match_name)
  
  # Check if that *specific* folder actually exists
  if (dir_exists(target_main_folder)) {
    
    # Path to "Aerial Orthoimage" subfolder
    # NOTE: Using path() is safer than file.path() with fs
    target_sub_folder <- path(target_main_folder, "Digital Surface Model (DSM)")
    
    # Create subfolder if missing
    if (!dir_exists(target_sub_folder)) {
      dir_create(target_sub_folder)
    }
    
    # Copy file
    file_copy(current_file_path, target_sub_folder, overwrite = TRUE)
    cat("✅ Copied:", file_name, "→", target_sub_folder, "\n")
    
  } else {
    # This will now correctly tell you if a folder is missing
    cat("❌ Folder not found for:", file_name, "(Looked for:", target_main_folder, ")\n")
  }
}

cat("\n--- Process Complete ---\n")
