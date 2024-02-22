#!/bin/bash

set -e

rm -rf makelove-build
makelove lovejs
unzip -o "makelove-build/lovejs/drakeshot-lovejs" -d makelove-build/html/
echo "http://localhost:8000/makelove-build/html/drakeshot/"
python3 -m http.server