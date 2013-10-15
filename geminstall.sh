#!/bin/bash

cd /usr/src 
sudo wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.17.tgz
sudo tar xvzf rubygems-1.8.17.tgz
cd rubygems-1.8.17
sudo ruby setup.rb
