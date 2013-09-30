package Todo::Web;

use strict;
use warnings;
use utf8;
use Kossy;
use Plack::Session;
use Todo::Config;
use Todo::DB;
use Net::Twitter::Lite;

*Kossy::Connection::session = sub {
    shift->{session};
};

*Kossy::Connection::is_login = sub {
    shift->session->get('access_token') ? 1 : 0;
};


my $config_teng;
my $config_tw = Todo::Config->param('twitter');
my $nt = Net::Twitter::Lite->new(
    consumer_key    => $config_tw->{consumer_key},
    consumer_secret => $config_tw->{consumer_secret},
);

filter 'session' => sub {
    my $app = shift;
    sub {
        my ($self, $c) = @_;
        $c->{session} = Plack::Session->new($c->req->env);
        $app->($self,$c);
    }
};

filter 'set_title' => sub {
    my $app = shift;
    sub {
        my ($self, $c)  = @_;
        $c->stash->{site_name} = __PACKAGE__;
        $app->($self,$c);
    }
};

get '/' => [qw/set_title session/] => sub {
    my ($self, $c)  = @_;
    $c->render('index.tx', { greeting => "Hello" });
};

get '/all' => [qw/set_title session/] => sub {
    my ($self, $c)  = @_;
    $c->stash->{all} = [ $self->db_r->search('sample' => +{}) ];
    use Data::Dumper;
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Terse  = 1;
    warn Dumper $c->stash->{all};
    $c->render('index.tx', { greeting => "Hello" });
};

post '/create' => [qw/set_title/] => sub {
    my ($self, $c)  = @_;

    my $result = $c->req->validator([
        'id1' => [['NOT_NULL'],'not null'],
        'id2' => [['NOT_NULL'],'not null'],
        'id3' => [['NOT_NULL'],'not null'],
    ]);
    return $c->halt('403') if $result->has_error;
    my $new_name = $result->valid;
    #$self->db_w->insert('todo' =>  +{id1 => 1, id2 => 2, id3 => 3});
    $c->render('index.tx', { greeting => "Hello" });
};

get '/json' => sub {
    my ($self, $c)  = @_;
    my $result = $c->req->validator([
        'q' => {
            default => 'Hello',
            rule => [
                [['CHOICE',qw/Hello Bye/],'Hello or Bye']
            ],
        }
    ]);
    $c->render_json(+{ greeting => $result->valid->get('q') });
};

get '/login' => [qw/session/] => sub {
    my ($self, $c)  = @_;
    my $session = $c->session;
    my $url     = $nt->get_authorization_url(
        callback => $c->req->base . 'callback'
   );
    $session->set('token', $nt->request_token);
    $session->set('token_secret', $nt->request_token_secret);
    $c->redirect($url);
};

get '/callback' => [qw/session/] => sub {
    my ($self, $c)  = @_;
    unless ($c->req->param('denied')) {
        my $session = $c->session;
        $nt->request_token($session->get('token'));
        $nt->request_token_secret($session->get('token_secret'));
        my $verifier = $c->req->param('oauth_verifier');
        my ($access_token, $access_token_secret, $user_id, $screen_name) =
          $nt->request_access_token(verifier => $verifier);
        $session->set('access_token',        $access_token);
        $session->set('access_token_secret', $access_token_secret);
        $session->set('screen_name',         $screen_name);
    }
    $c->redirect('/');
};

get '/logout' => [qw/session/] => sub {
    my ($self, $c)  = @_;
    $c->session->expire;
    $c->redirect('/');
};

sub db_r {
    my $self = shift;
    return $self->{db_r} if $self->{db_r};
    $config_teng ||= Todo::Config->param('teng');
    $self->{db_r}  = Todo::DB->new($config_teng->{read})
};

sub db_w {
    my $self = shift;
    return $self->{db_w} if $self->{db_w};
    $config_teng ||=  Todo::Config->param('teng');
    $self->{db_w}   = Todo::DB->new($config_teng->{write})
};

1;
