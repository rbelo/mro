FROM nuest:docker-mro
MAINTAINER Rodrigo Belo 

## (Based on https://github.com/nuest/docker-mro/blob/master/Dockerfile)
## Set a default user. Available via runtime flag `--user docker`
## Add user to 'staff' group, granting them write privileges to /usr/local/lib/R/site.library
## User should also have & own a home directory (e.g. for linked volumes to work properly).
RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
  ed \
  gofortran \
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