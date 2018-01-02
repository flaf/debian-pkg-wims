# How to build the Wims Debian package from source


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
ignore this package and I just use the package
`wims_x.y-n_amd64.deb`.


## How to install the package

**Warning:** this package is supposed to work on **Debian
Stretch amd64**.

You have to put the package in a APT repository or you
can you this APT repository: https://apt.ac-versailles.fr/
(http protocol is possible too). Below I assume you use
the APT repository https://apt.ac-versailles.fr/. Here is
the command to install the Wims server from a Debian Stretch:

```sh
# Required only if you use the APT repository via HTTPS.
apt-get update && apt-get install apt-transport-https

# Set the additional APT repository. If you prefer,
# you can replace "https://" by "http://".
echo deb https://apt.ac-versailles.fr/ stretch main > /etc/apt/sources.list.d/wims.list
wget http://apt.ac-versailles.fr/public-key.pgp -O - | apt-key add -

# Installation of Wims.
apt-get update && apt-get install wims
```

Now, Wims is installed and you should be able to visit the
page `http://IP-OF-YOUR-SERVER/wims/`.

If you want to redirect the path `/` to `/wims/`, you can
add the file `/etc/apache2/conf-available/wims-custom.conf`
with this content:

```apache
RedirectMatch permanent ^/$ /wims/
```

Then to activate the configuration:

```sh
a2enconf wims-custom
service apache2 restart
```

If you want to enable SSL, then you can edit the file
`/etc/apache2/conf-available/wims-custom.conf` like this :

```apache
RedirectMatch permanent ^/$ /wims/

<IfModule mod_ssl.c>
    SSLEngine             on
    SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
        SSLOptions +StdEnvVars
    </FilesMatch>

    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>
</IfModule>
```

Then to activate the configuration:

```sh
a2enconf wims-custom
a2enmod ssl
service apache2 restart
```

By default, `/etc/ssl/certs/ssl-cert-snakeoil.pem` is a self
signed certificate (signed via the private key
`/etc/ssl/private/ssl-cert-snakeoil.key`) with the value of
`hostname --fqdn` as "Subject Alternative Name". Of course,
you can change the configuration above to use another (and
not self signed) certificate.


