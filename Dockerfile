## Emacs, make this -*- mode: sh; -*-

FROM nuest/docker-mro:latest
MAINTAINER Rodrigo Belo

## (Based on https://github.com/nuest/docker-mro/blob/master/Dockerfile)
## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (e.g. for linked volumes to work properly).

## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
  ed \
#  gofortran \
#    ca-certificates \
	#curl \
	#nano \
	# MRO dependencies dpkg does not install on its own:
	#libcairo2 \
	#libgfortran3 \
	#libglib2.0-0 \
	#libgomp1 \
	#libjpeg8 \
	#libpango-1.0-0 \
	#libpangocairo-1.0-0 \
	#libtcl8.6 \
	#libtcl8.6 \
	#libtiff5 \
	#libtk8.6 \
	#libx11-6 \
	#libxt6 \
	# needed for installation of MKL:
	#build-essential \
	#make \
	#gcc \
	#g++ \
	&& rm -rf /var/lib/apt/lists/*


WORKDIR /home/docker


CMD ["/usr/bin/R"]
