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
