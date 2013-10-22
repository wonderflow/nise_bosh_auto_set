#!/bin/bash
#puts host 
echo -n `cat /proc/cpuinfo | grep "processor"|sort|uniq |wc -l` 
echo -n ' ' 
echo -n `cat /proc/meminfo | grep MemTotal |awk '{print $2}'`  
echo -n ' ' 
df -h / | head -3 |tail -1 |awk '{print $1}'
