#!/bin/bash
if [ `ls | grep sources.list` ]; then
  sudo cp sources.list /etc/apt/sources.list
  sudo apt-get update
  rm sources.list
fi
 
#set blob files
cd /home/vcap

if [ ! -d adeploy ]; then
  echo "start to tar adeploy.gz. it may take time..."
  tar xzf adeploy.gz

  echo "move files finished "
  mkdir vcap
  mv  /home/vcap/adeploy/deploy /home/vcap/vcap/
  sudo mv  /home/vcap/adeploy/vcap /var
fi

