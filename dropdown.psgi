use strict;
use Mojo::Server::PSGI;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;
use Dropdown;

$ENV{MOJO_MODE} = 'production';

my $psgi = Mojo::Server::PSGI->new( app => Dropdown->new );
my $app = $psgi->to_psgi_app;

builder {
    enable_if { $_[0]->{PATH_INFO} !~ qr{^/(?:favicon\.ico|css|images|js)} }
        "Plack::Middleware::AccessLog", format => "combined";
    enable 'Session', store => 'File';
    enable "Plack::Middleware::ReverseProxy";
    $app;
};
