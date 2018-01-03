Source to build the Debian package `wims` from the uptream
version available on
[this page](https://sourcesup.renater.fr/frs/?group_id=379).


# How to build the Wims Debian package from source


## Warnings

* You have to build the package on **Debian Stretch amd64**.
* This package is supposed to work on **Debian Stretch amd64**.
* This package is very simple by design and absolutely **not Debian
  policy compliant** (all files are put in `/opt/wims/`).


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


# How to install the package

**Warning:** this package is supposed to work on **Debian
Stretch amd64**.

You have to put the package in a APT repository or you
can use directly this APT repository: https://apt.ac-versailles.fr/
(HTTP protocol is possible too). Below I assume you use
the APT repository https://apt.ac-versailles.fr/. Here are
the commands to install the Wims server on Debian Stretch
from this package:

```sh
# Commands launched as root.

# Required only if you use the APT repository via HTTPS.
apt-get update && apt-get install apt-transport-https

# Set the additional APT repository.
# If you prefer, you can replace "https://" by "http://".
echo deb https://apt.ac-versailles.fr/ stretch main > /etc/apt/sources.list.d/wims.list
wget https://apt.ac-versailles.fr/public-key.pgp -O - | apt-key add -

# Installation of Wims.
apt-get update && apt-get install wims
```

Now, Wims is installed and you should be able to visit the
page `http://IP-OF-YOUR-SERVER/wims/`.


If you want to automatically redirect the path `/` to
`/wims/` (it's probably a good idea), you can add the file
`/etc/apache2/sites-available/wims.conf` with this content:

```apache
<VirtualHost *:80>
    RedirectMatch permanent ^/$ /wims/
</VirtualHost>
```

**Warning:** because there is no `ServerName` instruction,
the file `wims.conf` should be the only enabled vhost in
your Apache2 configuration.

Then, for the configuration to take effect:

```sh
# Commands launched as root.

a2ensite wims.conf
service apache2 restart
```

But if you want to enable SSL, then you can edit the file
`/etc/apache2/sites-available/wims.conf` like this:

```apache
<VirtualHost *:80>
    # Redirection HTTP to HTTPS.
    #
    # With SSL, you have to know the FQDN of your wims
    # server and you have to replace `FQDN-OF-YOUR-SERVER`
    # by the correct value.
    Redirect permanent / https://FQDN-OF-YOUR-SERVER/wims/
</VirtualHost>


<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        RedirectMatch permanent ^/$ /wims/

        # You should problably change these values. By
        # default, `/etc/ssl/certs/ssl-cert-snakeoil.pem` is
        # a self signed certificate (signed via the private
        # key `/etc/ssl/private/ssl-cert-snakeoil.key`) with
        # the value of the command `hostname --fqdn` as
        # "Subject Alternative Name". Of course, you can
        # change the configuration below to use another (and
        # not self signed) certificate.
        SSLEngine             on
        SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
        SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

        <FilesMatch "\.(cgi|shtml|phtml|php)$">
            SSLOptions +StdEnvVars
        </FilesMatch>

        <Directory /usr/lib/cgi-bin>
            SSLOptions +StdEnvVars
        </Directory>
    </VirtualHost>
</IfModule>
```

Then, for the configuration to take effect:

```sh
# Commands launched as root.

a2enmod ssl
a2ensite wims.conf
service apache2 restart
```

