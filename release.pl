print $/;
print " Changes should be made to Playground.tt *not* Playground.pm \n";
print " Changes should be made to MANIFEST.sans-scripts *not* MANIFEST \n";
print $/;

print $/;
print "I hope you bumped the version number", $/;
print $/;

#`cd scripts; ../delete-whitespace.pl; ../manifest-files.pl`;

`tt.pl Playground.tt`;
rename('Playground.tt-out', 'Playground.pm');

open M, ">MANIFEST";

open L, "MANIFEST.sans-scripts";
print M $_ while <L>;
print M $_, $/ while <scripts/*.pl>;


print <<'EOTEXT';
Now goto a cygwin shell and type

  perl Makefile.PL PREFIX=$PREFIX
  make tardist
  upload-cpan.pl $release

# dont you just love Windows?
EOTEXT

