require 'dbconn.pl';
use DBIx::Recordset;

use vars qw(*rs);

*rs = 
  DBIx::Recordset -> Search ({
	
      '$where'   => 'name = ? and age = ?',
      '$values'  => ['bob',  30],
      conn_dbh(), person_table()

      });

#print Dumper(\@rs); # results not fetched --- you get nothing!
print Dumper($rs[0]{name});










