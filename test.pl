# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

################## We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use MVS::VBFile;
$loaded = 1;
print "ok 1\n";

################## End of black magic.

#--- Test scalar call.
open(VB, "./mvs_vb.testfile") or die "Could not open: $!";
while ($r = vbget(*VB)) {
   $n++;
   $rec1 = $r  if $n == 1;
   $rec20 = $r if $n == 20;
}
if ($n == 20 && substr($rec1,0,4) eq "\xC2\x93\x85\xA2"
     && substr($rec20,0,4) eq "\x40\x40\xE3\x88") {
   print "ok 2\n";
} else {
   print "not ok 2\n";
}
close VB;

#--- Test array call.
open(VB, "./mvs_vb.testfile") or die "Could not open: $!";
$n = 0;
@aa = vbget(*VB);
if (@aa == 20 && substr($aa[0],0,4) eq "\xC2\x93\x85\xA2"
     && substr($aa[19],0,4) eq "\x40\x40\xE3\x88") {
   print "ok 3\n";
} else {
   print "not ok 3\n";
}
close VB;
