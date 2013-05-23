requires 'Encode';
requires 'Mojo::Base';
requires 'Mojo::Server::PSGI';
requires 'Plack::Builder';
requires 'Plack::Session';
requires 'Text::Markdown';
requires 'WebService::Dropbox';

on test => sub {
    requires 'Test::Mojo';
    requires 'Test::More';
};
