# Set your folder path
folder_path <- "C:/path/to/your/folder"

# List all .tif files
files <- list.files(folder_path, pattern = "\\.prj$", full.names = TRUE)

# Loop through each file and rename
for (file in files) {
  new_name <- gsub("G_", "", basename(file))  # remove "G_" from filename
  file.rename(file, file.path(folder_path, new_name))
}
