use strict;
use warnings;
use diagnostics;

use JSON::XS;
use Data::Dumper;
use Facebook::Graph;

my $file;
my $Action;

my $app_id		= '231557030323853';
my $app_secret		= '5ba33cd9b1dd078fc86bce38c2389cc4';
my $postback_url	= 'https://peaceful-dawn-6605.herokuapp.com/oauth';

my $fb = Facebook::Graph->new(
   desktop	=> 1,
   app_id       => $app_id,
   secret       => $app_secret,
   postback     => "$postback_url/callback",
   );

my $uri = $fb
   ->authorize
   ->extend_permissions(qw(offline_access read_stream publish_stream user_photos friends_photos))
   ->set_display('page')
   ->uri_as_string;

system("/opt/google/chrome/chrome", "$uri");

print "Code = "; 
chomp( my $code = <> );

   my $token_response_object = $fb->request_access_token($code);
   my $token_string = $token_response_object->token;
   my $token_expires_epoch = $token_response_object->expires;


      open my $Albums, '<', "albums", or die "Can't open file: $!";

   my @albums = <$Albums>;

      open my $FileAlbumNames, '>', "Album_Names", or die "Can't open file: $!";
      open my $FileAlbumIdList, '>', "Album_ID_list", or die "Cant open file: $!";

   my $Decoded;
foreach my $i ( @albums ) {
   $Decoded = JSON::XS::decode_json( $i );
 for ( @{$Decoded->{data}} ) {
    my $KeyPair = "$_->{name} $_->{id}";
    #my @Name = $_->{name}. "\n";
    my @Id = $_->{id}. "\n";
    my @answer = split(/[0-9]+$/, $KeyPair);
    print $FileAlbumNames "@answer\n";
    print $FileAlbumIdList "@Id";
 }

close( $FileAlbumNames ) or die "Cannot close file: $!";
close( $FileAlbumIdList ) or die "Cannot close file: $!";

}

   close( $Albums ) or die "Cannot close file: $!";

   open my $AlbumIdList, '<', "Album_ID_list" or die "Can't open file: $!";

my @album_ids = <$AlbumIdList>;
foreach my $i ( @album_ids ) {
   chomp( $i );
my @args = ( "wget", "https://graph.facebook.com/$i/photos?access_token=$token_string", "-O", "Photostream_Album_$i" );
   system( @args ) == 0 or die "System @args error: $!";
 }

close($AlbumIdList);

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
