#!/bin/bash

# !!! something important about permission!!!

#Nise BOSH init 
echo '+sudo ./bin/init'
cd /home/vcap/vcap/deploy/nise_bosh
sudo ./bin/init

echo '+install gcc'
if [ ! `which gcc` ]; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install gcc
  #sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y --force-yes --no-install-recommends gcc
fi

echo '+install other packages'

sudo apt-get install build-essential libssl-dev libreadline5-dev zlib1g-dev libxslt-dev libxml2-dev git-core

cd /home/vcap

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
if [ ! -d rubygems-1.8.17 ]; then
  sudo tar xzf rubygems-1.8.17.tgz
fi

cd rubygems-1.8.17
if  ! (which gem); then
  sudo ruby setup.rb
fi



#install gem packages
sudo gem install bundler
sudo gem install rake
sudo gem install bosh_cli

#get gem dependent files
cd /home/vcap/vcap/deploy/nise_bosh/
sudo bundle install

cd /var/vcap/packages/cloud_agent/
sudo bundle install
#ERROR,solution

