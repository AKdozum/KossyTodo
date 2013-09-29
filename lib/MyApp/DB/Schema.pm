package Schema;
use strict;
use warnings;
use utf8;
use Teng::Schema::Declare;

table {
    name 'sample';
    pk   'id';
    columns qw/id id1 id2 id3/;
};

1;

