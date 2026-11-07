library(tools)

# ============================================================
# STEP 1: Define ALL your root directories
# Use c() to combine multiple paths. Separated by commas.
# ============================================================
main_directories <- c(
  "C:/path/to/your/folder_1",
  "C:/path/to/your/folder_2"
)

# ============================================================
# STEP 2: Find the files
# ============================================================

# list.files handles the vector of paths automatically
all_files <- list.files(path = main_directories, 
                        pattern = "\\.(ecw|eew|prj)$", 
                        recursive = TRUE, 
                        full.names = TRUE,
                        ignore.case = TRUE)

# Filter: Keep ONLY files inside "Digital Surface Model (DSM)" folders
files_to_process <- all_files[basename(dirname(all_files)) == "Ecw"]

# Check if we found files
if (length(files_to_process) == 0) {
  stop("No files found. Please check your paths.")
} else {
  message(paste("Found", length(files_to_process), "files to scan across all folders."))
}

# ============================================================
# STEP 3: Rename the files (With Skip Logic)
# ============================================================

counter <- 0
skipped_counter <- 0

for (file_path in files_to_process) {
  
  # 1. Get directory and name
  dir_path <- dirname(file_path)
  file_name_no_ext <- tools::file_path_sans_ext(basename(file_path))
  
  # 2. CHECK: Skip if it already has the suffix
  if (grepl("_ECW$", file_name_no_ext, ignore.case = TRUE)) {
    skipped_counter <- skipped_counter + 1
    next 
  }
  
  # 3. Get extension
  ext <- tools::file_ext(file_path)
  
  # 4. Create new name
  new_file_name <- paste0(file_name_no_ext, "_ECW.", ext)
  new_full_path <- file.path(dir_path, new_file_name)
  
  # 5. Rename
  if (file_path != new_full_path) {
    file.rename(from = file_path, to = new_full_path)
    counter <- counter + 1
  }
}

message(paste("Processing Complete."))
message(paste("Renamed:", counter))
message(paste("Skipped (Already had suffix):", skipped_counter))
