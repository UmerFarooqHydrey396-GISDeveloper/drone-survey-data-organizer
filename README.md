# Drone Survey Data Organizer (R)

R scripts for organizing, renaming and quality-checking large drone survey deliverables:
orthomosaics, DSMs, ECWs, AOIs, ground control points and digitized cadastral parcels.

I wrote these while managing province-scale drone photogrammetry deliveries (thousands of
settlement/mouza folders across many districts). Manual copy-paste-rename at that scale is
slow and error-prone; these scripts turn hours of folder work into a single run.

## The folder standard these scripts build and check

Every settlement (identified by `OID_Name`, e.g. `10_9_Goleki`) gets the same structure:

```
OID_Name/
├── Aerial Orthoimage/
├── Aoi/
├── Digital Surface Model (DSM)/
├── Digitized Parcels/
├── Ecw/
└── Ground Control Points (GCP)/
```

## What's included

| Folder | Script | What it does |
|---|---|---|
| `01_folder_setup` | `create_main_folders_from_excel.R` | Creates one main folder per row of an Excel list (`OID`, `Name`) |
| | `create_folders_with_subfolders_from_excel.R` | Same, plus the six standard subfolders |
| | `create_folders_and_copy_data_from_excel.R` | Creates folders and copies the matching data into each subfolder |
| | `create_folders_from_filenames.R` | Builds the folder tree from file names (e.g. ortho tiles) |
| `02_file_placement` | `place_orthos_by_oid.R`, `place_dsm_by_oid.R`, `place_aoi_files_by_oid.R` | Moves rasters/shapefiles into the folder whose OID matches the file name |
| | `place_digitized_parcels.R` | Normalizes names, then places parcel GDB/SHP files into `Digitized Parcels` |
| | `sort_folders_by_tehsil.R` | Reads one feature/pixel from each folder's data and sorts folders by the tehsil boundary they fall in (`sf` + `terra`) |
| `03_renaming` | `add_suffix_*`, `remove_suffix_*`, `remove_prefix_*` | Bulk add/remove prefixes and suffixes on files and folders |
| | `replace_spaces_in_filenames.R`, `replace_spaces_in_gdb_names.R` | Replaces spaces with underscores (GIS software-safe names) |
| | `remove_oid_from_folder_names.R` (+ Windows `.bat` version) | Turns `7_1_Shah Sadar Din` into `Shah Sadar Din` |
| `04_qc_checks` | `check_empty_*` | Finds missing or empty subfolders before submission |
| | `check_empty_folders_to_excel.R`, `multi_district_qc_report_to_excel.R` | Writes a delivery-completeness report to Excel across one or many districts |
| `05_conversion` | `gdb_to_shapefile.R` | Batch-exports feature classes from File Geodatabases to shapefiles |

## Requirements

- R 4.x
- Packages (each script installs what it needs if missing): `fs`, `readxl`, `writexl`, `stringr`, `sf`, `terra`, `dplyr`, `tibble`

## How to use

1. Open the script you need in RStudio.
2. Edit the **configuration section** at the top (paths look like `C:/path/to/your/folder`).
3. Run the whole script and read the console log.

> ⚠️ Renaming and moving scripts change files in place. Test on a copy of your data first.

## Author

**Umer Farooq Hydrey**, GIS Manager & Photogrammetric Analyst
[Portfolio](https://umerfarooqhydrey396-gisdeveloper.github.io)

## License

MIT. See [LICENSE](LICENSE).
