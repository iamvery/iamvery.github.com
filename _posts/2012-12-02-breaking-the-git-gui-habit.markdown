---
layout: post
title: Breaking the git gui habit
---

I have been long-time dependent on Git's `gitk` application for my work. I suppose I'm just
visually minded, because it is quite difficult for me to work 100% command line with Git. A
couple days ago I was inspired again to look for command line alternatives to satisfy my
visual habit and found a very helpful customization of `git log`.

    # Found at: http://gitready.com/intermediate/2009/01/13/visualizing-your-repo.html#comment-445365575
    git log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative

The format it produces is quite nice! Something along the lines of (plus coloring you can't see here):

    * 34cb970 - (HEAD, jekyll) Fixed some problem (6 seconds ago)
    * d6c114d - (origin/jekyll, origin/HEAD) Added some meta content to site head (19 hours ago)
    * d77a0eb - Removed ruby age from about markdown (19 hours ago)
    * a8d2ea7 - Added CNAME file for github custom domain name (2 days ago)
    * a666cec - Updated resume (2 days ago)
    * f0ee430 - Added assets and updated markup to match current site (2 days ago)
    * 335d3a1 - Ignore sass cache (2 days ago)
    | * 7e8f3f9 - (some-feature) Started some feature (53 seconds ago)
    |/  
    * aa61903 - Removed haml; Decided there's really no benefit and it complicates build (2 days ago)
    * 601e9bc - Made haml title single line (5 days ago)

This quickly became the `glog` alias in my `.zshrc` ;)