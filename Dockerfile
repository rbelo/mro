## Emacs, make this -*- mode: sh; -*-

FROM nuest/mro:3.4.0
MAINTAINER Rodrigo Belo <rodrigobelo@gmail.com>

## Install extra packages need
RUN apt-get update \
	  && apt-get install -y --no-install-recommends \
               ed \
               build-essential \
               libcurl4-openssl-dev \
               gfortran \
               libmariadb-client-lgpl-dev \
               mariadb-server \
               default-jdk \
               r-cran-rmysql \
               libnlopt-dev \
               libblas-dev \
               liblapack-dev \
               libxml2-dev \
               libv8-3.14-dev \
               libssl-dev

WORKDIR /home/docker

## Install R packages.
## I need first to empty files MKL_EULA.txt and MRO_EULA.txt because R package 'minqa' does not install otherwise
RUN rm MKL_EULA.txt && touch MKL_EULA.txt
RUN rm MRO_EULA.txt && touch MRO_EULA.txt
RUN sed -i '$d' /usr/lib64/microsoft-r/3.4/lib64/R/etc/Rprofile.site
RUN echo 'utils::assignInNamespace("q", function(save = "no", status = 0, runLast = TRUE) { \
     .Internal(quit(save, status, runLast)) }, "base"); \
utils::assignInNamespace("quit", function(save = "no", status = 0, runLast = TRUE) { \
     .Internal(quit(save, status, runLast)) }, "base")' >> /usr/lib64/microsoft-r/3.4/lib64/R/etc/Rprofile.site
COPY ./install-packages.R install-packages.R
RUN R -f install-packages.R

CMD ["/usr/bin/R"]
