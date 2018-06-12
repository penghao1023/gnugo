#!/usr/bin/perl
# This script morphs config.h.in into config.vcin

use strict;
use warnings;

my %defaults =
 ( CHINESE_RULES => 0,
   RESIGNATION_ALLOWED => 1,
   HASHING_SCHEME => 2,
   DEFAULT_LEVEL => 10,
   DEFAULT_MEMORY => 8,
   ENABLE_SOCKET_SUPPORT => 1,
   ALTERNATE_CONNECTIONS => 1,
   SEMEAI_NODE_LIMIT => 500,
   OWL_NODE_LIMIT => 1000,
   EXPERIMENTAL_SEMEAI => 1,
   EXPERIMENTAL_OWL_EXT => 0,
   EXPERIMENTAL_CONNECTIONS => 1,
   LARGE_SCALE => 0,
   GRID_OPT => 1,
   OWL_THREATS => 0,
   USE_BREAK_IN => 1,
   COSMIC_GNUGO => 0,
   ORACLE => 0,
   USE_VALGRIND => 0,
   READLINE => 0);

my @skip = qw/
  GNU_PACKAGE 
  SIZEOF_INT 
  SIZEOF_LONG 
  GNUGO_PATH
  PACKAGE
  SIZEOF_INT
  SIZEOF_LONG
  const
  ANSI_COLOR
  TERMINFO
  VERSION
  TIME_WITH_SYS_TIME
  /;

open (CONFIGH, "config.h.in") or
      die "Couldn't open config.h.in: $!";
  
open (CONFIGVC, ">config.vcin")  or
      die "Couldn't overwrite config.vcin: $!";
  
print CONFIGVC 
q%/* This is the Microsoft Visual C++ version of config.h        *
 * Replace the distributed config.h with this file             *
 * See config.h.in for comments on the meanings of most of the *
 * defines.  This file is autogenerated.  Do not modify it.    *
 * See instead, the perl script makevcdist.pl                  */

#define HAVE_CRTDBG_H 1
#define HAVE_WINSOCK_IO_H 1
#define HAVE__VSNPRINTF 1

%;

  
my $comment = "";  
while (<CONFIGH>) {
  s/\s*$//ms;
  if (/^\s*$/) { next; }
  if (m@^/[*].*@) {
    $comment = $_;
    next;
  }
  if (/\*\/\s*$/) {
    $comment .= "\n$_";
    next;
  }
  if (/HAVE_/) { next; }
  if (! /^#undef\s+([^ ]*)\s*$/ms) {
    warn "Don't understand: $_";
    next;
  }
  my $define = $1;
  if (!defined($defaults{$define})) {
    my $found =0;
    foreach (@skip) {$found = 1 if $_ eq $define;}
    warn "Unknown define: $define" unless $found;
    next;
  }
  print CONFIGVC "$comment\n";
  print CONFIGVC "#define $define $defaults{$define}\n\n";
}

print CONFIGVC
q%
/* Version number of package */
#define PACKAGE "gnugo"

/* The concatenation of the strings "GNU ", and PACKAGE.  */
#define GNU_PACKAGE "GNU " PACKAGE

/* The number of bytes in a int.  */
#define SIZEOF_INT 4

/* The number of bytes in a long.  */
#define SIZEOF_LONG 4

/* Version number of package */
#define VERSION "@VERSION@"

#pragma warning(disable: 4244 4305)
%;
