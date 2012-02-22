package Dropdown::Dropbox;
use Mojo::Base 'Mojolicious::Controller';
use Text::Markdown qw/markdown/;
use Encode;

sub dropbox {
    my $self = shift;
    my $name = $self->stash->{name};
    my $dropbox = $self->app->dropbox;
    if ( (my $access_token = $self->cookie('access_token') )
             && ( my $access_secret = $self->cookie('access_secret') ) ) {
        $dropbox->access_token($access_token);
        $dropbox->access_secret($access_secret);
        my $list = $dropbox->metadata($name) or die $dropbox->error;
        $self->stash->{list} = $list;
        if (!$list->{is_dir}) {
            my $content;
            $dropbox->files(
                $name,
                sub {
                    $content .= $_[0];
                }
            );
            if ( $name =~ m!\.(?:md|mkdn|markdown|mkd|mark|mdown)$! ) {
                $content = decode_utf8($content);
                $self->stash->{markdown_html} = markdown($content);
                return $self->render(template => 'dropbox/markdown', format => 'html');
            }else{
                $self->res->headers->content_type($list->{mime_type});
                return $self->render(data => $content);
            }
        }
        return $self->render('dropbox/list');
    }
    return $self->render_not_found;
}

1;
