#!/usr/bin/env perl

use Authen::Passphrase::BlowfishCrypt;

my $ppr = Authen::Passphrase::BlowfishCrypt->new(
	cost => 8,
	salt_random => 1,
	passphrase => $ARGV[0]);

print $ppr->as_rfc2307 . "\n";
