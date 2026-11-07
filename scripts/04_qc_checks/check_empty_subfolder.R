# --- Configuration ---
# Root folder where all your main folders (e.g., 10_9_Goleki) are stored
main_folder <- "C:/path/to/your/folder"

# Subfolder name to check
target_subfolder <- "Ecw"

# --- Script Logic ---
# Get list of main folders (only top-level directories)
main_folders <- list.dirs(main_folder, full.names = TRUE, recursive = FALSE)

# Create an empty vector to store results
empty_folders <- c()

# Loop through each main folder
for (folder in main_folders) {
  # Path to the Digitized Parcels subfolder
  sub_path <- file.path(folder, target_subfolder)
  
  if (dir.exists(sub_path)) {
    # List all files/folders inside it
    contents <- list.files(sub_path, all.files = TRUE, no.. = TRUE)
    
    # Check if it’s empty
    if (length(contents) == 0) {
      empty_folders <- c(empty_folders, sub_path)
      cat("⚠️ Empty folder found:", sub_path, "\n")
    }
  } else {
    cat("❌ 'Digitized Parcels' subfolder not found in:", basename(folder), "\n")
  }
}

# --- Summary ---
if (length(empty_folders) == 0) {
  cat("\n✅ No empty 'Digitized Parcels' folders found.\n")
} else {
  cat("\n📂 Total empty folders found:", length(empty_folders), "\n")
  cat("List of empty folders:\n")
  print(empty_folders)
}
