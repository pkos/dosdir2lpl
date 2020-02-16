use strict;
use warnings;
use Digest::CRC qw(crc64 crc32 crc16 crcccitt crc crc8 crcopenpgparmor);
use Term::ProgressBar;

#init
my $directory = "";
my $system = "DOS";
my $substringh = "-h";

#check command line
foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "dosdir2lpl v0.6 - Generate RetroArch playlists from an unzipped DOS files directory scan. \n";
	print "\n";
	print "with dosdir2lpl [directory ...]";
    print "\n";
    print "Notes:\n";
	print "  this calculates the crc32 values of each (.bat, .exe, .com) and these are added to the playlist\n";
	print "  priority goes to batch files (skipping other executables) in each directory\n";
	print "  if batch files are not found the executables will be added to the playlist\n";
	print "\n";
	print "  [directory] should be the path to the games folder, each game will be named after game subfolders\n";
	print "\n";
	print "Example:\n";
	print '              dosdir2lpl "D:/ROMS/DOS"' . "\n";
	print "\n";
	print "Author:\n";
	print "   Discord - Romeo#3620\n";
	print "\n";
    exit;
  }
}

#set directory and system variables
if (scalar(@ARGV) < 1 or scalar(@ARGV) > 1) {
  print "Invalid command line.. exit\n";
  print "use: dosdir2lpl -h\n";
  print "\n";
  exit;
}
$directory = $ARGV[-1];
$directory =~ s/\\/\//g;

#debug
print "directory: $directory\n";

#exit no parameters
if ($directory eq "") {
  print "Invalid command line.. exit\n";
  print "use: dosdir2lpl -h\n";
  print "\n";
  exit;
}

#init output files
my @linesd;
my $playlist = "$system" . ".lpl";

#read games directory to @linesf
my $dirname = $directory;
opendir(DIR, $dirname) or die "Could not open $dirname\n";
while (my $filename = readdir(DIR)) {
  if (-d $filename) {
    next;
  } else {
    push(@linesd, $filename) unless $filename eq '.' or $filename eq '..';
  }
}
closedir(DIR);

#init varibles for playlist
my $version = '  "version": "1.2",';
my $default_core_path = '  "default_core_path": "",';
my $default_core_name = '  "default_core_name": "",';
my $label_display_mode = '  "label_display_mode": 0,';
my $right_thumbnail_mode = '  "right_thumbnail_mode": 0,';
my $left_thumbnail_mode = '  "left_thumbnail_mode": 0,';
my $items = '  "items": [';
my $romname = '';
my $zipfile = '';

#write playlist header
open(FILE, '>', $playlist) or die "Could not open file '$playlist' $!";
print FILE "{\n";
print FILE "$version\n";
print FILE "$default_core_path\n";
print FILE "$default_core_name\n";
print FILE "$label_display_mode\n";
print FILE "$right_thumbnail_mode\n";
print FILE "$left_thumbnail_mode\n";
print FILE "$items\n";

my $endoflist = $linesd[-1];
my $gamefile;
my $gamepath;
my $path;
my $ctx = Digest::CRC->new( type => 'crc32' );
my $max = scalar(@linesd);
my $progress = Term::ProgressBar->new({name => 'progress', count => $max});
my $crc;
my $romcrc;
my $subq = '?';
my $crcfilename;
my $gamefilecheck;

#print each directory from @lined to read files to playlist
HASH: foreach my $element (@linesd) {
  $progress->update($_);
  $gamepath = "$directory" . "/" . "$element" . "/";
  opendir (my $dh, $gamepath) or die "Could not open file '$gamepath' $!";
  while ($gamefile = readdir $dh) {
    if ($gamefile eq '.' or $gamefile eq '..') {
        next;
    }
	#print "$gamefile\n";
    if (substr(lc $gamefile, -4) eq '.bat') {
	  #print "$gamefile\n";
	  
	  #calculate CRC of rom file
	  $crcfilename = "$gamepath" . "$gamefile";
      #print "$crcfilename\n";
	  $crc = "00000000";
	  if ($crcfilename !~ m/[?]/) {
	    open (my $fh2, '<:raw', "$crcfilename") or die $!;
	    $ctx->addfile(*$fh2);
        close $fh2;
        $crc = uc $ctx->hexdigest;
      }
	  #write file to playlist
	  $path = '      "path": ' . '"' . "$crcfilename" . '",';
      my $name = substr $gamefile, 0, -4;
      my $label = '      "label": "' . "$element" . '"' . ',';
      my $core_path = '      "core_path": "DETECT",';
      my $core_name = '      "core_name": "DETECT",';
      my $crc32 = '      "crc32": "' . "$crc" . '|crc"' . ',';
      my $db_name = '      "db_name": "' . "$system" . '.rdb"';
      print FILE "    {\n";
      print FILE "$path\n";
      print FILE "$label\n";
      print FILE "$core_path\n";
      print FILE "$core_name\n";
      print FILE "$crc32\n";
      print FILE "$db_name\n";
      if ($element eq $endoflist){
        print FILE "    }\n";
      } else {
        print FILE "    },\n";
      }
	} elsif (substr(lc $gamefile, -4) eq '.exe' or substr(lc $gamefile, -4) eq '.com') {
	  #if directory contains a batch file skip
	  my $batchfile = "FALSE";
	  opendir (my $dh2, $gamepath) or die "Could not open file '$gamepath' $!";
      while ($gamefilecheck = readdir $dh2) {
        if (substr(lc $gamefilecheck, -4) eq '.bat') {
          $batchfile = "TRUE";
        }
        #print "$gamefile\n";
	  }
	  #print "batchfile:  $batchfile\n";
	  if ($batchfile eq "FALSE") {
	  
	    #calculate CRC of rom file
	    $crcfilename = "$gamepath" . "$gamefile";
        #print "$crcfilename\n";
	    $crc = "00000000";
	    if ($crcfilename !~ m/[?]/) {
	      open (my $fh2, '<:raw', "$crcfilename") or die $!;
	      $ctx->addfile(*$fh2);
          close $fh2;
          $crc = uc $ctx->hexdigest;
        }
	    #write file to playlist
	    $path = '      "path": ' . '"' . "$crcfilename" . '",';
        my $name = substr $gamefile, 0, -4;
        my $label = '      "label": "' . "$element" . '"' . ',';
        my $core_path = '      "core_path": "DETECT",';
        my $core_name = '      "core_name": "DETECT",';
        my $crc32 = '      "crc32": "' . "$crc" . '|crc"' . ',';
        my $db_name = '      "db_name": "' . "$system" . '.rdb"';
        print FILE "    {\n";
        print FILE "$path\n";
        print FILE "$label\n";
        print FILE "$core_path\n";
        print FILE "$core_name\n";
        print FILE "$crc32\n";
        print FILE "$db_name\n";
        if ($element eq $endoflist){
          print FILE "    }\n";
        } else {
          print FILE "    },\n";
        }	
	  }
	}  
  }
closedir $dh;

}
