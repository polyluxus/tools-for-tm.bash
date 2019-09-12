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

#hlp   ${0##*/} finds the final turbomole energy from a given file,
#hlp   or if none is given it will try to parse 'control'.
#hlp
#hlp   tools-for-tm.bash  Copyright (C) 2019  Martin C Schwarzer
#hlp   This program comes with ABSOLUTELY NO WARRANTY; this is free software, 
#hlp   and you are welcome to redistribute it under certain conditions; 
#hlp   please see the license file distributed alongside this repository,
#hlp   which is available when you type '${0##*/} license',
#hlp   or at <https://github.com/polyluxus/tools-for-tm.bash>.
#hlp
#hlp   Usage: ${0##*/} [options] [FILE]
#hlp

# Reset exit status
exit_status=0

#
# Generic functions to find the scripts 
# (Copy of ./resources/locations.sh)
#
# Let's know where the script is and how it is actually called
#

get_absolute_location ()
{
    # Resolves the absolute location of parameter and returns it
    # Taken from https://stackoverflow.com/a/246128/3180795
    local resolve_file="$1" description="$2" 
    local link_target directory_name filename resolve_dir_name 
    debug "Getting directory for '$resolve_file'."
    #  resolve $resolve_file until it is no longer a symlink
    while [[ -h "$resolve_file" ]]; do 
      link_target="$(readlink "$resolve_file")"
      if [[ $link_target == /* ]]; then
        debug "File '$resolve_file' is an absolute symlink to '$link_target'"
        resolve_file="$link_target"
      else
        directory_name="$(dirname "$resolve_file")" 
        debug "File '$resolve_file' is a relative symlink to '$link_target' (relative to '$directory_name')"
        #  If $resolve_file was a relative symlink, we need to resolve 
        #+ it relative to the path where the symlink file was located
        resolve_file="$directory_name/$link_target"
      fi
    done
    debug "File is '$resolve_file'" 
    filename="$(basename "$resolve_file")"
    debug "File name is '$filename'"
    resolve_dir_name="$(dirname "$resolve_file")"
    directory_name="$(cd -P "$(dirname "$resolve_file")" && pwd)"
    if [[ "$directory_name" != "$resolve_dir_name" ]]; then
      debug "$description '$directory_name' resolves to '$directory_name'."
    fi
    debug "$description is '$directory_name'"
    if [[ -z $directory_name ]] ; then
      directory_name="."
    fi
    echo "$directory_name/$filename"
}

get_absolute_filename ()
{
    # Returns only the filename
    local resolve_file="$1" description="$2" return_filename
    return_filename=$(get_absolute_location "$resolve_file" "$description")
    return_filename=${return_filename##*/}
    echo "$return_filename"
}

get_absolute_dirname ()
{
    # Returns only the directory
    local resolve_file="$1" description="$2" return_dirname
    return_dirname=$(get_absolute_location "$resolve_file" "$description")
    return_dirname=${return_dirname%/*}
    echo "$return_dirname"
}

get_scriptpath_and_source_files ()
{
    local error_count tmplog line tmpmsg
    tmplog=$(mktemp tmp.XXXXXXXX) 
    # Who are we and where are we?
    scriptname="$(get_absolute_filename "${BASH_SOURCE[0]}" "installname")"
    debug "Script is called '$scriptname'"
    # remove scripting ending (if present)
    scriptbasename=${scriptname%.sh} 
    debug "Base name of the script is '$scriptbasename'"
    scriptpath="$(get_absolute_dirname  "${BASH_SOURCE[0]}" "installdirectory")"
    debug "Script is located in '$scriptpath'"
    resourcespath="$scriptpath/resources"
    
    if [[ -d "$resourcespath" ]] ; then
      debug "Found library in '$resourcespath'."
    else
      (( error_count++ ))
    fi
    
    # Import default variables
    #shellcheck source=./resources/default_variables.sh
    source "$resourcespath/default_variables.sh" &> "$tmplog" || (( error_count++ ))
    
    # Set more default variables
    exit_status=0
    stay_quiet=0
    # Ensure that in/outputfile variables are empty
    unset inputfile
    unset outputfile
    
    # Import other functions
    #shellcheck source=./resources/messaging.sh
    source "$resourcespath/messaging.sh" &> "$tmplog" || (( error_count++ ))
    #shellcheck source=./resources/rcfiles.sh
    source "$resourcespath/rcfiles.sh" &> "$tmplog" || (( error_count++ ))
    #shellcheck source=./resources/test_files.sh
    source "$resourcespath/test_files.sh" &> "$tmplog" || (( error_count++ ))
    #shellcheck source=./resources/validate_numbers.sh
    source "$resourcespath/validate_numbers.sh" &> "$tmplog" || (( error_count++ ))

    if (( error_count > 0 )) ; then
      echo "ERROR: Unable to locate library functions. Check installation." >&2
      echo "ERROR: Expect functions in '$resourcespath'."
      debug "Errors caused by:"
      while read -r line || [[ -n "$line" ]] ; do
        debug "$line"
      done < "$tmplog"
      tmpmsg=$(rm -v "$tmplog")
      debug "$tmpmsg"
      exit 1
    else
      tmpmsg=$(rm -v "$tmplog")
      debug "$tmpmsg"
    fi
}

#
# Specific functions for this script only
#
process_options ()
{
  #hlp   Options:
  #hlp    
  local OPTIND=1 

  while getopts :sh options ; do
      case $options in
        #hlp     -s       Suppress logging messages of the script.
        #hlp              (May be specified multiple times.)
        #hlp
          s) (( stay_quiet++ )) ;;

        #hlp     -h       this help.
        #hlp
          h) helpme ;;

         \?) fatal "Invalid option: -$OPTARG." ;;

          :) fatal "Option -$OPTARG requires an argument." ;;

      esac
  done

  # Shift all variables processed to far
  shift $((OPTIND-1))

  filename="${1:-control}"
  [[ -r $filename ]] || fatal "ERROR: File '$filename' not readable." >&2
}

if [[ "$1" == "debug" ]] ; then
  exec 4>&1
  shift
else
  exec 4> /dev/null
fi

get_energy_line ()
{
  # Suppose we are dealing with the energy file, the last line is '$end'
  local testfile="$1"
  debug "testfile $testfile"
  local line showline
  #shellcheck disable=SC2016
  local pattern_start='\$energy'
  #shellcheck disable=SC2016
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
  #shellcheck disable=SC2016
  local pattern='\$energy[[:space:]]*file=([^[:space:]]*)'
  while read -r line || [[ -n "$line" ]] ; do
    #echo "$line"
    if [[ $line =~ $pattern ]] ; then
      found_file="${BASH_REMATCH[1]}"
      [[ -r "$found_file" ]] || fatal "Identified file '$found_file' not readable."
      search_and_print_scf_energy "$found_file" || return 1
      return 0
    fi
  done < "$testfile"
  search_and_print_scf_energy "$testfile" || return 1
}

#
# MAIN SCRIPT
#

# If this script is sourced, return before executing anything
if ( return 0 2>/dev/null ) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  debug "Script is sourced. Return now."
  return 0
fi

# Save how script was called
printf -v script_invocation_spell "'%s' " "${0/#$HOME/<HOME>}" "$@"

# Sent logging information to stdout
exec 3>&1

# Need to define debug function if unknown
if ! command -v debug ; then
  debug () {
    echo "DEBUG  : " "$*" >&4
  }
fi

# Secret debugging switch
if [[ "$1" == "debug" ]] ; then
  exec 4>&1
  stay_quiet=0 
  shift 
else
  exec 4> /dev/null
fi

get_scriptpath_and_source_files || exit 1

if [[ "$1" =~ ^[Ll][Ii][Cc][Ee][Nn][Ss][Ee]$ ]] ; then
  [[ -r "$scriptpath/LICENSE" ]] || fatal "No license file found. Your copy of the repository might be corrupted."
  if command -v less &> /dev/null ; then
    less "$scriptpath/LICENSE"
  else
    cat "$scriptpath/LICENSE"
  fi
  message "Displayed license and will exit."
  exit 0
fi

# Check for settings in three default locations (increasing priority):
#   install path of the script, user's home directory, current directory
tm_tools_rc_loc="$(get_rc "$scriptpath" "/home/$USER" "$PWD")"
debug "tm_tools_rc_loc=$tm_tools_rc_loc"

# Load custom settings from the rc

if [[ -n $tm_tools_rc_loc ]] ; then
  #shellcheck source=./tm.tools.rc 
  . "$tm_tools_rc_loc"
  message "Configuration file '$tm_tools_rc_loc' applied."
else
  debug "No custom settings found."
fi

# Evaluate Options

process_options "$@"
printf '%-50s: %25f\n' "${filename}" "$( resolve_energy_group "${filename}" )" || exit_status=1

(( exit_status > 0 )) && fatal "Energy not found."
debug "Command understood: $script_invocation_spell"
