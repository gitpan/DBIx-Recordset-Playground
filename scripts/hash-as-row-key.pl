require 'dbconn.pl';
use DBIx::Recordset;
use strict;
use vars qw(*set);

my %DEBUG = ('!Debug' => 0);

*set = DBIx::Recordset -> Setup
  ({
    conn_dbh(),
    %DEBUG,
    '!Table'	    => 'authors',
    '!HashAsRowKey' => 1,
    '!PrimKey'      => 'au_id'
   });


my @au_id = qw( 409-56-7008  213-46-8915 998-72-3567 );


warn Dumper($set{$_}) for @au_id;
