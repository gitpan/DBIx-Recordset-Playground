require 'dbconn.pl';
use DBIx::Recordset;
use strict;

use vars qw(*set);

*set =
  DBIx::Recordset -> Search
  ({
    '!DataSource' => dbh(),
    '$max' => 4,
    '!Query' => 'SELECT * FROM AUTHORS'
   });

while ($set->Next) {
    print Dumper(\%set)
}

