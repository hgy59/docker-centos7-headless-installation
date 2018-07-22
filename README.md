# docker-centos7-headless-installation
Docker image to create custom centos 7 iso files for headless installation

## Getting Started
Use the docker image to build iso files from original Centos 7 iso files for installation on headless devices, i.e. use the serial console to install Centos 7.
Thanks to docker you may create such images on Windows, OSX or linux.

## Prerequisites
Download the original iso file(s).

## Running
Provide the folder with the source iso files and a folder for targets as volumes.


```
docker run --rm --privileged -v /tmp/iso:/iso -v /tmp/target:/target hpgy/centos7-headless-installation
```
Every *.iso file in your iso folder will be converted to a headless installer version in the target folder.

Optionally  specify the name of a single source file located in the iso folder with `SOURCE`:
```
docker run --rm --privileged -v /tmp/iso:/iso -v /tmp/target:/target -e SOURCE=CentOS-7-x86_64-Minimal-1804.iso hpgy/centos7-headless-installation
```

With a specific source file it is possible to specify the name of the target iso file with `TARGET`:
```
docker run --rm --privileged -v /tmp/iso:/iso -v /tmp/target:/target -e SOURCE=CentOS-7-x86_64-Minimal-1804.iso -e TARGET=Centos-1804-headles.iso hpgy/centos7-headless-installation
```

## Apply a kickstart file
To create an installation with a kickstart file you can provide the `ks.cfg` file in the custom volume and run the creation with the container like this:
```
docker run --rm --privileged -v /tmp/iso:/iso -v /tmp/target:/target -v /tmp/custom:/custom hpgy/centos7-headless-installation
```
You may specifiy a different kickstart file in the custom volume with `KS_CFG`:
```
docker run --rm --privileged -v /tmp/iso:/iso -v /tmp/target:/target -v /tmp/custom:/custom -e KS_CFG=abc-ks.cfg -e SOURCE=CentOS-7-x86_64-Minimal-1804.iso -e TARGET=abc-test.iso hpgy/centos7-headless-installation
```
## Add custom rpm files
To add additional rpm files to the repository on the installation media you can specify the `RPM_DIR` folder as a folder in the custom volume and run the creation with the container like this:
```
docker run --rm --privileged -v /tmp/iso:/iso -v /tmp/target:/target -v /tmp/custom:/custom -e RPM_DIR=my_rpms -e SOURCE=CentOS-7-x86_64-Minimal-1804.iso hpgy/centos7-headless-installation
```

You may customize you installation media with a kickstart file and additional rpm files.

## Result
You will find the generated iso file(s) in your target folder.

On Windows use Win32DiskImager and on linux systems use dd command to create USB medium from the generated iso file.

## Kudos
The script for the creation of the headless iso files is based on the informations published by [meetcareygmailcom](https://meetcarey.wordpress.com/2016/08/16/first-blog-post/).
