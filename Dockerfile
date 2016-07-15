## Emacs, make this -*- mode: sh; -*-

FROM nuest/docker-mro:latest
MAINTAINER Rodrigo Belo <rodrigobelo@gmail.com>

## Install extra packages need
RUN apt-get update \
	  && apt-get install -y --no-install-recommends \
               ed \
               libcurl4-openssl-dev \
               gfortran

WORKDIR /home/docker

## Install R packages.
## I need first to empty mklLicense.txt because R package 'minqa' does not install otherwise
RUN rm mklLicense.txt && touch mklLicense.txt
COPY ./install-packages.R install-packages.R
RUN R -f install-packages.R

CMD ["/usr/bin/R"]
