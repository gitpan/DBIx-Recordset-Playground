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

our $VERSION = '0.06';


# Preloaded methods go here.





1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

  DBIx::Recordset::Cookbook - working sample usages of DBIx::Recordset

=head1 INTRODUCTION

This document serves several purposes. One, it makes it easy to get started
with DBIx::Recordset. Two, it serves as a place for those experienced with
recordset to examine the code to discover how to make usage of recordset
even simpler. Finally, it serves as a place for me to clarify all the
areas in the original docs that were a bit confusing to me.

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

=head2 Selecting data with where criteria in a hash (formdata? :))

 #
 #   scripts/select-using-hash.pl
 #
 
 require 'dbconn.pl';
 use DBIx::Recordset;
 
 use vars qw(*rs);
 
 *rs =
   DBIx::Recordset -> Search ({
 
       name => 'bob',
       age  => 30,
       conn_dbh(), person_table()
 
       });
 
 #print Dumper(\@rs); # results not fetched --- you get nothing!
 print Dumper($rs[0]{name});


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


=head3 Using C<Next()> but Using the Implicitly Bound Hash:

 #
 #   scripts/using-hash-of-recordset.pl
 #
 
 require 'dbconn.pl';
 use Data::Dumper;
 use DBIx::Recordset;
 
 use vars qw(*set);
 
 *set =
   DBIx::Recordset -> Search ({
 
       name => 'jane',
       conn_dbh(), person_table()
 
       });
 
 
 while ($set->Next) {
     print Dumper(\%set);
 }


=head1

DBIx::Recordset is a perl module for abstraction and simplification of
database access.

The goal is to make standard database access (select/insert/update/delete)
easier to handle and independent of the underlying DBMS. While special 
attention is
paid to web applications, making it possible to handle state-less access
and process the posted data of formfields, DBIx::Recordset is not
limited to such applications.

B<DBIx::Recordset> uses the DBI API to access the database, so it
should work with 
every database for which a DBD driver is available (see also DBIx::Compat).

Most public functions take a hash reference as parameter, which makes it simple
to supply various different arguments to the same function. The
parameter hash 
can also be taken from a hash containing posted formfields like those
available with 
CGI.pm, mod_perl, HTML::Embperl and others.

Before using a recordset it is necessary to setup an object. Of course the
setup step can be made with the same function call as the first
database access, 
but it can also be handled separately.

Most functions which set up an object return a B<typeglob>. A typeglob
in Perl is an  
object which holds pointers to all datatypes with the same
name. Therefore a typeglob 
must always have a name and B<can't> be declared with B<my>. You can only
use it as B<global> (package) variable or declare it with
B<local>. The trick for using 
a typglob is that setup functions can return a B<reference to an object>, an
B<array> and a B<hash> at the same time.

B<... concerns about package variables and mod_perl ...>

The object is used to access the object's methods, the array is used to access
the records currently selected in the recordset and the hash is used to access
the current record.

If you don't like the idea of using typglobs you can also set up the object,
array and hash separately, or just set the ones you need.


=head1 ARGUMENTS

Since most methods take a hash reference as argument, here is a
description of the valid arguments first.

=head2 Setup Parameters

All parameters starting with an '!' are B<only> recognized at setup time.
B<If you specify them in later function calls they will be ignored.>
Note: You can also preset these parameters with the TableAttr method of 
DBIx::Database.  This allows you to setup most parameters
for the whole database once and they will be use every time you create a new
DBIx::Recordset object, without specifying it every time.

=item B<!DataSource>

Specifies the database to which to connect. This information can be given in
the following ways:

=over 4

=item a DBI database handle

Uses a given database handle.

=item Driver/DB/Host.

Same as the first parameter to the DBI connect function.

=item DBIx::Recordset object

Takes the same database handle as the given DBIx::Recordset object.

=item DBIx::Database object

Takes Driver/DB/Host from the given database object. See L<DBIx::Database> 
for details about DBIx::Database object. When using more than one Recordset
object, this is the most efficient method.

=item DBIx::Database object name

Takes Driver/DB/Host from the database object which is saved under
the given name ($saveas parameter to DBIx::Database -> new)


=back

=item B<!Table>

Tablename. Multiple tables are comma-separated.


=item B<!Username>

Username. Same as the second parameter to the DBI connect function.

=item B<!Password>

Password. Same as the third parameter to the DBI connect function.

=item B<!DBIAttr>

Reference to a hash which holds the attributes for the DBI connect
function. See perldoc DBI for a detailed description.


=item B<!Fields>

Fields which should be returned by a query. If you have specified multiple
tables the fieldnames should be unique. If the names are not unique you must
specify them along with the tablename (e.g. tab1.field).


NOTE 1: Fieldnames specified with !Fields can't be overridden. If you plan
to use other fields with this object later, use $Fields instead.

NOTE 2: The keys for the returned hash normally don't have a table part.
Only the fieldname part forms the key. (See !LongNames for an exception.)

NOTE 3: Because the query result is returned in a hash, there can only be
one out of multiple fields with the same name fetched at once.
If you specify multiple fields with the same name, only one is returned
from a query. Which one this actually is depends on the DBD driver.
(See !LongNames for an exception.)

NOTE 4: Some databases (e.g. mSQL) require you to always qualify a fieldname
with a tablename if more than one table is accessed in one query.

=item B<!TableFilter>

The TableFilter parameter specifies which tables should be honoured
when DBIx::Recordset searches for links between tables (see
below). When given as parameter to DBIx::Database it filters for which
tables DBIx::Database retrieves metadata. Only thoses tables are used
which starts with prefix given by C<!TableFilter>. Also the DBIx::Recordset
link detection tries to use this value as a prefix of table names, so
you can leave out this prefix when you write a fieldname that should
be detected as a link to another table.

=item B<!LongNames>

When set to 1, the keys of the hash returned for each record not only
consist of the fieldnames, but are built in the form table.field.

=item B<!Order>

Fields which should be used for ordering any query. If you have specified multiple
tables the fieldnames should be unique. If the names are not unique you must
specify them among with the tablename (e.g. tab1.field).


NOTE 1: Fieldnames specified with !Order can't be overridden. If you plan
to use other fields with this object later, use $order instead.

B<... of course the question being how to do ascending and descending>

=item B<!TabRelation>

Condition which describes the relation between the given tables
(e.g. tab1.id = tab2.id) (See also L<!TabJoin>.)

  Example

  '!Table'       => 'tab1, tab2',
  '!TabRelation' => 'tab1.id=tab2.id',
  'name'         => 'foo'

  This will generate the following SQL statement:

  SELECT * FROM tab1, tab2 WHERE name = 'foo' and tab1.id=tab2.id ;

=item B<!TabJoin>

!TabJoin allows you to specify an B<INNER/RIGHT/LEFT JOIN> which is
used in a B<SELECT> statement. (See also L<!TabRelation>.)

  Example

  '!Table'   => 'tab1, tab2',
  '!TabJoin' => 'tab1 LEFT JOIN tab2 ON	(tab1.id=tab2.id)',
  'name'     => 'foo'

  This will generate the following SQL statement:

  SELECT * FROM tab1 LEFT JOIN tab2 ON	(tab1.id=tab2.id) WHERE name = 
'foo' ;

=item B<!PrimKey>

Name of the primary key. When this key appears in a WHERE parameter list
(see below), DBIx::Recordset will ignore all other keys in the list,
speeding up WHERE expression preparation and execution.

B<... oh I think I see. He means that the primary key alone should be
enough to find your records, so why bother with anything else. So, if
you set this up beforehand, then when formdata came piling in, you
could search on primary key only if it happened to be in the formdata.>

Note that this
key does NOT have to correspond to a field tagged as PRIMARY KEY in a
CREATE TABLE statement.

=item B<!Serial>

Name of the primary key. In contrast to C<!PrimKey> this field is treated
as an autoincrement field. If the database does not support
autoincrement fields, 
but sequences the field is set to the next value of a sequence (see
C<!Sequence> and C<!SeqClass>) 
upon each insert. If a C<!SeqClass> is given the values are always
retrived from the sequence class 
regardless if the DBMS supports autoincrement or not.
The value from this field from the last insert could be retrieved
by the function C<LastSerial>.

B<... aha! an how-to! ...>

=item C<!Sequence>

Name of the sequence to use for this table when inserting a new record and
C<!Serial> is defind. Defaults to <tablename>_seq.

B<... a feature related to DBMS which use sequences>

=item C<!SeqClass>

Name and Parameter for a class that can generate unique sequence
values. This is 
a string that holds comma separated values. The first value is the
class name and 
the following parameters are given to the new constructor. See also
I<DBIx::Recordset::FileSeq> 
and I<DBIx::Recordset::DBSeq>.  

Example:  

   '!SeqClass' => 'DBIx::Recordset::FileSeq, /tmp/seq'

B<... another sequence-related feature>

=item B<!WriteMode>

!WriteMode specifies which write operations to the database are
allowed and which are 
disabled. You may want to set C<!WriteMode> to zero if you only need
to query data, to 
avoid accidentally changing the content of the database.

B<NOTE:> The !WriteMode only works for the DBIx::Recordset methods. If you
disable !WriteMode, it is still possible to use B<do> to send normal
SQL statements to the database engine to write/delete any data.

!WriteMode consists of some flags, which may be added together:

=over 4

=item DBIx::Recordset::wmNONE (0)

Allow B<no> write access to the table(s)

=item DBIx::Recordset::wmINSERT (1)

Allow INSERT

=item DBIx::Recordset::wmUPDATE (2)

Allow UPDATE

=item DBIx::Recordset::wmDELETE (4)

Allow DELETE

=item DBIx::Recordset::wmCLEAR (8)

To allow DELETE for the whole table, wmDELETE must be also specified. This is 
necessary for assigning a hash to a hash which is tied to a table. (Perl will 
first erase the whole table, then insert the new data.)

=item DBIx::Recordset::wmALL (15)

Allow every access to the table(s)


=back

Default is wmINSERT + wmUPDATE + wmDELETE

=item B<!StoreAll>

If present, this will cause DBIx::Recordset to store all rows which will be fetched between
consecutive accesses, so it's possible to access data in a random order. (e.g.
row 5, 2, 7, 1 etc.) If not specified, rows will only be fetched into memory
if requested, which means that you will have to access rows in ascending order.
(e.g. 1,2,3 if you try 3,2,4 you will get an undef for row 2 while 3 and 4 is ok)
see also B<DATA ACCESS> below.

=item B<!HashAsRowKey>

By default, the hash returned by the setup function is tied to the
current record. 

B<... this is already confusing. by "Setup Function" I presume he
means the function SetupObject and only this function? Or does he mean
any function which calls SetupObject. Such as Search(), Insert(),
Update(), Delete(). 

Also, the hash is not "returned" because the last sentence below says
that
this whole discussion relates to functions which return a
typeglob... therefore I think he means functions which bind a hash
with data of the current record.>

You can use it to access the fields of the current
record. If you set this parameter to true, the hash will by tied to
the whole 
database. This means that the key of the hash will be used as the
primary key in 
the table to select one row. 

B<... cool can we get an example of this?>

(This parameter only has an effect on
functions 
which return a typglob.)

B<... "typglob" should be spelled "typeglob">

=item B<!IgnoreEmpty>

This parameter defines how B<empty> and B<undefined> values are handled. 
The values 1 and 2 may be helpful when using DBIx::Recordset inside a CGI
script, because browsers send empty formfields as empty strings.

=over 4

=item B<0 (default)>

An undefined value is treated as SQL B<NULL>: an empty string remains an empty 
string.

=item B<1>

All fields with an undefined value are ignored when building the WHERE expression.

=item B<2>

All fields with an undefined value or an empty string are ignored when building the 
WHERE expression.

=back

B<NOTE:> The default for versions before 0.18 was 2.

=item B<!Filter>

Filters can be used to pre/post-process the data which is read from/written to the database.
The !Filter parameter takes a hash reference which contains the filter functions. If the key
is numeric, it is treated as a type value and the filter is applied to all fields of that 
type. If the key if alphanumeric, the filter is applied to the named field.  Every filter 
description consists of an array with at least two elements.  The first element must contain the input
function, and the second element must contain the output function. Either may be undef, if only
one of them are necessary. The data is passed to the input function before it is written to the
database. The input function must return the value in the correct format for the database. The output
function is applied to data read from the database before it is returned
to the user.
 
 
 Example:

     '!Filter'   => 
	{
	DBI::SQL_DATE     => 
	    [ 
		sub { shift =~ /(\d\d)\.(\d\d)\.(\d\d)/ ; "19$3$2$1"},
		sub { shift =~ /\d\d(\d\d)(\d\d)(\d\d)/ ; "$3.$2.$1"}
	    ],

	'datefield' =>
	    [ 
		sub { shift =~ /(\d\d)\.(\d\d)\.(\d\d)/ ; "19$3$2$1"},
		sub { shift =~ /\d\d(\d\d)(\d\d)(\d\d)/ ; "$3.$2.$1"}
	    ],

	}

Both filters convert a date in the format dd.mm.yy to the database format 19yymmdd and
vice versa. The first one does this for all fields of the type
SQL_DATE, the second one 
does this for the fields with the name datefield.

The B<!Filter> parameter can also be passed to the function
B<TableAttr> of the B<DBIx::Database> 
object. In this case it applies to all DBIx::Recordset objects which
use 
these tables.

B<... aha! so this is the second place so far that we have a means of
globally affecting all recordset object using tables. This means less
needs be done in pure OOP and more can be done by Recordset, for
better or worse>

A third parameter can be optionally specified. It could be set to
C<DBIx::Recordset::rqINSERT>, 
C<DBIx::Recordset::rqUPDATE>, or the sum of both. If set, the
InputFunction (which is called during 
UPDATE or INSERT) is always called for this field in updates and/or
inserts depending on the value. 

B<... what InputFunction is he talking about?>

If there is no data specified for this field
as an argument to a function which causes an UPDATE/INSERT, the
InputFunction 
is called with an argument of B<undef>.

During UPDATE and INSERT the input function gets either the string 'insert' or 'update' passed as
second parameter.

=item B<!LinkName>

This allows you to get a clear text description of a linked table,
instead of (or in addition to) the !LinkField. For example, if you
have a record with all your bills, and each record contains a customer
number, setting !LinkName DBIx::Recordset can automatically retrieve
the name of the customer instead of (or in addition to) the bill
record itself.

=over 4

=item 1 select additional fields

This will additionally select all fields given in B<!NameField> of the Link or the table
attributes (see TableAttr).

=item 2 build name in uppercase of !MainField

This takes the values of B<!NameField> of the Link or the table attributes (see 
TableAttr)
and joins the content of these fields together into a new field, which has the same name
as the !MainField, but in uppercase.


=item 2 replace !MainField with the contents of !NameField

Same as 2, but the !MainField is replaced with "name" of the linked record.

=back

See also B<!Links> and B<WORKING WITH MULTIPLE TABLES> below

=item B<!Links>

This parameter can be used to link multiple tables together. It takes a
reference to a hash, which has - as keys, names for a special B<"linkfield">
and - as value, a parameter hash. The parameter hash can contain all the
B<Setup parameters>. The setup parameters are taken to construct a new
recordset object to access the linked table. If !DataSource is omitted (as it
normally should be), the same DataSource (and database handle), as the
main object is taken. There are special parameters which can only 
occur in a link definition (see next paragraph). For a detailed description of
how links are handled, see B<WORKING WITH MULTIPLE TABLES> below.

=head2 Link Parameters

=item B<!MainField>

The B<!MailField> parameter holds a fieldname which is used to retrieve
a key value for the search in the linked table from the main table.
If omitted, it is set to the same value as B<!LinkedField>.

=item B<!LinkedField>

The fieldname which holds the key value in the linked table.
If omitted, it is set to the same value as B<!MainField>.

=item B<!NameField>

This specifies the field or fields which will be used as a "name" for the destination table. 
It may be a string or a reference to an array of strings.
For example, if you link to an address table, you may specify the field "nickname" as the 
name field
for that table, or you may use ['name', 'street', 'city'].

Look at B<!LinkName> for more information.


B<... this is very confusing... there is some stuff in test.pl in the
Recorset distribution which does this... but boy is it confusing!>

=item B<!DoOnConnect>

You can give an SQL Statement (or an array reference of SQL
statements), that will be executed every time, just after an connect
to the db. As third possibilty you can give an hash reference. After
every successful connect, DBIx::Recordset excutes the statements, in
the element which corresponds to the name of the driver. '*' is
executed for all drivers.

=item B<!Default>

Specifies default values for new rows that are inserted via hash or array access. The Insert
method ignores this parameter.

=item B<!TieRow>

Setting this parameter to zero will cause DBIx::Recordset to B<not> tie the returned rows to
an DBIx::Recordset::Row object and instead returns an simple hash. The benefit of this is
that it will speed up things, but you aren't able to write to such an row, nor can you use
the link feature with such a row.

=item B<!Debug>

Set the debug level. See DEBUGGING.


=item B<!PreFetch>

Only for tieing a hash! Gives an where expression (either as string or as hashref) 
that is used to prefetch records from that
database. All following accesses to the tied hash only access this prefetched data and
don't execute any database queries. See C<!Expires> how to force a refetch.
Giving a '*' as value to C<!PreFetch> fetches the whole table into memory.

 The following example prefetches all record with id < 7:

 tie %dbhash, 'DBIx::Recordset::Hash', {'!DataSource'   =>  $DSN,
                                        '!Username'     =>  $User,
                                        '!Password'     =>  $Password,
                                        '!Table'        =>  'foo',
                                        '!PreFetch'     =>  {
                                                             '*id' => '<',
                                                             'id' => 7
                                                            },
                                        '!PrimKey'      =>  'id'} ;

 The following example prefetches all records:

 tie %dbhash, 'DBIx::Recordset::Hash', {'!DataSource'   =>  $DSN,
                                        '!Username'     =>  $User,
                                        '!Password'     =>  $Password,
                                        '!Table'        =>  'bar',
                                        '!PreFetch'     =>  '*',
                                        '!PrimKey'      =>  'id'} ;

=item B<!Expires>

Only for tieing a hash! If the values is numeric, the prefetched data will be refetched 
is it is older then the given number of seconds. If the values is a CODEREF the function
is called and the data is refetched is the function returns true.

=item B<!MergeFunc>

Only for tieing a hash! Gives an reference to an function that is called when more then one
record for a given hash key is found to merge the records into one. The function receives
a refence to both records a arguments. If more the two records are found, the function is
called again for each following record, which is already merged data as first parameter.

 The following example sets up a hash, that, when more then one record with the same id is
 found, the field C<sum> is added and the first record is returned, where the C<sum> field
 contains the sum of B<all> found records:

 tie %dbhash, 'DBIx::Recordset::Hash', {'!DataSource'   =>  $DSN,
                                        '!Username'     =>  $User,
                                        '!Password'     =>  $Password,
                                        '!Table'        =>  'bar',
                                        '!MergeFunc'    =>  sub { my ($a, $b) = @_ ; $a->{sum} += $b->{sum} ; },
                                        '!PrimKey'      =>  'id'} ;



=head1 AUTHOR

T. M. Brannon, <tbone@cpan.org>

=cut
