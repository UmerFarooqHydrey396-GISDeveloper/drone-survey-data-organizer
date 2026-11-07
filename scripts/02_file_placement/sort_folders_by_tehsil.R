# ==============================================================================
# SCRIPT: AUTO-DETECT TEHSIL FROM FOLDER CONTENTS (GDB/SHP/TIF)
# ==============================================================================

# 1. INSTALL/LOAD LIBRARIES
# ------------------------------------------------------------------------------
required_packages <- c("sf", "terra", "dplyr", "fs", "tibble")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

library(sf)       # Vector handling
library(terra)    # Raster handling
library(dplyr)    # Data manipulation
library(fs)       # File system operations
library(tibble)   # Dataframes

# ==============================================================================
# 2. USER INPUTS (PLEASE EDIT THIS SECTION)
# ==============================================================================

# Path to the Tehsil Boundary Shapefile
tehsil_path <- "C:/path/to/your/boundary.shp" 

# Path to the Root Directory containing your Main Folders
root_folder <- "C:/path/to/your/folder"

# Path where you want the SORTED folders to go
# We create a separate folder to avoid messing up your original data
output_base_folder <- "C:/path/to/your/folder"

# The EXACT column name in your Shapefile containing the Tehsil Name
tehsil_col_name <- "Tehsil_N" 

# ==============================================================================
# 3. CORE FUNCTIONS
# ==============================================================================

# FUNCTION A: Check Vector (GDB/SHP) - SAFE MODE (Reads only 1 feature)
check_vector_safe <- function(f_path, tehsils_sf) {
  tryCatch({
    # Get layer names without reading data
    layers <- st_layers(f_path)
    if(length(layers$name) == 0) return(NA)
    
    # Target the first layer found
    target_layer <- layers$name[1]
    
    # --- THE SAFETY LOCK ---
    # We use a SQL query to fetch ONLY the first row (LIMIT 1).
    query_string <- paste0("SELECT * FROM \"", target_layer, "\" LIMIT 1")
    
    # Read only that single feature
    vec_sample <- read_sf(f_path, query = query_string, quiet = TRUE)
    
    if(nrow(vec_sample) == 0) return(NA)
    
    # Get Centroid of that sample
    center_pt <- st_centroid(st_geometry(vec_sample))
    
    # Transform CRS if it doesn't match Tehsil
    if (st_crs(center_pt) != st_crs(tehsils_sf)) {
      center_pt <- st_transform(center_pt, st_crs(tehsils_sf))
    }
    
    # Spatial Join to find Tehsil
    result <- st_join(st_as_sf(center_pt), tehsils_sf, join = st_intersects)
    
    return(as.character(result[[tehsil_col_name]]))
    
  }, error = function(e) {
    message(paste("  [!] Error reading vector:", path_file(f_path)))
    return(NA) 
  })
}

# FUNCTION B: Check Raster (TIF) - FAST MODE (Reads header only)
check_raster_fast <- function(f_path, tehsils_sf) {
  tryCatch({
    r <- rast(f_path)
    e <- ext(r)
    center_x <- (e$xmin + e$xmax) / 2
    center_y <- (e$ymin + e$ymax) / 2
    
    pt_sf <- st_sfc(st_point(c(center_x, center_y)), crs = st_crs(r)$wkt)
    pt_sf <- st_as_sf(pt_sf)
    
    if (st_crs(pt_sf) != st_crs(tehsils_sf)) {
      pt_sf <- st_transform(pt_sf, st_crs(tehsils_sf))
    }
    
    result <- st_join(pt_sf, tehsils_sf, join = st_intersects)
    
    return(as.character(result[[tehsil_col_name]]))
    
  }, error = function(e) { 
    return(NA) 
  })
}

# ==============================================================================
# 4. MAIN EXECUTION LOOP
# ==============================================================================

message("--- STARTING PROCESS ---")
message("1. Loading Tehsil Boundaries...")
tehsils <- read_sf(tehsil_path)

if (any(!st_is_valid(tehsils))) {
  tehsils <- st_make_valid(tehsils)
}

message("2. Scanning Main Folders...")
main_folders <- dir_ls(root_folder, type = "directory")

results_list <- list()

for (folder in main_folders) {
  folder_name <- path_file(folder)
  message(paste("Processing:", folder_name, "..."))
  
  found_tehsil <- NA
  source_info <- "None"
  
  # --- CHECK 1: Look for GDBs (Priority) ---
  gdbs <- dir_ls(folder, glob = "*.gdb", recurse = TRUE, type = "directory")
  if (length(gdbs) > 0) {
    found_tehsil <- check_vector_safe(gdbs[1], tehsils)
    if (!is.na(found_tehsil)) source_info <- paste("GDB:", path_file(gdbs[1]))
  }
  
  # --- CHECK 2: Look for Shapefiles (If no GDB match) ---
  if (is.na(found_tehsil)) {
    shps <- dir_ls(folder, glob = "*.shp", recurse = TRUE)
    if (length(shps) > 0) {
      found_tehsil <- check_vector_safe(shps[1], tehsils)
      if (!is.na(found_tehsil)) source_info <- paste("SHP:", path_file(shps[1]))
    }
  }
  
  # --- CHECK 3: Look for TIFs (If no Vector match) ---
  if (is.na(found_tehsil)) {
    tifs <- dir_ls(folder, glob = "*.tif", recurse = TRUE)
    tifs <- tifs[!grepl(".xml$", tifs)] 
    
    if (length(tifs) > 0) {
      found_tehsil <- check_raster_fast(tifs[1], tehsils)
      if (!is.na(found_tehsil)) source_info <- paste("TIF:", path_file(tifs[1]))
    }
  }
  
  results_list[[folder_name]] <- tibble(
    Main_Folder = folder_name,
    Detected_Tehsil = ifelse(is.na(found_tehsil), "Unknown_Outside_Boundary", found_tehsil),
    Source_Used = source_info
  )
}

# ==============================================================================
# 5. EXPORT RESULTS
# ==============================================================================

final_df <- bind_rows(results_list)
output_csv <- file.path(root_folder, "Final_Tehsil_Mapping.csv")
write.csv(final_df, output_csv, row.names = FALSE)
print(final_df)

# ==============================================================================
# 6. ORGANIZE FOLDERS (MOVES/COPIES)
# ==============================================================================

# Safety Check: If operation_mode wasn't defined, default to MOVE
if (!exists("operation_mode")) {
  operation_mode <- "MOVE"
  message("NOTE: 'operation_mode' was not defined. Defaulting to 'MOVE' mode.")
}

message(paste("\n--- STARTING", operation_mode, "PROCESS ---"))
message(paste("Target Directory:", output_base_folder))

if (!dir_exists(output_base_folder)) {
  dir_create(output_base_folder)
}

count <- 0
total <- nrow(final_df)

for (i in 1:total) {
  row <- final_df[i, ]
  
  folder_name <- row$Main_Folder
  tehsil_name <- row$Detected_Tehsil
  
  # Build paths
  source_path <- file.path(root_folder, folder_name)
  dest_tehsil_dir <- file.path(output_base_folder, tehsil_name)
  dest_path <- file.path(dest_tehsil_dir, folder_name)
  
  # Create Tehsil Directory if missing
  if (!dir_exists(dest_tehsil_dir)) {
    dir_create(dest_tehsil_dir)
  }
  
  message(paste("[", i, "/", total, "]", operation_mode, ":", folder_name, "-->", tehsil_name))
  
  tryCatch({
    if (operation_mode == "MOVE") {
      # MOVE: Instant on same drive (Cut & Paste)
      # file_move works on directories too
      file_move(source_path, dest_path)
    } else {
      # COPY: Duplicate data (Slow for large files)
      dir_copy(source_path, dest_path, overwrite = TRUE)
    }
    count <- count + 1
  }, error = function(e) {
    message(paste("   [ERROR] Could not process", folder_name, ":", e$message))
  })
}

message(paste("\n--- DONE! Successfully processed", count, "folders. ---"))
