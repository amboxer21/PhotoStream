package PhotoStream;

use strict;
#use warnings;
#use diagnostics;

use Tk;
use Tk::Photo;
use Data::Dumper;
use Facebook::Graph;

require Tk::Pane;
require Tk::Dialog;
require Tk::Checkbox;
require Tk::ErrorDialog;

my $file;
my $code;
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

my $mw = MainWindow->new;
   $mw->geometry("700x600");   
   $mw->title("PhotoStream");

my $Menu = $mw->Menu();
   $mw->configure( -menu => $Menu );
   $mw->protocol( WM_DELETE_WINDOW => \&ask );

my $File = $Menu->cascade( -label => 'File', );
   $File->command( -label => 'Quit', -accelerator => 'Ctrl-q', -command => sub { exit; } );
   $File->separator;
   
my $DummyOpt1 = $File->command( -label => 'DummyOpt1', );

my $Help = $Menu->cascade( -label => 'Help', -underline => 0, -tearoff => 0 );
   $Help->command( -label => "Brief", -underline => 0, -command => \&how_to );

my $Pane = $mw->Scrolled( 'Pane', Name => 'Image Display',
        		  -scrollbars => 'e',
	 		  -width => 540,
			  -height => 500, 
			  -background => "WHITE" )->pack( -side => 'top', -anchor => 'ne', -padx => '8', -pady => '8', -fill => 'x', -expand => '1' );

my $RadioButtonAlbums = $mw->Checkbutton( -text => 'Albums', 
				          -variable => \$Action, )->pack( -side => 'top', -anchor => 'sw', -padx => '10', -padx => '10', -after => $Pane, );

my $CodeButton = $mw->Button( -text => "Get Code", -command => \&get_code_button )->pack( -side => 'left', -anchor => 'sw', -pady => 4, -padx => 5 );
my $DLButton = $mw->Button( -text => "Download", -command => \&PhotoStream )->pack( -side => 'right', -anchor => 'se', -pady => 4, -padx => 5 );
my $Label = $mw->Label( -text => 'CODE= ')->pack( -side => 'left', -anchor => 'sw', -pady => 5 );

my $entry = $mw->Entry( -background=> 'white', 
			-foreground => 'black', 
			-width => 165, 
			-show => '*', 
			-textvariable => \$code,
			-exportselection => '1', )->pack( -side => 'left', -anchor => 'sw', -padx => 5, -pady => 6 );

my $token_string;
my $token_response_object;

#######################
## Token sub routine.##
#######################
sub token {
   $token_response_object = $fb->request_access_token($code);
   $token_string = $token_response_object->token;
   my $token_expires_epoch = $token_response_object->expires;
      $ENV{'token_string'} = $token_string;
};

#################################
## Get_code_button sub routine.##
#################################
sub get_code_button {
   system ("/opt/google/chrome/chrome", "$uri");
};

############################
## Get_albums sub routine.##
############################
my $GetAlbumsButtons;
sub get_albums {
if ( defined($Action && $code) ) {
   &token;
      system ( "wget https://graph.facebook.com/me/albums?access_token=$token_string -O albums" );

      open my $FILE, '<', "albums", or die "Can't open file: $!";

   my @lines = <$FILE>;

      open my $FileAlbumNames, '>', "Album_Names", or die "Can't open file: $!";
      open my $FileAlbumIdList, '>', "Album_ID_list", or die "Cant open file: $!";

   my $Decoded;
foreach my $i ( @lines ) {
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
      #&get_albums;

   my @Buttons;
   my $TlwAlbums = $mw->Toplevel;
      $TlwAlbums->title( 'Albums' );

      open $FILE, "<Album_Names", or die "Can't open file: $!";

   @lines = <$FILE>;

   my $NumberOfAlbums = scalar @lines;
      print "You have $NumberOfAlbums albums.\n\n";
      close( $FILE ) or die "Cannot close file: $!";

my $i = 0;
my @Selected;
foreach my $n ( @lines ) {
   $TlwAlbums->Checkbutton( -text => "$n", 
                     -onvalue => $n,
   	             -offvalue => 0,
		     -variable => \$Selected[$i], )->pack(-side => 'top', -anchor => 'nw' ); 
   $i=$i+1;
 }

my $GetAlbumsButtons = $TlwAlbums->Button( -text => "Get Albums",
				           -command => \&value, )->pack(  -side => 'left', -anchor => 'sw', -padx => '5', -pady => '5' ); 

my $CancelButtons = $TlwAlbums->Button( -text => "Cancel",
				        -command => , sub { print "Operation cancelled.\n"; $TlwAlbums->withdraw }, )
					->pack(  -side => 'right', -anchor => 'se', -padx => '5', -pady => '5' ); 

sub value {
for my $x ( @Selected ) {
   if( $x ne 0 ) { #&& $x =~ m/LINUX/ ) {
   print "$x";
   } #elsif ( $x == ' ' ) { print "No albums were selected.\n" }
 } print "\n";
};

# NEED GET ALBUM HANDLER HERE.

      &get_albums_button;

      } elsif ( defined($Action) && ! defined($code) ) {
        &empty_code;
        } 
};

########################
## How_to sub routine.##
########################
sub how_to {
my $HowTo = <<'END_MESSAGE';

  Clicking on the Get Code button will open a new tab in your browser.

  There is a query string within the URL. You must copy everything after
  code= and paste it into the code text entry bar in PhotoStream. 

  Clicking 
  Download will then start PhotoStream and automate the process of downloading
  all of your Facebook photos.
  
END_MESSAGE

my $DialogHowTo = $mw->Dialog( -title => "How To", -text => "$HowTo" );
   $DialogHowTo->Show( );
};

#########################
## Options sub_routine.##
#########################
sub options {
my $Options = <<'END_MESSAGE';

   Please choose the albums you want to download.
  
END_MESSAGE

my $DialogOptions = $mw->Dialog( -title => "Error", -text => "$Options" );
   $DialogOptions->Show( );
};

############################
## Empty_code sub routine.##
############################
sub empty_code {
my $EmptyCode = <<'END_MESSAGE';

   'Code =' cannot be empty. Click on the get code button to retrieve the code.
  
END_MESSAGE

my $DialogEmptyCode = $mw->Dialog( -title => "Error", -text => "$EmptyCode" );
   $DialogEmptyCode->Show( );
};

#Get albums button function needs to be built!
############################
## Get_albums sub routine.##
############################
sub get_albums_button {
if ( defined ($GetAlbumsButtons) ) {
   print "Get Albums Button Pressed.\n"
 }
};

#############################
## PhotoStream sub routine.##
#############################
sub PhotoStream {
if ( ! defined($Action) && defined($code) ) {
   &token; 
      system ( "wget https://graph.facebook.com/me/albums?access_token=$token_string -O albums && bash Parser" );
      } elsif ( ! defined($Action && $code) ) {
        &empty_code;
        }
	&get_albums;
};

sub ask {
my $Tlw = $mw->Toplevel;
   $Tlw->title('Prompt');
my $Label = $Tlw->Label( -text => 'Are you sure?' )->pack( -side => 'top', -pady => '15' );

   $Tlw->Button( -text => "Quit", 
		       -command => sub { exit; }, )->pack( -side => 'left', -anchor => 'sw', -padx => '5', -pady => '5' );

   $Tlw->Button( -text => "Cancel",
		       -command => sub { $Tlw->withdraw }, )->pack( -side => 'right', -anchor => 'se', -padx => '5', -pady => '5' );
};

MainLoop;
