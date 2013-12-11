package PhotoStream;

use Tk;
use strict;
use Data::Dumper;
use Facebook::Graph;

require Tk::Dialog;

my $file;
my $code;
my $app_id		= '231557	030323853';
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
   #$mw->geometry("400x400");
my $Frame = $mw -> Frame( -container => 1, -height => 5, -width => 5 );   
   $mw->title("PhotoStream");

my $Menu = $mw->Menu();
   $mw->configure( -menu => $Menu );

my $File = $Menu->cascade( -label => 'File', -underline => 0, -tearoff => 0 );
   #

my $Help = $Menu->cascade( -label => 'Help', -underline => 0, -tearoff => 0 );
   $Help->command( -label => "Brief", -underline => 0, -command => \&how_to );

my $CodeButton = $mw->Button( -text => "Get Code", -command => \&button_sub )->pack( );
my $DLButton = $mw->Button( -text => "Download", -command => \&PhotoStream )->pack( );
my $Close = $mw->Button( -text => "Close", -command => \&close )->pack( -fill => 'both' );
my $DummyButton2 = $mw->Button( )->pack( );

my $entry = $mw->Entry( -background=> 'white', -foreground => 'black', -width => 28, -show => '*', -textvariable => \$code )->pack( );
my $Label = $mw->Label( -text => 'CODE= ')->pack( );

   $Label->grid( -row => 5, -column => 1 );
   $entry->grid( -row => 5, -column => 4 );
   $DummyButton2->grid( -row => 2, -column => 1, -sticky => 'w', );
   $Close->grid( -row => 3, -column => 1, );
   $DLButton->grid( -row => 5, -column => 5, );
   $CodeButton->grid( -row => 4, -column => 1, );

=pod
my $ProgressBar = $mw->ProgressBar( 
   -side => 'center', 
   -width => 20, 
   -length => 200, 
   -from => 0, 
   -to => 100, 
   -blocks => 10, 
   -colors => [0, 'green', 50, 'yellow' , 80, 'red'],
   -variable => \&PhotoStream
   )->pack( );
   $ProgressBar->value();
=cut

sub button_sub {
   system ("/opt/google/chrome/chrome", "$uri");
   #$code->get(0, 'end'); 
};

sub PhotoStream {
my $token_response_object = $fb->request_access_token($code);
my $token_string = $token_response_object->token;
my $token_expires_epoch = $token_response_object->expires;
   $ENV{'token_string'} = $token_string;
   system ("wget https://graph.facebook.com/me/albums?access_token=$token_string -O albums && bash Parser");
   };

sub how_to {
my $HowTo = <<'END_MESSAGE';

  Clicking on the Get Code button will open a new tab in your browser.

  There is a query string within the URL. You must copy everything after
  code= and paste it into the code text entry bar in PhotoStream. 

  Clicking 
  Download will then start PhotoStream and automate the process of downloading
  all of your Facebook photos.
  
END_MESSAGE

my $Dialog = $mw->Dialog( -title => "How To", -text => "$HowTo" );
   $Dialog->Show( );
};

sub close {
   exit 0;
   #system( readarray -t array < <( pgrep -f PhotoStreamUI.pl ); for i in "${array[@]}"; do kill -9 $i; done )
};

MainLoop;
