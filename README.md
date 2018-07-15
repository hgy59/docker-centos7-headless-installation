# docker-centos7-headless-installation
Docker image to create custom centos 7 iso files for headless installation

## Getting Started
Use the docker image to build iso files from original Centos 7 iso files for installation on headless devices, i.e. use the serial console to install Centos 7.
You may even use the image on Windows OS.

## Prerequisites
Download the original iso file.

## Running
Provide the folder with the iso file(s) and a folder for the created iso files as volumes.

```
docker run --rm --privileged -v /downloads/iso:/iso -v /headless/target:/target hpgy/centos7-headless-installation
```

Every iso file in your iso folder will be converted to a headless installer version named as *-headless.iso.

## Result
You will find the generated iso file(s) in your target folder.

On Windows use Win32DiskImager and on linux systems use dd command to create USB medium from the generated iso file.

## Kudos
The script for the creation of the headless iso files is based on the informations published by [meetcareygmailcom](https://meetcarey.wordpress.com/2016/08/16/first-blog-post/).
