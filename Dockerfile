# syntax    = docker/dockerfile:1.4

FROM mcr.microsoft.com/powershell:latest

RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y tzdata
RUN ln -snf /usr/share/zoneinfo/Europe/Athens /etc/localtime && echo "Europe/Athens" > /etc/timezone

# Create a directory to store the PowerShell script
RUN mkdir /scripts
ARG API_KEY
ARG POAPI_KEY
ARG POUSER_KEY

# Set environment variables from build arguments
ENV API_KEY=${API_KEY}
ENV POAPI_KEY=${POAPI_KEY}
ENV POUSER_KEY=${POUSER_KEY}

RUN cat /etc/resolv.conf
# Set the working directory
WORKDIR /scripts
# Mount the secret and use it in the build process
RUN --mount=type=secret,id=mysecret \
    export API_KEY=$(cat /run/secrets/mysecret | grep ^API_KEY) && \
    export POAPI_KEY=$(cat /run/secrets/mysecret | grep ^POAPI_KEY) && \
    export POUSER_KEY=$(cat /run/secrets/mysecret | grep ^POUSER_KEY) && \
    echo $API_KEY $POAPI_KEY $POUSER_KEY
# Copy the PowerShell script into the container
COPY image_sources.csv /scripts/
COPY script.ps1 /scripts/
# Execute the PowerShell script using JSON array syntax for CMD
CMD ["pwsh", "./script.ps1"]
