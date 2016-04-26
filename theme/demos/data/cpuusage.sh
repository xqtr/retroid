#!/bin/bash
#export CPUUSAGE="$(top -bn1 | awk '/Cpu/ { cpu = 100 - $8 }; END   { print cpu }')"
export CPUUSAGE="$(top -bn2 -d 0.01 | grep '%Cpu.s.' | tail -n 1 | gawk '{print $2+$4+$6}')"
