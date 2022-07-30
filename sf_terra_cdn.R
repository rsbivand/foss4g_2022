# for transformation grid, set before package loaded
Sys.setenv("PROJ_NETWORK"="ON")
library(sf)
sf_proj_network()
bp_file <- system.file("gpkg/b_pump.gpkg", package="sf")
b_pump_sf <- st_read(bp_file)
b_pump_sf_ll <- st_transform(b_pump_sf, "OGC:CRS84")
st_geometry(b_pump_sf_ll)
# with POINT (-0.1366876 51.5133)
# without POINT (-0.1367127 51.5133)

# for transformation grid, set before package loaded
Sys.setenv("PROJ_NETWORK"="ON")
library(terra)
bp_file <- system.file("gpkg/b_pump.gpkg", package="sf")
b_pump_sv <- vect(bp_file)
b_pump_sv_ll <- project(b_pump_sv, "OGC:CRS84")
geom(b_pump_sv_ll)
# with  -0.1366876 51.5133
# without  -0.1367127 51.5133

