# docker4che
Dockerfile to build and run dcm4che

####Requirements####

* Docker (https://docs.docker.com/installation/)

####Usage####

To build the container:

    docker build --rm=true -t dcm4chee .
    
To run the container:

    docker run -p 8080:8080 -p 11112:11112 dcm4chee

To access the dcm4chee web-console: http://192.168.59.103:8080/dcm4chee-web3/
