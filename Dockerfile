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


## Install some useful tools and dependencies
RUN apt-get update \
	  && apt-get install -y --no-install-recommends \
               ed \
               littler \
#               r-cran-littler \
    && ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
	  && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
	  && ln -s /usr/share/doc/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
	  && ln -s /usr/share/doc/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
	  && install.r docopt \
	  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
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
RUN install.r --error \
#    -r "https://cran.rstudio.com" \
#    -r "http://www.bioconductor.org/packages/release/bioc" \
    ggplot2 \
    ggthemes \
    haven \
    httr \
    knitr \
    lubridate \
    reshape2 \
    readr \
    readxl \
    revealjs \
    rmarkdown \
    rstudioapi \
    rticles \
    rvest \
    rversions \
    testthat \
    stringr

## Manually install (useful packages from) the SUGGESTS list of the above packages.
## (because --deps TRUE can fail when packages are added/removed from CRAN)
RUN install.r --error \
    -r "https://cran.rstudio.com" \
    -r "http://www.bioconductor.org/packages/release/bioc" \
    base64enc \
    BiocInstaller \
    bitops \
    crayon \
    codetools \
    covr \
    data.table \
    doParallel \
    downloader \
    evaluate \
    formula.tools \
    git2r \
    gridExtra \
    gmailr \
    gtable \
    hexbin \
    Hmisc \
    htmlwidgets \
    hunspell \
    jpeg \
    Lahman \
    lattice \
    lintr \
    MASS \
    openxlsx \
    PKI \
    png \
    microbenchmark \
    mgcv \
    mapproj \
    maps \
    maptools \
    mgcv \
    mosaic \
    multcomp \
    nlme \
    nycflights13 \
    quantreg \
    Rcpp \
    rJava \
    roxygen2 \
    RMySQL \
    RPostgreSQL \
    RSQLite \
    stargazer \
    testit \
    V8 \
    withr \
    XML \
#  && r -e 'source("https://raw.githubusercontent.com/MangoTheCat/remotes/master/install-github.R")$value("mangothecat/remotes")' \
#  && r -e 'remotes::install_github("wesm/feather/R")' \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds





WORKDIR /home/docker


CMD ["/usr/bin/R"]
