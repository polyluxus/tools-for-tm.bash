#!/bin/bash

# The following script gives default values to any of the scripts within the package.
# They can (or should) be set in the rc file, too.

# If this script is not sourced, return before executing anything
if (( ${#BASH_SOURCE[*]} == 1 )) ; then
  echo "This script is only meant to be sourced."
  exit 0
fi

#
# Generic details about these tools 
#
softwarename="tools-for-tm.bash"
version="0.0.0_dev"
versiondate="2018-11-XX"

#
# Standard commands for external software:
#
# Turbomole related options
#
# General path to the turbomole directory (this should work on every system, but it is not tested)
tm_installpath="/path/is/not/set"
# If a modular software management is available, use it?
load_modules="true"
# For example: On the RWTH cluster Gaussian is loaded via a module system,
# the names (in correct order) of the modules:
tm_modules[0]="CHEMISTRY"
tm_modules[1]="turbomole-smp/7.3.0"

# Options related to use open babel (currently unused for turbomole)
obabel_cmd="obabel"

#
# Default files and suffixes
#
# tm_input_suffix="com" (there is no inputfile for these calculations)
tm_output_suffix="log"

#
# Default options for printing (currently unused for turbomole)
#
values_separator=" " # (space separated values)
output_verbosity=0

#
# Default values for queueing system submission
#
# Select a queueing system (pbs-gen/bsub-rwth) # TODO: bsub-gen
request_qsys="bsub-rwth"
# Walltime for remote execution, header line for the queueing system
requested_walltime="24:00:00"
# Specify a default value for the memory (MB) (It'll be scaled back to include overhead)
# Should be at least 500 per CPU + 30%
requested_memory=3000
# This corresponds to nthreads/NProcShared (etc)
requested_numCPU=4
# Account to project (currently only for bsub-rwth)
bsub_project=default
# Request a machinetype
bsub_machinetype=default
# Calculations will be submitted to run (hold/keep)
requested_submit_status="run"

