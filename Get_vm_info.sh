#!/bin/bash
#puts host 
echo -n `cat /proc/cpuinfo | egrep "core id|physical id" | tr -d "\n" | sed s/physical/\\nphysical/g | grep -v ^$ | sort | uniq | wc -l` 
echo -n ' ' 
echo -n `cat /proc/meminfo | grep MemTotal |awk '{print $2}'`  
echo -n ' ' 
df -h / | head -3 |tail -1 |awk '{print $1}'
