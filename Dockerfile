## Emacs, make this -*- mode: sh; -*-

FROM nuest/mro:3.2.5
MAINTAINER Rodrigo Belo <rodrigobelo@gmail.com>

## Install extra packages need
RUN apt-get update \
	  && apt-get install -y --no-install-recommends \
               ed \
               build-essential \
               libcurl4-openssl-dev \
               gfortran \
               libmariadbclient-dev \
               default-jdk

WORKDIR /home/docker

## Install R packages.
## I need first to empty files MKL_EULA.txt and MRO_EULA.txt because R package 'minqa' does not install otherwise
RUN rm MKL_EULA.txt && touch MKL_EULA.txt
RUN rm MRO_EULA.txt && touch MRO_EULA.txt
COPY ./install-packages.R install-packages.R
RUN R -f install-packages.R

CMD ["/usr/bin/R"]
