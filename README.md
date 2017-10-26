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


