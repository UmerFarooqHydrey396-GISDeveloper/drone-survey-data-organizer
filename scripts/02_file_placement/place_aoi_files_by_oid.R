# --- Libraries ---
library(fs)

# --- Paths ---
source_dir <- "C:/path/to/your/folder"  # folder containing shapefile components (.shp, .dbf, etc.)
target_dir <- "C:/path/to/your/folder"      # main folder with OID_Name folders

# --- Logic ---
# List all files (shp, dbf, prj, cpg, sbn, sbx, shx)
parcel_files <- dir_ls(source_dir, regexp = "\\.(shp|dbf|prj|cpg|sbn|sbx|shx)$", type = "file")

for (file in parcel_files) {
  file_name <- basename(file)
  
  # Extract OID and Name (remove extension first)
  file_core <- tools::file_path_sans_ext(file_name)
  
  # Extract OID only (before first underscore)
  oid <- sub("_.*", "", file_core)
  
  # Find corresponding folder (starts with OID_)
  target_main <- dir_ls(target_dir, type = "directory", regexp = paste0("^", oid, "_"))
  
  if (length(target_main) == 1) {
    # Path to "Digitized Parcels" subfolder
    target_sub <- file.path(target_main, "Aoi")
    
    # Create subfolder if missing
    if (!dir_exists(target_sub)) dir_create(target_sub)
    
    # Copy file
    file_copy(file, target_sub, overwrite = TRUE)
    cat("✅ Copied:", file_name, "→", target_sub, "\n")
  } else {
    cat("❌ Folder not found for:", file_name, "\n")
  }
}
