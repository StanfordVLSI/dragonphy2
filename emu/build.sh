#!/bin/sh

mkdir -p project
vivado -nolog -nojournal -mode batch -source build.tcl
