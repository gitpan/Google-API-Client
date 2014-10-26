#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use Google::API::Client;
use Google::API::OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;

use constant MAX_PAGE_SIZE => 50;


my $client = Google::API::Client->new;
my $service = $client->build('adsense', 'v1.3');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

# Call adclients.list
my $res = $service->adclients->list(
    body => {
        maxResults => MAX_PAGE_SIZE
    })->execute({ auth_driver => $auth_driver });
for my $ad_client (@{$res->{items}}) {
    # Call adunits.list
    my $ad_units = $service->adunits->list(
        body => {
            adClientId => $ad_client->{id},
            maxResults => MAX_PAGE_SIZE
        })->execute({ auth_driver => $auth_driver });
    for my $ad_unit (@{$ad_units->{items}}) {
        say "Ad unit with code $ad_unit->{code}, name $ad_unit->{name} and status $ad_unit->{status} was found";
    }
}

store_token($dat_file, $auth_driver);

say 'Done';
__END__
