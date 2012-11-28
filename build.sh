#!/bin/sh
# Inspired by http://davegamache.com/hosted-on-github/

jekyll \
  && cp -r _site/ ../tmp \
  && git checkout master \
  && cp -r ../tmp/* ./ \
  && rm -r ../tmp \
  && git add -A \
  && git status
