## ---- echo=TRUE-------------------------------------------------------------
needed <- c("rgrass", "XML", "raster", "stars", "abind", "sp", "sf", "terra")


## ---------------------------------------------------------------------------
library("terra")


## ---------------------------------------------------------------------------
gdal(lib="all")


## ---------------------------------------------------------------------------
fv <- system.file("ex/lux.shp", package="terra")
(v <- vect(fv))


## ---------------------------------------------------------------------------
try(inMemory(v))


## ---------------------------------------------------------------------------
cat(crs(v), "\n")


## ---------------------------------------------------------------------------
library("sf")


## ---------------------------------------------------------------------------
v_sf <- st_as_sf(v)
v_sf


## ---------------------------------------------------------------------------
v_sf_rt <- vect(v_sf)
v_sf_rt


## ---------------------------------------------------------------------------
all.equal(v_sf_rt, v, check.attributes=FALSE)


## ---------------------------------------------------------------------------
Sys.setenv("_SP_EVOLUTION_STATUS_"="2")
library("sp")

## ---------------------------------------------------------------------------
v_sp <- as(v_sf, "Spatial")
print(summary(v_sp))


## ---------------------------------------------------------------------------
v_sp_rt <- vect(st_as_sf(v_sp))
all.equal(v_sp_rt, v, check.attributes=FALSE)


## ---------------------------------------------------------------------------
fr <- system.file("ex/elev.tif", package="terra")
(r <- rast(fr))


## ---------------------------------------------------------------------------
try(inMemory(r))


## ---------------------------------------------------------------------------
library("stars")


## ---------------------------------------------------------------------------
r_stars <- st_as_stars(r)
print(r_stars)


## ---------------------------------------------------------------------------
(r_stars_rt <- rast(r_stars))


## ---------------------------------------------------------------------------
(r_stars_p <- st_as_stars(r, proxy=TRUE))


## ---------------------------------------------------------------------------
(r_stars_p_rt <- rast(r_stars_p))


## ---------------------------------------------------------------------------
r_sp <- as(r_stars, "Spatial")
summary(r_sp)


## ---------------------------------------------------------------------------
(r_sp_rt <- rast(st_as_stars(r_sp)))


## ---------------------------------------------------------------------------
tf <- tempfile(fileext=".grd")
terra::writeRaster(r, filename=tf, filetype="RRASTER")


## ---------------------------------------------------------------------------
library("raster")


## ---------------------------------------------------------------------------
(r_RL <- raster(tf))


## ---------------------------------------------------------------------------
(r_RL_rt <- rast(r_RL))


## ---------------------------------------------------------------------------
library(terra)
bbo <- vect("data/bbo.gpkg")
bbo


## ---------------------------------------------------------------------------
bbo_r <- rast(bbo, resolution=1)
bbo_r


## ---------------------------------------------------------------------------
buildings <- vect("data/buildings.gpkg")
deaths <- vect("data/deaths.gpkg")
b_pump <- vect("data/b_pump.gpkg")
nb_pump <- vect("data/nb_pump.gpkg")


## ---------------------------------------------------------------------------
plot(buildings)
points(deaths)
points(b_pump, pch=7, col="red", cex=1.5)
points(nb_pump, pch=1, col="blue", cex=1.5)


## ---------------------------------------------------------------------------
Sys.setenv("GRASS_INSTALLATION"="/home/rsb/topics/grass/g820/grass82")
# replace with correct value for platform
library(rgrass)
GRASS_INSTALLATION <- Sys.getenv("GRASS_INSTALLATION")
file.info(GRASS_INSTALLATION)$isdir[1]
GRASS_INSTALLATION


## ---------------------------------------------------------------------------
td <- tempdir()
td


## ---------------------------------------------------------------------------
soho <- initGRASS(gisBase=GRASS_INSTALLATION, home=td, SG=bbo_r, override=TRUE)
soho


## ---------------------------------------------------------------------------
fl <- c("overwrite", "quiet")
write_VECT(bbo, vname="bbo", flags=fl)
write_VECT(buildings[,1], vname="buildings", flags=fl)
write_VECT(b_pump, vname="b_pump", flags=fl)
write_VECT(nb_pump, vname="nb_pump", flags=fl)
write_VECT(deaths, vname="deaths", flags=fl)
execGRASS("g.list", type="vector", intern=TRUE)


## ---------------------------------------------------------------------------
execGRASS("v.overlay", ainput="buildings", binput="bbo", operator="xor", output="roads", flags=fl)
execGRASS("v.to.rast", input="roads", output="rroads", use="val", value=1, flags=fl)
execGRASS("r.stats", input="rroads", flags=c("c", "quiet"))


## ---------------------------------------------------------------------------
execGRASS("r.buffer", input="rroads", output="rroads4", distances=4, flags=fl)
execGRASS("r.stats", input="rroads4", flags=c("c", "quiet"))
tf <- tempfile()
cat("1 2 = 1\n", file=tf)
execGRASS("r.reclass", input="rroads4", output="rroads4a", rules=tf, flags=fl)
execGRASS("r.stats", input="rroads4a", flags=c("c", "quiet"))


## ---------------------------------------------------------------------------
execGRASS("r.cost", input="rroads4a", output="dist_broad", start_points="b_pump", flags=fl)
execGRASS("r.cost", input="rroads4a", output="dist_not_broad", start_points="nb_pump", flags=fl)


## ---------------------------------------------------------------------------
execGRASS("v.db.addcolumn", map="deaths", columns="broad double precision", flags="quiet")
execGRASS("v.what.rast", map="deaths", raster="dist_broad", column="broad", flags="quiet")
execGRASS("v.db.addcolumn", map="deaths", columns="not_broad double precision", flags="quiet")
execGRASS("v.what.rast", map="deaths", raster="dist_not_broad", column="not_broad", flags="quiet")


## ---------------------------------------------------------------------------
deaths1 <- read_VECT("deaths", flags=fl)
deaths1$b_nearer <- deaths1$broad < deaths1$not_broad


## ---------------------------------------------------------------------------
by(deaths1$Num_Css, deaths1$b_nearer, sum)


## ---------------------------------------------------------------------------
sessionInfo()

