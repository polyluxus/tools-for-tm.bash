#!/bin/bash

[[ -z $1 ]] && { echo "ERROR: Supply turbomole input file" ; exit 1 ; }

filename="$1"

get_energy_line ()
{
  local input="$1"
  tail -n 2 "$input" | head -n 1
}

extract_scf_energy ()
{
  local input_line="$1"
  local pattern_cycle="[[:digit:]]+"
  local pattern_energy="[+-]?[[:digit:]]+\\.[[:digit:]]+"
  local pattern="^[[:space:]]*($pattern_cycle)[[:space:]]+($pattern_energy)[[:space:]]+($pattern_energy)[[:space:]]+($pattern_energy)[[:space:]]*$"
  [[ "$input_line" =~ $pattern ]] &&  echo "${BASH_REMATCH[2]}"
}

print_scf_energy ()
{
  local input_file="$1"
  local retrieved_line returned_value
  retrieved_line=$(get_energy_line "$input_file")
  returned_value=$(extract_scf_energy "$retrieved_line")
  echo "$returned_value"
}

printf '%-50s: %25f\n' "${filename}" "$(print_scf_energy "${filename}")"

