require 'dbconn.pl';
use DBIx::Recordset;

use vars qw(*set);

*set = 
  DBIx::Recordset -> Search ({
	
      '$where'   => 'name = ? and age = ?',
      '$values'  => ['bob',  30],
      conn_dbh(), person_table()

      });


print $set[0]{name}, $/;
print $set[1]{name}, $/;

$set->Search({
    name => 'lazlo'
    });

print $set[0]{age}, $/;











