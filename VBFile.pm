package MVS::VBFile;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use Carp;

require Exporter;

@ISA = qw(Exporter);
@EXPORT = qw(vbget);
$VERSION = '0.03';

my $blib = 0;  # Bytes left in block
$MVS::VBFile::bdws = 0;

#--- vbget gets a single record; if called in array context (the user
#--- wants all records in a single array), it calls vbget_array.
#
sub vbget {
 my $FH = shift;  # Filehandle
 if (wantarray) {
    return vbget_array($FH);
 }

 my ($bdw, $rdw, $reclen, $v_record, $n);
 if ($blib == 0 && $MVS::VBFile::bdws) {
	#--- Beginning of a block: read the Block Descriptor Word
	#--- if we've been told to.
    $n = read($FH, $bdw, 4);
    if ($n < 4) {  # End of file
       return undef();
    }
    $blib = unpack("n2", substr($bdw, 0,2)) - 4;
 }
	#--- Now read the Record Descriptor Word
 $n = read($FH, $rdw, 4);
 if ($n < 4) {
    return undef() if ! $MVS::VBFile::bdws;  # End of file
    Carp::carp "vbget: Unexpected end of file";
    return undef();
 }
 $reclen = unpack("n2", substr($rdw, 0,2)) - 4;
 
 $n = read($FH, $v_record, $reclen);
 if ($n != $reclen) {
    Carp::carp "vbget: Unexpected end of file";
 }
 $blib = $blib - ($reclen + 4)  if $MVS::VBFile::bdws;

 return $v_record;
}

#--- Get all records in a single array.
#
sub vbget_array {
 my $FH = shift;  # Filehandle
 my ($bdw, $rdw, $reclen, $v_record, $n);
 my @out = ();

 while (1) {
    if ($blib == 0 && $MVS::VBFile::bdws) {
	#--- Beginning of a block: read the Block Descriptor Word
	#--- if we've been told to.
       $n = read($FH, $bdw, 4);
       if ($n < 4) {  # End of file
          return @out;
       }
       $blib = unpack("n2", substr($bdw, 0,2)) - 4;
    }
	#--- Now read the Record Descriptor Word
    $n = read($FH, $rdw, 4);
    if ($n < 4) {
       return @out if ! $MVS::VBFile::bdws;  # End of file
       Carp::carp "vbget: Unexpected end of file";
       return @out;
    }
    $reclen = unpack("n2", substr($rdw, 0,2)) - 4;
 
    $n = read($FH, $v_record, $reclen);
    if ($n != $reclen) {
       Carp::carp "vbget: Unexpected end of file";
       return @out;
    }
    $blib = $blib - ($reclen + 4)  if $MVS::VBFile::bdws;
    push @out, $v_record;
 }
}

1;

__END__

=head1 NAME

MVS::VBFile - Perl extension to read variable blocked files from MVS

=head1 SYNOPSIS

  use MVS::VBFile;
  $next_record = vbget(*FILEHANDLE);
  @whole_enchilada = vbget(*FILEHANDLE);

=head1 DESCRIPTION

This module provides a single function, vbget(), to get records from
a mainframe MVS file in variable blocked (VB) format.  It works like
the angle operator: when called in scalar context, it returns the next
record; when in array context, it returns the entire file in a single
array.  The file must be in "binary" format (no translation of bytes)
and include record descriptor words.  The file may include block
descriptor words but need not.

The rationale behind this is as follows.  Most files from MVS
systems are either fixed-length (record format FB) or variable-length
(recfm VB).  Perl can read fixed-length mainframe files just as it
reads other fixed-length files -- open, read a certain number of bytes,
close -- but variable-length files require some special handling.
Since Perl provides open and close, the only function needed is one to 
get the next record.

Read the file as follows:

  open FILEHANDLE, "..name..";
  while (vbget(*FILEHANDLE)) {  # Be sure to use '*'!!
     # process and reality...
  }
  # OR do this:
  @much_in_little = vbget(*FILEHANDLE);
  # and then process the array (only on small files, of course).
  close FILEHANDLE;

=head1 VARIABLE

The variable B<MVS::VBFile::bdws> tells the module whether the file
to be read contains block descriptor words.  The default is 0 (false);
set it to 1 or any other true value if the file contains BDW's.

=head1 RESTRICTIONS

VB (blocked) and V (unblocked) formats are supported.  This function
will not work properly on format VBS (spanned).  Since VB is by far
the most commonly used format, this should not be a major snag.

=head1 MORE ABOUT DESCRIPTOR WORDS

Record descriptor words are 4 bytes that appear at the beginning of
each record in a VB file.  The first two bytes contain the record
length in binary (16 bits, signed, big-endian); the last two are used
only by spanned records and are ignored by this module.  Block
descriptor words, likewise, are 4 bytes that appear at the beginning
of each block, having the same format.

My experience with FTP from MVS is limited, but it seems that if you
transfer a file from an MVS host via FTP including the RDW's, the
RDW's will be transferred but the BDW's will not.  Most applications
do not require BDW's, but if you want them, they can be transferred
by converting the VB file to undefined records (recfm=U) under MVS
and then transferring the converted file.

=head1 AUTHOR

W. Geoffrey Rommel, grommel@sears.com, March 1999.

=cut
