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


# Copy app files to the container
COPY . /app

# Set the working directory
WORKDIR /app

# Install R packages using renv and package repository override
RUN R -e "options(renv.config.repos.override = 'https://packagemanager.posit.co/cran/latest'); renv::restore()"

# Set environment variable for Shiny to listen to the specified PORT
ENV PORT 8080

# Expose the port (for Cloud Run's use)
EXPOSE 8080

# Run the Shiny app, dynamically using the PORT environment variable
CMD ["R", "-e", "shiny::runApp('/app/app.R', host = '0.0.0.0', port = as.numeric(Sys.getenv('PORT')))"]

"""

# clean up
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

# Copy shiny app into the Docker image
COPY app /srv/shiny-server/

RUN rm /srv/shiny-server/index.html

# Make the ShinyApp available at port 5000
EXPOSE 8080

# Copy shiny app execution file into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh


USER shiny """

#CMD ["/usr/bin/shiny-server"] 

