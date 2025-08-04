FROM rocker/rstudio:latest

# Switch to root for installations
USER root

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    postgresql-client \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c( \
    'DBI', \
    'RPostgreSQL', \
    'RPostgres', \
    'rgoogleads', \
    'readr', \
    'dplyr', \
    'tidyr', \
    'httr', \
    'jsonlite', \
    'jose', \
    'ggplot2' \
    ), repos='https://cran.rstudio.com/')"

# Create a test script
RUN echo '#!/usr/bin/env Rscript\n\
library(DBI)\n\
library(RPostgreSQL)\n\
cat("RPostgreSQL successfully installed!\\n")\n\
cat("Version:", packageVersion("RPostgreSQL"), "\\n")' > /usr/local/bin/test_postgres.R

RUN chmod +x /usr/local/bin/test_postgres.R

# Set environment variables for Railway PostgreSQL connection
ENV DB_HOST=switchyard.proxy.rlwy.net \
    DB_PORT=57686 \
    DB_NAME=railway \
    DB_USER=rest_api_user \
    DB_PASSWORD=Goquestdb123

# Switch back to rstudio user
USER rstudio

WORKDIR /home/rstudio

# Expose RStudio port
EXPOSE 8787

CMD ["/init"]
