# Source to build a Debian package of Wims


## Warnings

* You have to build the package on **Debian Stretch**.
* This package is supposed to work on **Debian Stretch**.
* This package is very simple by design and absolutely **not Debian
  policy compliant** (all is put in `/opt/wims/`).


## Install the environment to build the package

These commands should be launched only once:

```sh
apt-get update && apt-get install -y git ca-certificates openssl make
git clone https://github.com/flaf/debian-pkg-wims.git
cd debian-pkg-wims
./make install-env
```

## Build the package

At the root of this Git repository, you can launch:

```sh
./make build && echo 'Build is OK!'
ls -l *.deb
```

Normally, there is a package `wims-dbgsym_x.y-n_amd64.deb`
too. If I have well understood, it's a feature of Debian to
have (automatically) a package for debug. Personally, I just
ignore this package and I use ``wims_x.y-n_amd64.deb.


