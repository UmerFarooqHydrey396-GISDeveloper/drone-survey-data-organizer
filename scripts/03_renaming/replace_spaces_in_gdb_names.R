library(fs)

# Set your main folder path
main_dir <- "C:/path/to/your/folder" # ← Your folder path

# List ALL paths (files AND folders) recursively
all_paths <- dir_ls(main_dir, recurse = TRUE)

# --- CRITICAL STEP ---
# Sort paths by character count, from longest to shortest.
# This ensures we rename items "inside-out" (e.g., "folder with space/file.txt" 
# gets renamed BEFORE "folder with space" itself). This prevents errors.
all_paths_sorted <- all_paths[order(nchar(all_paths), decreasing = TRUE)]

cat("Found", length(all_paths_sorted), "files and folders to check...\n\n")

# Loop through each path and rename
for (p in all_paths_sorted) {
  # Get just the filename or folder name
  original_name <- path_file(p)
  
  # Replace one or more spaces (" +") with a single underscore "_"
  new_name <- gsub(" +", "_", original_name)
  
  # Create the new full path
  new_path <- path(path_dir(p), new_name)
  
  # Rename the file/folder if the name has changed
  if (p != new_path) {
    file_move(p, new_path)
    
    # Check if it was a file or folder for the message
    # We must check the NEW path, as the old 'p' doesn't exist anymore
    type_msg <- if (is_dir(new_path)) "Folder:" else "File:"
    cat("✅ Renamed", type_msg, original_name, "→", new_name, "\n")
  }
}

cat("\nDone! All files and folders have been processed.\n")
