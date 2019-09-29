#!/bin/bash

mkdir -p project
vivado -nolog -nojournal -mode batch -source build.tcl
