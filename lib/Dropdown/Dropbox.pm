package Dropdown::Dropbox;
use Mojo::Base 'Mojolicious::Controller';
use Text::Markdown qw/markdown/;
use Encode;
use Plack::Session;

sub dropbox {
    my $self          = shift;
    my $name          = $self->stash->{name};
    my $dropbox       = $self->app->dropbox;
    my $session       = Plack::Session->new( $self->req->env );
    my $access_token  = $session->get('access_token');
    my $access_secret = $session->get('access_secret');
    return $self->render_not_found if ( !$access_token && !$access_secret );
    $dropbox->access_token($access_token);
    $dropbox->access_secret($access_secret);
    my $list = $dropbox->metadata($name) or die $dropbox->error;
    $self->stash->{list} = $list;

    if ( !$list->{is_dir} ) {
        my $content;
        $dropbox->files(
            $name,
            sub {

                # using Furl.
                $content .= $_[3];
            }
        );
        if ( $name =~ m!\.(?:md|mkdn|markdown|mkd|mark|mdown)$! ) {
            $content = decode_utf8($content);
            $self->stash->{markdown_html} = markdown($content);
            return $self->render(
                template => 'dropbox/markdown',
                format   => 'html'
            );
        }
        else {
            $self->res->headers->content_type( $list->{mime_type} );
            return $self->render( data => $content );
        }
    }
    return $self->render('dropbox/list');
}

1;
