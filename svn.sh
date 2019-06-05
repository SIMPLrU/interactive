#!/bin/bash
# Stops Script on First Error
set -e
echo loading environment
echo loading variables

# ====EXIT script====
  exit 2    # Misuse of shell builtins (according to Bash documentation)
  exit 0    # Success
  exit 1    # General errors, Miscellaneous errors, such as "divide by zero" and other impermissible operations
