use Data::Dumper;
use DBIx::Recordset;

# change to match your local connection parameters

my  $dsn = 'DBI:mysql:database=princepawn;host=localhost';
my  $user='princepawn';
my  $pass='money1';
my  $attr= { RaiseError => 1 };


sub dbh {
    *DBIx::Recordset::LOG   = \*STDOUT;
    $DBIx::Recordset::Debug = 2;

    my $dbh = DBI->connect($dsn, $user, $pass, $attr) or die $DBI::errstr;

}

sub conn_dbh {
    ( '!DataSource' => dbh() );
}

sub author_table {
    ( '!Table'      => 'authors' );
}

sub royalty_table {
    ( '!Table'      => 'roysched' );
}

sub tblnm {

    (
     '!Table' =>
     shift()
    )

}


sub print_recordset {

    my $glob = shift;
    my $set = $glob;

    while ( my $rec = $set->Next )
      {
	  print Dumper(\%set);
      }

}


1;
