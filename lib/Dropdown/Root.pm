package Dropdown::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;
    my $dropbox = $self->app->dropbox;
    my $info = {};
    if ( (my $access_token = $self->session('access_token') )
             && ( my $access_secret = $self->session('access_secret') ) ) {
        $dropbox->access_token($access_token);
        $dropbox->access_secret($access_secret);
        $info = $dropbox->account_info or die $dropbox->error;
    }
    $self->stash->{info} = $info;
};

sub login {
    my $self = shift;
    my $dropbox = $self->app->dropbox;
    my $url = $dropbox->login( $self->req->url->base . '/callback' )
      or die $dropbox->error;
    $self->redirect_to( $url);
}

sub callback {
    my $self = shift;
    my $dropbox = $self->app->dropbox;
    $dropbox->auth or die $dropbox->error;
    $self->session( access_token => $dropbox->access_token );
    $self->session( access_secret => $dropbox->access_secret );
    $self->redirect_to('/dropbox/');
}

sub logout {
    my $self = shift;
    $self->session( access_token => undef );
    $self->session( access_secret => undef );
    $self->redirect_to('/');
}

1;
