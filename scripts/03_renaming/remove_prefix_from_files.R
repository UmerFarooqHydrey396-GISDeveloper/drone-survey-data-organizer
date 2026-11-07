# Load the modern 'fs' library for file system operations
library(fs)

# Set your folder path
folder_path <- "C:/path/to/your/folder" # <-- Change this to your folder path

# --- Find all files ending in .tif OR .tfw ---
# The key change is the regular expression in `regexp`.
# "\\.(tif|tfw)$" means "match a dot, followed by either 'tif' or 'tfw' at the end of the filename."
files_to_rename <- dir_ls(folder_path, regexp = "\\.(tif|tfw|prj)$", type = "file")

# Check if any files were found
if (length(files_to_rename) == 0) {
  cat("No .tif or .tfw files found in the specified folder.\n")
} else {
  cat("Found", length(files_to_rename), "files to process...\n\n")
  
  # Loop through each file and rename it
  for (current_file_path in files_to_rename) {
    # Get just the filename from the full path
    original_filename <- path_file(current_file_path)
    
    # Create the new filename by removing "E_"
    new_filename <- gsub("E_", "", original_filename)
    
    # Rebuild the full path for the new name
    new_file_path <- path(path_dir(current_file_path), new_filename)
    
    # Only rename if the name is actually different
    if (current_file_path != new_file_path) {
      file_move(current_file_path, new_file_path)
      cat("✅ Renamed:", original_filename, "→", new_filename, "\n")
    }
  }
  
  cat("\nDone! All files have been processed.\n")
}
