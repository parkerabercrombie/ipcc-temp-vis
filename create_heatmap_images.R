#!/usr/bin/Rscript

require(ncdf4)
require(maptools)
require(grDevices)

args <- commandArgs(trailingOnly=TRUE)

#borders.shapefile = readShapeLines('borders/TM_WORLD_BORDERS_SIMPL-0.2.shp')

# Setup plotting environment
rgb.palette <- colorRampPalette(c("blue", "cyan", "green", "yellow", "orange",
                                  "red", "purple", "black"), space="rgb")

create.images = function (file.base, year.start, year.end, in.file, out.dir) {
  # Read data from NetCDF file
  tryCatch({
    temp.anomaly.file <- nc_open(in.file)
    data <- ncvar_get(temp.anomaly.file, 'air_temperature_anomaly')
    nc_close(temp.anomaly.file)
  }, warning = function (w) {
    print("Warning: opening NetCDF file")
  }, error = function (e) {
    stop("Error: opening NetCDF file")
  })

  data.mean <- 0
  for (i in 1:12) {
    data.mean <- data.mean + data[,,i]
  }
  data.mean <- data.mean / 12

  # Create the image
  out.file <- paste(out.dir, paste(file.base, year.start, '-', year.end, '.jpg', sep=''), sep='/')
  plot.images(data.mean, out.file)
}

create.images.interpolate = function(file.base, year.start, year.end, pre.file, post.file, out.dir) {
  # Read data from NetCDF files
  pre.temp.file <- nc_open(pre.file)
  pre.data <- ncvar_get(pre.temp.file, 'air_temperature_anomaly')
  nc_close(pre.temp.file)

  data.sum <- 0
  for (i in 1:12) {
    data.sum <- data.sum + pre.data[,,i]
  }
  
  post.temp.file <- nc_open(post.file)
  post.data <- ncvar_get(post.temp.file, 'air_temperature_anomaly')
  nc_close(post.temp.file)

  for (i in 1:12) {
    data.sum <- data.sum + post.data[,,i]
  }

  data.mean <- data.sum / 24

  out.file <- paste(out.dir, paste(file.base, year.start, '-', year.end, '.jpg', sep=''), sep='/')
  plot.images(data.mean, out.file)
}

plot.images = function(data, out.file) {
  # Create the image
  jpeg(out.file, width=1024, height=1024)

  # Set all margins to zero
  par(oma=c(0, 0, 0, 0))
  par(mar=c(0, 0, 0, 0))

  x = seq(from=0, to=180, by=(180 / (128 - 1)))
  y = seq(from=-90, to=90, by=(180 / (128 - 1)))

  image(x, y, z=data[1:128,], xlim=c(-180, 180),ylim=c(-90, 90), zlim=c(-10, 20),
        col=rgb.palette(1024), axes=FALSE)

  x = seq(from=-180, to=0, by=(180 / (128 - 1)))
  image(x, y, z=data[129:256,], xlim=c(-180, 180), ylim=c(-90, 90), zlim=c(-10, 20),
        col=rgb.palette(1024), axes=FALSE, add=TRUE)

#  plot(borders.shapefile, add=TRUE)
}

img.dir.base <- "ipcc_projections/images"

scenarios = c("A1B", "A2", "B1")

for (scenario in scenarios) {
    file.base = paste('NCCCSM_SR', scenario, '_1_tas-change_', sep='')
    img.dir = paste(img.dir.base, scenario, sep='/')

    if (!file.exists(img.dir)) {
      dir.create(img.dir)
    }

    create.images(file.base, 2010, 2030, paste('netcdf/', file.base, '2011-2030.nc', sep=''), img.dir)
    create.images(file.base, 2046, 2065, paste('netcdf/', file.base, '2046-2065.nc', sep=''), img.dir)
    create.images(file.base, 2080, 2110, paste('netcdf/', file.base, '2080-2099.nc', sep=''), img.dir)

    # Interpolate segments of missing data
    create.images.interpolate(file.base, 2031, 2045,
                              paste('netcdf/', file.base, '2011-2030.nc', sep=''),
                              paste('netcdf/', file.base, '2046-2065.nc', sep=''), img.dir)
    create.images.interpolate(file.base, 2066, 2079,
                              paste('netcdf/', file.base, '2046-2065.nc', sep=''),
                              paste('netcdf/', file.base, '2080-2099.nc', sep=''), img.dir)


    par(oma=c(0, 0, 0, 0))
    par(mar=c(0, 0, 0, 0))

    png(paste(img.dir, 'header.png', sep='/'),
        width=400, height=300, bg="transparent")

    par(col="white")
    par(cex=2.0)
    par(col.main="white")

    plot.new()
    title(paste('Scenario', scenario))
}
dev.off()

png(paste(img.dir.base, 'legend.jpg', sep='/'),
    width=400, height=150, bg="transparent")
par(col="white")
par(col.lab="white")
par(col.axis="white")
par(col.main="white")
par(bg="black")

plot.new()
levels = seq(-10, 20, length=1024)

title('Temperature Change (C)')
plot.window(xlim = range(levels), ylim = c(0, 1), xaxs = "i", yaxs = "i")
rect(levels[-length(levels)], 0, levels[-1], 1, col = rgb.palette(1024),  density = NA)

axis(1)
box()

dev.off()
