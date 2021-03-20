![](https://github.com/SergeyMi37/apptools-util/blob/master/doc/hammer-green.png)
## apptools-util
[![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/apptools-util-1)

Template and examples for creating a user interface for administrative utilities.

## What's new
This project is not only a set of [tools for the administrator](#PanelAdmin), but a platform for the rapid creation of a prototype of any solution.
For example, Photo Album, Music Player, and Personal Books Library all come together in a user-friendly treasure chest design.

Load http:// your-host:your-port/apptoolsrest/a/adminsample

Load http:// your-host:your-port/apptoolsrest/a/permiss

## Installation with ZPM

zpm:USER>install apptools-util

## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/SergeyMi37/apptools-util.git
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it
Open IRIS terminal:

```
$ docker-compose exec iris iris session iris
USER>
USER>zpm
zpm:USER>install apptools-util
```




