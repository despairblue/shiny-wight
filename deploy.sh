#!/bin/sh -xe

brunch build
codo --private
cp -r public ../
cp -r doc ../
cp -r node_modules ../
git stash -u
git checkout gh-pages
rm -rf *
cp -r ../public/* .
cp -r ../doc .
git add --all
git commit -m 'update site'
git push
git checkout develop
git stash pop
cp -r ../node_modules .
rm -rf ../public
rm -rf ../node_modules
rm -rf ../doc
