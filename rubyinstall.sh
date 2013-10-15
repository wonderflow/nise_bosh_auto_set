#!/bin/bash
 
if ! (which wget); then
  sudo apt-get update
  sudo apt-get install -y wget
fi

if [ ! `which gcc` ]; then
  if [ `ls | grep sources.list` ]; then
    sudo cp sources.list /etc/apt/sources.list
    sudo apt-get update
    rm sources.list
  fi
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install gcc
fi

sudo apt-get -y install build-essential libssl-dev libreadline-gplv2-dev zlib1g-dev

#yaml install
cd /usr/src
sudo wget http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
sudo tar xvzf yaml-0.1.4.tar.gz
cd yaml-0.1.4
sudo ./configure --prefix=/usr/local
sudo make 
sudo make install

#ruby install
INSTALLER_URL=${INSTALLER_URL:-http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p448.tar.gz}
source /etc/environment
if [ ! `ls | grep ruby-1.9.3-p448.tar.gz` ]; then
  sudo wget ${INSTALLER_URL}
fi
sudo cp ruby-1.9.3-p448.tar.gz /usr/src/

cd /usr/src
if [ ! -d ruby-1.9.3-p448 ]; then
  sudo tar xvzf ruby-1.9.3-p448.tar.gz
fi

cd ruby-1.9.3-p448
if ! (which ruby); then
  sudo ./configure --prefix=/usr/local --enable-shared --disable-install-doc --with-opt-dir=/usr/local/lib --with-openssl-dir=/usr --with-readline-dir=/usr --with-zlib-dir=/usr
  sudo make
  sudo make install
fi

#rubygems install
cd /usr/src 
sudo wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.17.tgz
sudo tar xvzf rubygems-1.8.17.tgz
cd rubygems-1.8.17
sudo ruby setup.rb
