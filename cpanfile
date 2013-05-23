requires 'Encode';
requires 'Mojolicious', '3.97';
requires 'Plack::Builder';
requires 'Plack::Session';
requires 'Text::Markdown';
requires 'WebService::Dropbox';
requires 'Plack::Middleware::ReverseProxy';

on test => sub {
    requires 'Test::Mojo';
    requires 'Test::More';
};
