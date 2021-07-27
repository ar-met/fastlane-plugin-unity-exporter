git checkout master # making sure that we are on the master branch before starting merge
git merge develop --no-ff
git push --all

rake release
