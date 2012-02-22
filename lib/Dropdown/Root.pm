package Dropdown::Root;
use Mojo::Base 'Mojolicious::Controller';
use Plack::Session;

sub index {
    my $self          = shift;
    my $dropbox       = $self->app->dropbox;
    my $info          = {};
    my $session       = Plack::Session->new( $self->req->env );
    my $access_token  = $session->get('access_token');
    my $access_secret = $session->get('access_secret');
    if ( $access_token && $access_secret ) {
        $dropbox->access_token($access_token);
        $dropbox->access_secret($access_secret);
        $info = $dropbox->account_info or die $dropbox->error;
    }
    $self->stash->{info} = $info;
}

sub login {
    my $self    = shift;
    my $dropbox = $self->app->dropbox;
    my $url     = $dropbox->login( $self->req->url->base . '/callback' )
      or die $dropbox->error;
    my $session = Plack::Session->new( $self->req->env );
    $session->set( 'request_token',  $dropbox->request_token );
    $session->set( 'request_secret', $dropbox->request_secret );
    $self->redirect_to($url);
}

sub callback {
    my $self    = shift;
    my $dropbox = $self->app->dropbox;
    my $session = Plack::Session->new( $self->req->env );
    $dropbox->request_token( $session->get('request_token') );
    $dropbox->request_secret( $session->get('request_secret') );
    $dropbox->auth or die $dropbox->error;
    $session->set( 'access_token',  $dropbox->access_token );
    $session->set( 'access_secret', $dropbox->access_secret );
    $self->res->code('302');
    $self->res->headers->header( 'Location' => '/' );
}

sub logout {
    my $self    = shift;
    my $session = Plack::Session->new( $self->req->env );
    $session->set( 'access_token',  undef );
    $session->set( 'access_secret', undef );
    $self->res->code('302');
    $self->res->headers->header( 'Location' => '/' );
}

1;
