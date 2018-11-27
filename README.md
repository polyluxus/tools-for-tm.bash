# tools-for-tm.bash

This repository will (hopefully someday) contain various bash scripts 
to aid the use of the quantum chemistry software package Turbomole.

This is still a work in progress and currently only contains a script to 
create a sumbit script for a batch queueing system.

Please understand, that this project is primarily for me to help my everyday work. 
I am happy to hear about suggestions and bugs. 
I am fairly certain, that it will be a work in progress for quite some time 
and might be therefore in constant flux. 
This 'software' comes with absolutely no warrenty. None. Nada.
If you decide to use any of the scripts, it is entirely your resonsibility. 

## Installation

If you want to use the scripts, clone this repository.
The files in it are not self-contained. 
They each need access to the resources directory.
The scripts can be configured with the help of `tm.tools.rc`; 
more advisable, however, is to copy this file onto `.tm.toolsrc`
and modify this file instead.

To make the files accessible globally, the directory where they have been stored
must be in the `PATH` variable.
Alternatively, you can create softlinks to those files in a directory, 
which is already recognised by `PATH`, e.g. `~/bin` in my case.

## Utilities

This reposity comes with the following scripts (and files):

 * `tm.submit.sh`
   This tool parses and then submits a Gaussian 16 inputfile to a queueing system.

All of the scripts come with a `-h` switch to give a summary of the available options.

Martin (0.0.1.dev, 2018-11-XX)
