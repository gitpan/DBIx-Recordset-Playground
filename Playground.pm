package DBIx::Recordset::Cookbook;

use 5.008;
use strict;
use warnings;

use DBI;
use DBIx::Recordset;


require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use DBIx::Recordset::Cookbook ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(	
);

our $VERSION = '0.02';


# Preloaded methods go here.





1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

  DBIx::Recordset::Cookbook - working sample usages of DBIx::Recordset

=head1 INTRODUCTION

This document serves two purposes. One, it makes it easy to get started
with DBIx::Recordset. Two, it serves as a place for those experienced with
recordset to examine the code to discover how to make usage of recordset
even simpler.

By working the examples in the order given in this document, you will be
able to create a database and manipulate it, all from DBIx::Recordset.

Let the games begin!

=head1 CREATE THE DATABASE

=head2 Our Generic Connection Script:

 #
 #   scripts/dbconn.pl
 #
 
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


=head2 And Now the Script to Create the Tables:

 #
 #   scripts/create-tables.pl
 #
 
 require 'dbconn.pl';
 use DBI;
 
 my $person_tbl =<<EOSQL;
 CREATE TABLE IF NOT EXISTS person (
 id          mediumint unsigned not null primary key auto_increment,
 name        varchar(40) not null,
 age         varchar(255) not null, 
 country_id  mediumint unsigned
 )
 EOSQL
 
 my $country_tbl =<<EOSQL;
 CREATE TABLE IF NOT EXISTS country (
 id          mediumint unsigned not null primary key auto_increment,
 name        varchar(40) not null
 )
 EOSQL
 
 
 my $dbh = dbh();
 
 
 $dbh->do('use test');
 $dbh->do($person_tbl);
 $dbh->do($country_tbl);
 
 


=head2 POPULATE THE DATABASE

 #
 #   scripts/populate-person.pl
 #
 
 require 'dbconn.pl';
 use DBI;
 
 use Data::Dumper;
 
 
 my @data = (
 	    [qw(bill   25 ru)],
 	    [qw(bob    30 de)],
 	    [qw(bob    30 ca)],
 	    [qw(bob    30 nz)],
 	    [qw(jane   18 us)],
 	    [qw(jane   48 dk)],
 	    [qw(jane   22 nw)],
 	    [qw(lazlo  40 hu)],
 	    [qw(tony   40 uk)],
 	    [qw(tony   21 yg)],
 	    [qw(tony   22 ie)]
 	    );
 
 ### no insert whole array ref huh?
 
 for (@data) {
 
     my %h = (
 	     name      => $_->[0],
 	     age       => $_->[1],
 	     country   => $_->[2]
 	     );
 
     warn Dumper(\%h);
 
   DBIx::Recordset -> Insert ({%h,
 			      ('!DataSource'   =>  dbh(),
 			       '!Table'        =>  'person')});
 }
 
 


=head1 SYNOPSIS

=head2 Selecting data where values are in an arrayref:

 #
 #   scripts/select-using-aref.pl
 #
 
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
 
 
 
 
 
 
 
 
 
 


=head2 Using Manual Indexing

 #
 #   scripts/synopsis-manual-indexing.pl
 #
 
 require 'dbconn.pl';
 use DBIx::Recordset;
 use strict;
 use vars qw(*set);
 
 my %where = (name => 'jane');
 
 *set = 
   DBIx::Recordset -> Search ({
 	
       %where,
       conn_dbh(), person_table()
 
       });
 
 
 print "A1: ", $set[0]{age}, $/;
 print "A2: ", $set[1]{age}, $/;
 
 # now to use the hash of the current record:
 
 print "N: ", $set{name}, $/;
 print "A: ", $set{age}, $/;
 
 
 
 
 
 
 


=head2 Reusing a Set Object to do Another Search:

 #
 #   scripts/do-another-search.pl
 #
 
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
 
 
 
 
 
 
 
 
 
 
 


=head2 Using C<Next()> to Iterate over a Result Set:

 #
 #   scripts/all-users-with.pl
 #
 
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
 
 
 
 
 
 
 
 
 
 
 




=head1 AUTHOR

T. M. Brannon, tbone@cpan.org


=cut
