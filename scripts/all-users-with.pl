require 'dbconn.pl';
use DBIx::Recordset;
use strict;
use vars qw(*set);

my %where = (name => 'tony');

*set =
  DBIx::Recordset -> Search ({

      %where,
      conn_dbh(), person_table()

      });


while (my $rec = $set->Next) {
    print $rec->{age}, $/;
}
