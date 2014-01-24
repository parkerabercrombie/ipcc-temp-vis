#!/usr/bin/Rscript

scenario = commandArgs(trailingOnly = T)[1]

in.file <- paste('data/seres_', scenario, '.dat', sep='')
out.dir <- paste('ipcc_projections/images/', scenario, sep='')

world <- read.table(in.file, header=T, sep=',')

xlim <- c(min(world$year), max(world$year))
ylim <- c(5282, 15068)
ylim.co2 <- c(0.0, 1855.3)

for (i in 1:length(world$year)) {

  out.file <- paste(out.dir, paste('plot-', world$year[i], '.png', sep=''), sep='/')
  png(out.file, bg="transparent")
  par(col="white")
  par(col.lab="white")
  par(col.axis="white")
  par(col.main="white")
  par(bg="black")

  # Plot the full series as dashed line
  plot(world$year, world$pop,
       xlim=xlim, ylim=ylim,
       type="l",  # Lines only
       lty=2,
       xlab="Year",
       ylab="Population (millions)")     # Dashed

  # Plot up to the current year as solid line
  par(new=T)
  plot(world$year[1:i], world$pop[1:i],
       xlim=xlim, ylim=ylim,
       type="l", # Lines only
       lwd=4,    # Line width
       col="blue",
       axes=F,   # Don't change axes
       xlab='',  # Already set labels
       ylab='')

  
  # Plot the full CO2 series as dashed line
  par(new=T)
  plot(world$year, world$co2,
       xlim=xlim, ylim=ylim.co2,
       type="l",  # Lines only
       lty=2,
       axes=F,
       xlab="Year",
       ylab="")     # Dashed

  # Plot up to the current year as solid line
  par(new=T)
  plot(world$year[1:i], world$co2[1:i],
       xlim=xlim, ylim=ylim.co2,
       type="l", # Lines only
       lwd=4,    # Line width
       col="red",
       axes=F,   # Don't change axes
       xlab='',  # Already set labels
       ylab='')

  mtext("Cummulative CO2 emmissions (Gt)", side=4, line=0.5)
  axis(side=4, pretty(ylim.co2, 10))

  title("World Population (Blue)\nCO2 emissions (Red)")
}

dev.off()
