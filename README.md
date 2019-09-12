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

## License (GNU General Public License v3.0)

tools-for-tm.bash - a collection of scripts for turbomole  
Copyright (C) 2019 Martin C Schwarzer

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See [LICENSE](LICENSE) to see the full text.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

Martin (0.0.3, 2019-09-13)
