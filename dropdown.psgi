use strict;
use Mojo::Server::PSGI;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;

my $psgi = Mojo::Server::PSGI->new( app_class => 'Dropdown' );
my $app = sub { $psgi->run(@_) };

builder {
    enable_if { $_[0]->{PATH_INFO} !~ qr{^/(?:favicon\.ico|css|images|js)} }
        "Plack::Middleware::AccessLog", format => "combined";
    enable 'Session', store => 'File';
    enable "Plack::Middleware::ReverseProxy";
    $app;
};
