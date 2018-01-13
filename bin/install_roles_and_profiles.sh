#!/bin/sh
rm -rf $1/site
git clone https://github.com/igorovic/puppet_roles_and_profiles.git $1/site/ && rm -rf $1/site/.git