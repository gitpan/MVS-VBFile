# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

################## We start with some black magic to print on failure.

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}
use MVS::VBFile;
$loaded = 1;
print "ok 1\n";

################## End of black magic.

#--- Test scalar call (no BDW's).
open(VB, "./mvsvb1.txt") or die "Could not open: $!";
while ($r = vbget(*VB)) {
   $n++;
   $rec1 = $r  if $n == 1;
}
if ($n == 3 && substr($rec1,0,4) eq "\xC2\x85\x88\x96") {
   print "ok 2\n";
} else {
   print "not ok 2\n";
}
close VB;

#--- Test array call (no BDW's).
open(VB, "./mvsvb1.txt") or die "Could not open: $!";
$n = 0;
@aa = vbget(*VB);
if (@aa == 3 && substr($aa[2],0,4) eq "\x60\x60\xC9\x40") {
   print "ok 3\n";
} else {
   print "not ok 3\n";
}
close VB;


#--- Test scalar call (with BDW's).
$MVS::VBFile::bdws = 1;
open(VB, "./mvsvb2.txt") or die "Could not open: $!";
while ($r = vbget(*VB)) {
   $n++;
   $rec1 = $r  if $n == 1;
   $rec20 = $r if $n == 20;
}
if ($n == 20 && substr($rec1,0,4) eq "\xC2\x93\x85\xA2"
     && substr($rec20,0,4) eq "\x40\x40\xE3\x88") {
   print "ok 4\n";
} else {
   print "not ok 4\n";
}
close VB;

#--- Test array call (with BDW's).
open(VB, "./mvsvb2.txt") or die "Could not open: $!";
$n = 0;
@aa = vbget(*VB);
if (@aa == 20 && substr($aa[0],0,4) eq "\xC2\x93\x85\xA2"
     && substr($aa[19],0,4) eq "\x40\x40\xE3\x88") {
   print "ok 5\n";
} else {
   print "not ok 5\n";
}
close VB;
