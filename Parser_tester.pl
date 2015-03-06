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
      if( my $next_urls = $_ =~ m/(next\":\"https:\\\/\\\/graph\.facebook\.com\\\/[a-z][0-9]\.[0-9]+\\\/[0-9]+\\\/[a-z]+\?access_token=[a-zA-Z0-9&=]+)/ ) { 
	$next_urls = $1;
	$next_urls =~ s/([\"\\]|next)//g;
	print "$next_urls ";
      }
      #print $_ # tester
      }

   close($URLS);
   }

 }
close( $Photostream_photos );
close( $PhotostreamAlbumList );
close( $TMP );
