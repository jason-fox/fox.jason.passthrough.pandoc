curl -sLO https://github.com/jgm/pandoc/releases/download/2.10.1/pandoc-2.10.1-1-amd64.deb
dpkg -i pandoc-2.10.1-1-amd64.deb
pandoc --version
echo
which pandoc