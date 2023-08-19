#! /bin/bash
# Root directory to cd into.
dir=$1
excluded=""
command="cppclean $dir/src/GoonDash | egrep -Ev '$excluded'"
echo $command
cppcleanlines=$(eval $command '| wc -l')
# Use this to see the command output for debugging
eval $command
# If there is any output, stop and we should fix these.
if [[ $cppcleanlines -ne 0 ]]
then
  echo "Problem with cppclean command"
  eval $command
  exit 1
else
    exit 0
fi