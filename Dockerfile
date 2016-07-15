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

## Install the Hadleyverse packages (and some close friends).
COPY ./install-packages.R install-packages.R
RUN R -f install-packages.R

CMD ["/usr/bin/R"]
