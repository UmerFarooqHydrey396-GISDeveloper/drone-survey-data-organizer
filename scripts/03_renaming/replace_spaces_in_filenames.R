# Load the library
library(fs)

# Set your main folder path
main_dir <- "C:/path/to/your/folder" # ← Change this to your folder path

# List all FILES in the directory
# The key change is using type = "file"
all_files <- dir_ls(main_dir, type = "file", recurse = TRUE)

# Loop through each file and rename
for (f in all_files) {
  # Get just the filename
  original_name <- path_file(f)
  
  # Replace spaces with underscores
  new_name <- gsub(" ", "_", original_name)
  
  # Create the new full path
  new_path <- path(path_dir(f), new_name)
  
  # Rename the file if the name has changed
  if (f != new_path) {
    file_move(f, new_path)
    cat("✅ Renamed:", original_name, "→", new_name, "\n")
  }
}

cat("\nDone! All files have been processed.\n")
