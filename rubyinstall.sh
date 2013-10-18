#!/bin/bash

# !!! something important about permission!!!
if [ `ls | grep sources.list` ]; then
  sudo cp sources.list /etc/apt/sources.list
  sudo apt-get update
  rm sources.list
fi
 
#set blob files
cd /home/vcap
echo "\nstart to tar adeploy.gz. it may take time..."
tar xzf adeploy.gz
mkdir vcap
mv  /home/vcap/adeploy/deploy /home/vcap/vcap/
sudo mv  /home/vcap/adeploy/vcap /var

#Nise BOSH init
cd /home/vcap/vcap/deploy/nise_bosh
sudo ./bin/init

if [ ! `which gcc` ]; then
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install gcc
  #sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y --force-yes --no-install-recommends gcc
fi

sudo apt-get -y install build-essential libssl-dev libreadline-gplv2-dev zlib1g-dev libxslt-dev libxml2-dev git-core

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
sudo tar xzf rubygems-1.8.17.tgzsudo cd /home/vcap
sudo mkdir vcap
sudo mv -r /home/vcap/adeploy/deploy /home/vcap/vcap/
sudo mv -r /home/vcap/adeploy/vcap /var

cd rubygems-1.8.17
sudo ruby setup.rb



#install gem packages
sudo gem install bundler
sudo gem install rake

#get gem dependent files
cd /home/vcap/vcap/deploy/nise_bosh/
bundle install
#ERROR,solution

#install bosh
sudo gem install bosh_cli
