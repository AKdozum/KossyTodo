package MyApp::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use Plack::Session;
use MyApp::Config;
use MyApp::DB;

my $config_teng;

*Kossy::Connection::session = sub {
    shift->{session};
};

filter 'session' => sub {
    my $app = shift;
    sub {
        my ( $self, $c ) = @_;
        $c->{session} = Plack::Session->new($c->req->env);
        $app->($self,$c);
    }
};

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ( $self, $c )  = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};

get '/' => [qw/set_title session/] => sub {
    my ( $self, $c )  = @_;
    $c->render('index.tx', { greeting => "Hello" });
};

get '/all' => [qw/set_title session/] => sub {
    my ( $self, $c )  = @_;
    $c->stash->{all} = [ $self->db_r->search('sample' => +{}) ];
    use Data::Dumper;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Terse  = 1;
    warn Dumper $c->stash->{all};
    $c->render('index.tx', { greeting => "Hello" });
};

post '/insert' => [qw/set_title/] => sub {
    my ( $self, $c )  = @_;

    my $result = $c->req->validator([
        'id1' => [['NOT_NULL'],'not null'],
        'id2' => [['NOT_NULL'],'not null'],
        'id3' => [['NOT_NULL'],'not null'],
    ]);
    use Data::Dumper;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Terse  = 1;
    warn Dumper $result->valid;
    #my $new_name = $result->valid->get('text');
    #$self->db_w->insert('sample' =>  +{id1 => 1, id2 => 2, id3 => 3});
    $c->render('index.tx', { greeting => "Hello" });
};

get '/json' => sub {
    my ( $self, $c )  = @_;
    my $result = $c->req->validator([
        'q' => {
            default => 'Hello',
            rule => [
                [['CHOICE',qw/Hello Bye/],'Hello or Bye']
            ],
        }
    ]);
    $c->render_json({ greeting => $result->valid->get('q') });
};

sub db_r {
    my $self = shift;
    return $self->{db_r} if $self->{db_r};
    $config_teng ||=  MyApp::Config->param('teng');
    $self->{db_r} = MyApp::DB->new($config_teng->{read})
};

sub db_w {
    my $self = shift;
    return $self->{db_w} if $self->{db_w};
    $config_teng ||=  MyApp::Config->param('teng');
    $self->{db_w} = MyApp::DB->new($config_teng->{write})
};

1;
