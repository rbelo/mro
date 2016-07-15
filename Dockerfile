## Emacs, make this -*- mode: sh; -*-

FROM ubuntu:trusty
MAINTAINER Rodrigo Belo

## Merged nuest/docker-mro and rocker/hadleyverse

RUN useradd docker \
	&& mkdir /home/docker \
	&& chown docker:docker /home/docker \
	&& addgroup docker staff

RUN apt-get update \
	    && apt-get install -y --no-install-recommends \
		             ed \
		             less \
		             locales \
		             vim-tiny \
		             wget \
		             ca-certificates \
	    && rm -rf /var/lib/apt/lists/*

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	  && locale-gen en_US.utf8 \
	  && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

## Use Debian unstable via pinning -- new style via APT::Default-Release
#RUN echo "deb http://http.debian.net/debian sid main" > /etc/apt/sources.list.d/debian-unstable.list \
	  #&& echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default


## Install some useful tools and dependencies for MRO
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
    ca-certificates \
	curl \
  ed \
	nano \
	# MRO dependencies dpkg does not install on its own:
	libcairo2 \
  libcurl4-openssl-dev \
	libgfortran3 \
	libglib2.0-0 \
	libgomp1 \
	libjpeg8 \
	libpango-1.0-0 \
	libpangocairo-1.0-0 \
	libtcl8.6 \
	libtcl8.6 \
	libtiff5 \
	libtk8.6 \
	libx11-6 \
	libxt6 \
	# needed for installation of MKL:
	build-essential \
	make \
	gcc \
	g++ \
	&& rm -rf /var/lib/apt/lists/*


## https://mran.revolutionanalytics.com/documents/rro/installation/#revorinst-lin
# Use major and minor vars to re-use them in non-interactive installtion script
ENV MRO_VERSION_MAJOR 3
ENV MRO_VERSION_MINOR 2.5
ENV MRO_VERSION $MRO_VERSION_MAJOR.$MRO_VERSION_MINOR

## TODO: use Ubuntu this version to create the URL below
#RUN export UBUNTU_VERSION="$(lsb_release -s -d | sed -e 's/Ubuntu //g')" \
#	&& echo $UBUNTU_VERSION

WORKDIR /home/docker

## Download & Install MRO
RUN curl -LO -# https://mran.revolutionanalytics.com/install/mro/$MRO_VERSION/MRO-$MRO_VERSION-Ubuntu-14.4.x86_64.deb \
#RUN wget https://mran.revolutionanalytics.com/install/mro/$MRO_VERSION/MRO-$MRO_VERSION-Ubuntu-14.4.x86_64.deb \
	&& dpkg -i MRO-$MRO_VERSION-Ubuntu-14.4.x86_64.deb \
	&& rm MRO-*.deb

## Donwload and install MKL as user docker so that .Rprofile etc. are properly set
#RUN wget https://mran.revolutionanalytics.com/install/mro/$MRO_VERSION/RevoMath-$MRO_VERSION.tar.gz \
RUN curl -LO -# https://mran.revolutionanalytics.com/install/mro/$MRO_VERSION/RevoMath-$MRO_VERSION.tar.gz \
	&& tar -xzf RevoMath-$MRO_VERSION.tar.gz
WORKDIR /home/docker/RevoMath
COPY ./RevoMath_noninteractive-install.sh RevoMath_noninteractive-install.sh
RUN ./RevoMath_noninteractive-install.sh \
	|| (echo "\n*** RevoMath Installation log ***\n" \
	&& cat mkl_log.txt \
	&& echo "\n")

WORKDIR /home/docker
RUN rm RevoMath-*.tar.gz \
	&& rm -r RevoMath

# print MKL license on every start
#COPY mklLicense.txt mklLicense.txt
#RUN echo 'cat("\n", readLines("/home/docker/mklLicense.txt"), "\n", sep="\n")' >> /usr/lib64/MRO-$MRO_VERSION/R-$MRO_VERSION/lib/R/etc/Rprofile.site

## Install the Hadleyverse packages (and some close friends).
COPY ./install-packages.R install-packages.R
RUN R -f install-packages.R


WORKDIR /home/docker


CMD ["/usr/bin/R"]
