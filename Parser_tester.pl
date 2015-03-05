#!/usr/local/bin/perl -w

use strict;

   opendir my $DIR, '.' or die "Cant open directory: $!";

my @files = readdir($DIR);
closedir( $DIR );

   open my $Photostream_photos, '>>', "Photostream_photos" or die "Cannot open Photostream_photos: $!";
   open my $PhotostreamAlbumList, '>>', "PhotostreamAlbumList" or die "Cannot open PhotstreamAlbumList: $!";
   open my $TMP, '>>', "TMP" or die "Cannot open PhotstreamAlbumList: $!";

foreach my $F ( @files ) {
   if( $F =~ m/Photostream_Album/ ) {
   my @regex_array = "$F\n";
   print "$F\n";
   #system qq(cat "$_" >> "$TMP" );
   open my $URLS, $F or die "Cannot open file: $!";

   while (<$URLS>) {
      print $TMP "$_\n";
      if( $_ =~ m/https/ ) { print }
      }

   close($URLS);
   }

 }
close( $Photostream_photos );
close( $PhotostreamAlbumList );
close( $TMP );
