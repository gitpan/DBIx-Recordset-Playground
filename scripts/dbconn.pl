use Data::Dumper;
use DBIx::Recordset;

sub dbh {
    *DBIx::Recordset::LOG   = \*STDOUT;
    $DBIx::Recordset::Debug = 2;

#my  $dsn = 'DBI:mysqlPP:database_name=test;host=localhost';
#    my  $dsn = 'DBI:mysqlPP:database=test;host=localhost';
    my  $dsn = 'DBI:mysql:database=test;host=localhost';
    our $dbh;

  my $attr = { RaiseError => 1 };
  my ($user, $pass);

  $dbh = DBI->connect($dsn, $user, $pass, $attr) or die $DBI::errstr;

}

sub conn_dbh { 
    ( '!DataSource' => dbh() );
}

sub person_table {
    ( '!Table'      => 'person' );
}



1;
