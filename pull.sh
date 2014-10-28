#!/usr/bin/env bash

git clone git@github.com:wvanbergen/chunky_png.git lib/bench/benchmarks/chunky_png/chunky_png
pushd lib/bench/benchmarks/chunky_png/chunky_png
git checkout efd61c8d0ddcabdcf09fb44f8e8c1ba709995940
rm -rf .git*
patch -p1 < ../chunky_png.patch
popd

git clone git@github.com:wvanbergen/oily_png.git lib/bench/benchmarks/chunky_png/oily_png
pushd lib/bench/benchmarks/chunky_png/oily_png
git checkout 705202d54c891c709a2c9075e6d0cd4bba04f209
rm -rf .git*
popd

git clone git@github.com:layervault/psd.rb.git lib/bench/benchmarks/psd.rb/psd.rb
pushd lib/bench/benchmarks/psd.rb/psd.rb
git checkout e14d652ddc705e865d8b2b897d618b25d78bcc7c
rm -rf .git*
popd

git clone git@github.com:layervault/psd_native.git lib/bench/benchmarks/psd.rb/psd_native
pushd lib/bench/benchmarks/psd.rb/psd_native
git checkout bbea04db2f4f483bde73b6793e68eff73f3b9c3f
rm -rf .git*
patch -p1 < ../psd_native.patch
popd

curl http://code.jquery.com/jquery-2.1.1.js > lib/bench/report/jquery.js

curl https://raw.githubusercontent.com/nnnick/Chart.js/master/Chart.js > lib/bench/report/chart.js
pushd lib/bench/report
patch -p1 < chartjs.patch
popd

curl https://code.jquery.com/jquery-2.1.1.min.js > lib/bench/report/jquery.js
curl http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css > lib/bench/report/bootstrap.css
curl http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css > lib/bench/report/bootstrap-theme.css
curl http://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js > lib/bench/report/bootstrap.js
