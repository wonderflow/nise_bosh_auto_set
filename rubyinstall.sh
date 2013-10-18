#!/bin/bash

# !!! something important about permission!!!
 
if ! (which wget); then
  sudo apt-get update
  sudo apt-get install -y wget
fi

if [ ! `which gcc` ]; then
  if [ `ls | grep sources.list` ]; then
    sudo cp sources.list /etc/apt/sources.list
if [ ! `ls | grep ruby-1.9.3-p448.tar.gz` ]; then
  sudo wget ${INSTALLER_URL}
fi
    sudo apt-get update
    rm sources.list
  fi
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install gcc
fi

sudo apt-get -y install build-essential libssl-dev libreadline-gplv2-dev zlib1g-dev git-core libxslt-dev libxml2-dev

sudo cp yaml-0.1.4.tar.gz /usr/src
sudo cp ruby-1.9.3-p448.tar.gz /usr/src
sudo cp rubygems-1.8.17.tgz /usr/src


#yaml install
cd /usr/src
sudo tar xzf yaml-0.1.4.tar.gz
cd yaml-0.1.4
sudo ./configure --prefix=/usr/local
sudo make 
sudo make install

#ruby install
cd /usr/src
if [ ! -d ruby-1.9.3-p448 ]; then
  sudo tar xzf ruby-1.9.3-p448.tar.gz
fi

cd ruby-1.9.3-p448
if ! (which ruby); then
  sudo ./configure --prefix=/usr/local --enable-shared --disable-install-doc --with-opt-dir=/usr/local/lib --with-openssl-dir=/usr --with-readline-dir=/usr --with-zlib-dir=/usr
  sudo make
  sudo make install
fi

#rubygems install
cd /usr/src 
sudo tar xzf rubygems-1.8.17.tgz
cd rubygems-1.8.17
sudo ruby setup.rb

#set blob files
cd /home/vcap
tar xzf adeploy.gz
mkdir vcap
mv  /home/vcap/adeploy/deploy /home/vcap/vcap/
sudo mv  /home/vcap/adeploy/vcap /var


#install gem packages
sudo gem install bundler
sudo gem install rake

#get gem dependent files
cd /home/vcap/vcap/deploy/nise_bosh/
bundle install
#ERROR,solution

#install bosh
sudo gem install bosh_cli
