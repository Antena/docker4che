# docker4che
Dockerfile to build and run dcm4che

####Requirements####

* Docker (https://docs.docker.com/installation/)

####Usage####

First run:

    docker build --rm=true -t dcm4chee .
    
For successive builds, a bash script is provided:

    bash ./setup.bash
    
To run the container:

    bash ./run.bash
