#!/usr/bin/zsh

for ps in ./*.ps; do
  ps2pdf $ps
  rsync -avz -stat ${ps:r}.pdf gate:output/.
done
