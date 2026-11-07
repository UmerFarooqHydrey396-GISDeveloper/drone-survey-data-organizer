# Title: R Script to Remove a Suffix from File Names (Handles Extensions)
library(fs)
library(tools) # Using 'tools' to easily get file extensions

# --- Configuration ---
parent_directory_path <- "C:/path/to/your/folder"
suffix_to_remove <- "_Ortho"

# --- Script Logic ---
if (!dir_exists(parent_directory_path)) {
  stop("Error: The specified directory does not exist: ", parent_directory_path)
}

all_files <- dir_ls(parent_directory_path, type = "file")

if (length(all_files) == 0) {
  cat("No files found.\n")
} else {
  cat("Scanning", length(all_files), "files...\n\n")
  
  for (current_file_path in all_files) {
    
    original_file_name <- path_file(current_file_path)
    
    # --- THIS IS THE IMPORTANT PART ---
    
    # Get the file name *without* the extension
    # e.g., "27_19_Dalu_Wali_Ortho"
    file_name_no_ext <- file_path_sans_ext(original_file_name)
    
    # Get just the extension
    # e.g., "ecw"
    file_ext <- file_ext(original_file_name)
    
    # Check if the name *without the extension* ends with the suffix
    if (endsWith(file_name_no_ext, suffix_to_remove)) {
      
      # Create the new name by removing the suffix from the "no_ext" part
      new_name_no_ext <- gsub(paste0(suffix_to_remove, "$"), "", file_name_no_ext)
      
      # Add the extension back on
      # We need to add the dot "." back manually if the extension exists
      if (file_ext != "") {
        new_file_name <- paste0(new_name_no_ext, ".", file_ext)
      } else {
        new_file_name <- new_name_no_ext
      }
      
      # Construct the full new path
      new_file_path <- path(path_dir(current_file_path), new_file_name)
      
      # Rename
      file_move(current_file_path, new_file_path)
      
      cat("✅ Renamed:", original_file_name, "→", new_file_name, "\n")
      
    } else {
      cat("- Skipping (suffix not found before extension):", original_file_name, "\n")
    }
  }
  
  cat("\nFile renaming process complete.\n")
}
