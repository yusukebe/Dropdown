package Dropdown::Root;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;
    my $dropbox = $self->app->dropbox;
    my $info = {};
    my $access_token = $self->signed_cookie( 'access_token' );
    my $access_secret = $self->signed_cookie( 'access_secret' );
    if ( $access_token && $access_secret ) {
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
    $self->redirect_to( $url );
}

sub callback {
    my $self = shift;
    my $dropbox = $self->app->dropbox;
    $dropbox->auth or die $dropbox->error;
    $self->signed_cookie( access_token => $dropbox->access_token );
    $self->signed_cookie( access_secret => $dropbox->access_secret );
    $self->res->code('302');
    $self->res->headers->header( 'Location' => '/dropbox/');
}

sub logout {
    my $self = shift;
    $self->signed_cookie( access_token => '' );
    $self->signed_cookie( access_secret => '' );
    $self->res->code('302');
    $self->res->headers->header('Location'=> '/');
}

1;
