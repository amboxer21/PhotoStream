#!/usr/local/bin/perl -w

use strict;

   opendir my $DIR, '.' or die "Cant open directory: $!";

my @files = readdir($DIR);
closedir( $DIR );

my($f);
foreach my $i (@files) {
  if($i =~ (/Photostream_Album_[0-9]+/m)) {
    open $f, '<', $i or die "Cannot open $f: $!\n";
    while(<$f>) {
      if(my $next_urls = $_ =~ m/(next\":\"https:\\\/\\\/graph\.facebook\.com\\\/[a-z][0-9]\.[0-9]+\\\/[0-9]+\\\/[a-z]+\?access_token=[a-zA-Z0-9&=]+)/ ) { 
        $next_urls = $1;
        $next_urls =~ s/(next\":\")//g;
	$next_urls =~ s/([\\])//g;
	#$next_urls =~ s/(:[\"\\]|next)//g;
        print "NEXT => $next_urls\n";
      }

      # "source":"https:\/\/scontent.xx.fbcdn.net\/hphotos-xfp1\/v\/t1.0-9\/11025815_817194565026923_2716325669440810711_n.jpg
      if(my $source_urls = $_ =~ m/(source\":\"https:\\\/\\\/scontent\.[a-zA-Z0-9]+\.fbcdn\.net\\\/[a-zA-Z0-9]+\-[a-zA-Z0-9]+\\\/[a-zA-Z]+\\\/[a-zA-Z0-9-.])/) { 
        $source_urls = $1;
        #$source_urls =~ s/(source\":\")//g;
        #$source_urls =~ s/([\\])//g;
        #$next_urls =~ s/(:[\"\\]|next)//g;
        print "SOURCE => $source_urls\n";
      }
    }
    #print "$i\n";
  }
}

=cut
   open my $Photostream_photos, '>>', "Photostream_photos" or die "Cannot open Photostream_photos: $!";
   open my $PhotostreamAlbumList, '>>', "PhotostreamAlbumList" or die "Cannot open PhotstreamAlbumList: $!";
   open my $TMP, '>>', "TMP" or die "Cannot open PhotstreamAlbumList: $!";

foreach my $F ( @files ) {
   if( $F =~ m/Photostream_Album/ ) {
   my @regex_array = "$F\n";
   #print "$F\n";
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
=pod
