FROM rocker/shiny-verse:latest

# system libraries of general use
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev\
    ## clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN R -e "install.packages('remotes')"
RUN R -e "install.packages(c('timetk'), repos='https://cloud.r-project.org/')"
RUN R -e "remotes::install_github('rstudio/renv')"
RUN R -e "options(renv.config.repos.override = 'https://packagemanager.posit.co/cran/latest')"

# clean up
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

# Copy shiny app into the Docker image
COPY app /srv/shiny-server/
RUN chown -R shiny:shiny /srv/shiny-server


# Copy shiny app execution file into the Docker image and set permisisions
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh # Added


EXPOSE 3838

USER shiny

CMD ["/usr/bin/shiny-server"] 

