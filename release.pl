print $/;
print " Changes should be made to Playground.tt *not* Playgroun.pm \n";
print $/;

print $/;
print "I hope you bumped the version number", $/;
print $/;

`cd scripts; manifest-files.pl`;

`tt.pl Playground.tt`;
rename('Playground.tt-out', 'Playground.pm');

open M, ">MANIFEST";

open L, "MANIFEST.sans-scripts";
print M $_ while <L>;
open L, "scripts/LOCAL_MANIFEST";
print M $_ while <L>;

