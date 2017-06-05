# Login Proxy

A simple to setup Auth Proxy to restrict site access to certain users. Mainly used for beta websites.

## Building

First dependencies under Fedora 25.

`# dnf install @development-tools perl-CPAN perl-App-cpanminus perl-Test-Simple perl-Test perl-Test-Pod perl-Digest-MD5 perl-Crypt-Blowfish perl-Crypt-Eksblowfish perl-Digest-SHA1 perl-Digest-MD4 perl-Test-Warn perl-JSON`

And then the pure Perl dependencies.

`# cpanm Test::More Mojolicious Mojolicious::Plugin::Authentication Crypt::CBC Authen::Passphrase::BlowfishCrypt Text::CSV Mojolicious::Plugin::Proxy File::Slurp`

## Running

In development `morbo login.pl`

In production the systemd file can be used.

## Config

Make a file in the project root called shadow. It should have a format similar to this:

```
foo:{CRYPT}$2a$08$eZtgqcRM6d6IgyNcJPSSTuKZIDaCsQHkEQR3nO9t8Svy4RkFSakLG:1
bar:{CRYPT}$2a$08$GDH3MOnTNpwQx.22GO2Jee2h1OsYG6Lb7zhxopduQJo3VE0dO9.y2:2
```

The program hash.pl can be used to hash passwords.

## TODO

* Make hash.pl interactive
* Rename routes in login.pl so they conflict less
