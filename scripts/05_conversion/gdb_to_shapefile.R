# ============================================================
# CONFIGURATION
# ============================================================
library(sf)

# Update this path to your "Main Folders" location
main_directory <- c(
  "C:/path/to/your/folder_1",
  "C:/path/to/your/folder_2"
)

# ============================================================
# SCRIPT
# ============================================================

# 1. Find all .gdb folders recursively
all_dirs <- list.dirs(main_directory, recursive = TRUE, full.names = TRUE)
gdb_list <- all_dirs[grep("\\.gdb$", all_dirs, ignore.case = TRUE)]

if (length(gdb_list) == 0) {
  stop("No .gdb folders found! Check your path.")
}

message(paste("Found", length(gdb_list), "Geodatabases. Starting conversion..."))
message("---------------------------------------------------")

count_created <- 0
count_skipped <- 0
count_errors  <- 0

for (gdb_path in gdb_list) {
  
  # WRAP THE WHOLE GDB PROCESS IN ERROR HANDLING
  tryCatch({
    
    # A. Get the parent folder path
    parent_folder <- dirname(gdb_path) 
    
    # B. List layers inside the GDB
    # If this fails (due to lock or corruption), it jumps to the error block below
    layers <- st_layers(gdb_path)
    layer_names <- layers$name
    
    if (length(layer_names) == 0) {
      message(paste("Skipping empty GDB:", basename(gdb_path)))
      next
    }
    
    # C. Loop through each layer in the GDB
    for (layer_name in layer_names) {
      
      # Name logic: Just the layer name
      new_filename <- paste0(layer_name, ".shp")
      output_path <- file.path(parent_folder, new_filename)
      
      # Check if exists
      if (file.exists(output_path)) {
        message(paste("Skipping (Already Exists):", new_filename))
        count_skipped <- count_skipped + 1
        next 
      }
      
      # Convert
      geo_data <- st_read(dsn = gdb_path, layer = layer_name, quiet = TRUE)
      st_write(geo_data, output_path, delete_layer = TRUE, quiet = TRUE)
      
      message(paste("Converted:", layer_name, "->", new_filename))
      count_created <- count_created + 1
    }
    
  }, error = function(e) {
    # This block runs if the GDB itself cannot be opened
    message(paste("CRITICAL ERROR: Could not open GDB:", basename(gdb_path)))
    message(paste("Reason:", e$message))
    message("--> Skipping this GDB and continuing...")
    count_errors <- count_errors + 1
  })
}

message("---------------------------------------------------")
message("Process complete.")
message(paste("Files Created:", count_created))
message(paste("Files Skipped (Existed):", count_skipped))
message(paste("GDB Errors (Corrupt/Locked):", count_errors))
