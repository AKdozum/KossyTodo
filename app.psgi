use FindBin;
use lib "$FindBin::Bin/extlib/lib/perl5";
use lib "$FindBin::Bin/lib";
use File::Basename;
use Plack::Builder;
use MyApp::Web;
use Plack::Session::State::Cookie;
use Plack::Session::Store::Redis;
my $root_dir = File::Basename::dirname(__FILE__);

my $app = MyApp::Web->psgi($root_dir);
builder {
    enable 'ReverseProxy';
    enable 'Static',
        path => qr!^/(?:(?:css|js|img)/|favicon\.ico$)!,
        root => $root_dir . '/public';
    enable 'Session',
        state => Plack::Session::State::Cookie->new(httponly => 1),
        store => Plack::Session::Store::Redis->new(
            host => 'localhost',
            port => 6379,
        );
    $app;
};

