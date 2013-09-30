package Todo::Config;
use strict;
use warnings;
use Config::ENV qw(PLACK_ENV), default => 'development';
use File::Spec;
use YAML::XS qw();

sub base_dir($) {
    my $path = shift;
    $path =~ s!::!/!g;
    if (my $libpath = $INC{"$path.pm"}) {
        $libpath =~ s!\\!/!g; # win32
        $libpath =~ s!(?:blib/)?lib/+$path\.pm$!!;
        File::Spec->rel2abs($libpath || './');
    } else {
        File::Spec->rel2abs('./');
    }
}

my $base;
sub load_yaml {
    $base ||= base_dir(__PACKAGE__);
    my $path = File::Spec->catfile($base, 'config', @_);
    return () unless -f $path;
    return YAML::XS::LoadFile($path);
}

common +{ load_yaml('common.pl') };

for my $env (qw/development test production/) {
    config $env => load_yaml("$env.yaml");
}

1;
