FROM rocker/tidyverse:latest

# Stay as root
USER root

# Install PostgreSQL support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN install2.r --error \
    RPostgreSQL \
    RPostgres \
    DBI

# Set permissions
RUN chown -R rstudio:rstudio /home/rstudio && \
    chmod -R 755 /home/rstudio

# Environment variables for Railway
ENV DISABLE_AUTH=true
ENV ROOT=FALSE
ENV USER=rstudio

EXPOSE 8787

CMD ["/init"]
