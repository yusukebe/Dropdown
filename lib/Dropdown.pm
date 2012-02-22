package Dropdown;
use Mojo::Base 'Mojolicious';
use WebService::Dropbox;

sub startup {
    my $self = shift;
    my $config = $self->plugin('Config');
    $self->attr(
        dropbox => sub {
            WebService::Dropbox->new(
                {
                    key    => $config->{key},
                    secret => $config->{secret}
                }
            );
        }
    );
    my $r = $self->routes;
    $r->route('/')->to('root#index');
    $r->route('/login')->to('root#login');
    $r->route('/callback')->to('root#callback');
    $r->route('/dropbox/(*name)')->to('dropbox#dropbox');
}

1;
