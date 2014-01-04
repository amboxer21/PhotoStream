package PhotoStream;

use strict;

use Tk;
use Tk::Photo;
use Data::Dumper;
use Facebook::Graph;

require Tk::Checkbox;
require Tk::Dialog;
require Tk::Pane;

my $file;
my $code;
my $Action;

my $app_id		= 'APP_ID';
my $app_secret		= 'APP_SECRET';
my $postback_url	= 'POSTBACK_URL';

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

my $File = $Menu->cascade( -label => 'File', -underline => 0, -tearoff => 0 );
   #

my $Help = $Menu->cascade( -label => 'Help', -underline => 0, -tearoff => 0 );
   $Help->command( -label => "Brief", -underline => 0, -command => \&how_to );

my $Pane = $mw->Scrolled( 'Pane', Name => 'Image Display',
        -scrollbars => 'e',
	-width => 540,
	-height => 500, 
	-background => "WHITE"
	)->pack( -side => 'top', -anchor => 'ne', -padx => '8', -pady => '8', -fill => 'x', -expand => '1' ); #-fill => 'both', -expand => '1' 

my $RadioButtonAlbums = $mw->Checkbutton( -text => 'Albums', 
				    -variable => \$Action, 
				    #-value => 'Up', 
				    #-command => \&options, 
				    )->pack( -side => 'top', -anchor => 'sw', -padx => '10', -padx => '10', -after => $Pane, );

my $CodeButton = $mw->Button( -text => "Get Code", -command => \&button_sub )->pack( -side => 'left', -anchor => 'sw', -pady => 4, -padx => 5 );
my $DLButton = $mw->Button( -text => "Download", -command => \&PhotoStream )->pack( -side => 'right', -anchor => 'se', -pady => 4, -padx => 5 );
my $Label = $mw->Label( -text => 'CODE= ')->pack( -side => 'left', -anchor => 'sw', -pady => 5 );

my $entry = $mw->Entry( -background=> 'white', 
			-foreground => 'black', 
			-width => 165, 
			-show => '*', 
			-textvariable => \$code,
			-exportselection => '1', )->pack( -side => 'left', -anchor => 'sw', -padx => 5, -pady => 6 );

sub button_sub {
   system ("/opt/google/chrome/chrome", "$uri");
};

#print "CODE = $code.\n";

=pod
sub get_albums {
my $token_response_object = $fb->request_access_token($code);
my $token_string = $token_response_object->token;
my $token_expires_epoch = $token_response_object->expires;
   $ENV{'token_string'} = $token_string;
   system ("wget https://graph.facebook.com/me/albums?access_token=$token_string -O albums && bash AlbumNames");
   };
=cut

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

sub options {
my $Options = <<'END_MESSAGE';

Please choose the albums you want to download.
  
END_MESSAGE

my $DialogOptions = $mw->Dialog( -title => "Error", -text => "$Options" );
   $DialogOptions->Show( );
};

sub empty_code {
my $EmptyCode = <<'END_MESSAGE';

'Code =' cannot be empty. Click on the get code button to retrieve the code.
  
END_MESSAGE

my $DialogEmptyCode = $mw->Dialog( -title => "Error", -text => "$EmptyCode" );
   $DialogEmptyCode->Show( );
};

sub PhotoStream {
if ( ! defined($Action) && defined($code) ) {
my $token_response_object = $fb->request_access_token($code);
my $token_string = $token_response_object->token;
my $token_expires_epoch = $token_response_object->expires;
   $ENV{'token_string'} = $token_string;
   system ("wget https://graph.facebook.com/me/albums?access_token=$token_string -O albums && bash Parser2");
   } elsif ( ! defined($Action && $code) ) {
     &empty_code;
     }

if ( defined($Action && $code) ) {
my $token_response_object = $fb->request_access_token($code);
my $token_string = $token_response_object->token;
my $token_expires_epoch = $token_response_object->expires;
   $ENV{'token_string'} = $token_string;
   system ("wget https://graph.facebook.com/me/albums?access_token=$token_string -O albums && bash AlbumNames");
   #&get_albums;

my @Buttons;

my $DialogAlbums = $mw->Dialog( -title => "Albums", );
#my $Show = $Dialog->Show( );

open FILE, "<Album_Names", or die "Can't open file: $!";

my @lines = <FILE>;

my $NumberOfAlbums = scalar @lines;
   print $NumberOfAlbums;

close FILE or die "Cannot close file: $!";

for (my $i = 1; $i <= $NumberOfAlbums; $i++) {
  push (@Buttons, $DialogAlbums->Checkbutton(-text => "$lines[$i]"));
  }

foreach (@Buttons) {
   $_->pack(-side => 'top', -anchor => 'nw' );
   } 
   $DialogAlbums->Show( );

my $DialogAlbums = $mw->Dialog( -title => "Albums", );
   
     } elsif ( defined($Action) && ! defined($code) ) {
     &empty_code;
     } 

};

MainLoop;
