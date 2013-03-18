#!/bin/sh -xe

brunch build
cp -r public ../
cp -r node_modules ../
git stash -u
git checkout gh-pages
rm -rf *
cp -r ../public/ .
git add --all
git commit -m 'update site'
git push
git checkout develop
git stash pop
cp -r ../node_modules .
rm -rf ../public
rm -rf ../node_modules
