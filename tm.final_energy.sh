#!/bin/bash

###
#
# tools-for-tm.bash -- 
#   A collection of tools for the help with Turbomole.
# Copyright (C) 2019 Martin C Schwarzer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
###

if [[ "$1" == "debug" ]] ; then
  exec 4>&1
  shift
else
  exec 4> /dev/null
fi

if [[ "$1" == '-h' ]] ; then
  echo "${0##*/} finds the final turbomole energy from a given file (default: control)"
  exit 0
fi

filename="${1:-control}"
exit_status=0

[[ -r $filename ]] || { echo "ERROR: File '$filename' not readable." >&2 ; exit 1 ; }

debug ()
{
  echo "debug: $*" >&4
}

get_energy_line ()
{
  # Suppose we are dealing with the energy file, the last line is '$end'
  local testfile="$1"
  debug "testfile $testfile"
  local line showline
  local pattern_start='\$energy'
  local pattern_end='\$end'
  local reading_energies
  while read -r line || [[ -n "$line" ]] ; do
  debug "line  |$line"
    #echo "$line"
    if [[ -z $reading_energies ]] ; then
      debug "not reading"
      if [[ $line =~ $pattern_start ]] ; then
        debug "start matched"
        reading_energies=true
        continue
      fi
    else
      debug "    reading"
      debug "showline  |$showline"
      if [[ $line =~ $pattern_end ]] ; then
        debug "end matched"
        unset reading_energies
        debug "returning  |$showline"
        echo "$showline"
        return 0
      fi
      showline="$line"
    fi
  done < "$testfile"
  return 1
}

extract_scf_energy ()
{
  local input_line="$1"
  local pattern_cycle="[[:digit:]]+"
  local pattern_energy="[+-]?[[:digit:]]+\\.[[:digit:]]+"
  local pattern="^[[:space:]]*($pattern_cycle)[[:space:]]+($pattern_energy)[[:space:]]+($pattern_energy)[[:space:]]+($pattern_energy)[[:space:]]*$"
  if [[ "$input_line" =~ $pattern ]] ; then 
    echo "${BASH_REMATCH[2]}"
    return 0
  fi
  return 1
}

search_and_print_scf_energy ()
{
  local testfile="$1"
  local retrieved_line returned_value
  retrieved_line=$(get_energy_line "$testfile") || return 1
  returned_value=$(extract_scf_energy "$retrieved_line") || return 1
  echo "$returned_value"
}

resolve_energy_group ()
{
  local testfile="$1"
  local line
  local found_file
  local pattern='\$energy[[:space:]]*file=([^[:space:]]*)'
  while read -r line || [[ -n "$line" ]] ; do
    #echo "$line"
    if [[ $line =~ $pattern ]] ; then
      found_file="${BASH_REMATCH[1]}"
      [[ -r "$found_file" ]] || { echo "ERROR: Identified file '$found_file' not readable." >&2 ; exit 1 ; }
      search_and_print_scf_energy "$found_file" || return 1
      return 0
    fi
  done < "$testfile"
  search_and_print_scf_energy "$testfile" || return 1
}


printf '%-50s: %25f\n' "${filename}" "$( resolve_energy_group "${filename}" )" || exit_status=1

(( exit_status > 0 )) && { echo "ERROR: Energy not found." ; exit 1 ; }
