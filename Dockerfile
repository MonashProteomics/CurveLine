FROM rocker/shiny-verse:4.4.1
RUN apt-get update && apt-get install -yq \
     libcurl4-openssl-dev \
     libhdf5-dev \
     libnetcdf-dev \
     build-essential \
     libgd-dev \
     libudunits2-dev \
     libproj-dev \
     libgdal-dev
RUN Rscript -e 'install.packages(c("devtools","BiocManager", "shiny","shinyjs", "shiny.info","shinycssloaders","bslib", "tidyverse", "DT", "ggplot2", "boot"), dependencies=TRUE)'
COPY . /srv/shiny-server/curveline
RUN chmod -R +r /srv/shiny-server/curveline
