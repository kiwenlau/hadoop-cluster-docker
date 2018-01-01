#!/usr/bin/perl
#
# Google Drive direct download of big files
# ./gdown.pl 'gdrive file url' ['desired file name']
#
# v1.0 by circulosmeos 04-2014.
# http://circulosmeos.wordpress.com/2014/04/12/google-drive-direct-download-of-big-files
#
use strict;

my $TEMP='/tmp';
my $COMMAND;
my $confirm;
my $check;
sub execute_command();

my $URL=shift;
die "\n./gdown.pl 'gdrive file url' [desired file name]\n\n" if $URL eq '';
my $FILENAME=shift;
$FILENAME='gdown' if $FILENAME eq '';

execute_command();

while (-s $FILENAME < 100000) { # only if the file isn't the download yet
    open fFILENAME, '<', $FILENAME;
    $check=0;
    foreach (<fFILENAME>) {
        if (/href="(\/uc\?export=download[^"]+)/) {
            $URL='https://docs.google.com'.$1;
            $URL=~s/&amp;/&/g;
            $confirm='';
            $check=1;
            last;
        }
        if (/confirm=([^;&]+)/) {
            $confirm=$1;
            $check=1;
            last;
        }
        if (/"downloadUrl":"([^"]+)/) {
            $URL=$1;
            $URL=~s/\\u003d/=/g;
            $URL=~s/\\u0026/&/g;
            $confirm='';
            $check=1;
            last;
        }
    }
    close fFILENAME;
    die "Couldn't download the file :-(\n" if ($check==0);
    $URL=~s/confirm=([^;&]+)/confirm=$confirm/ if $confirm ne '';

    execute_command();
}

sub execute_command() {
    $COMMAND="wget -nv --load-cookie $TEMP/cookie.txt --save-cookie $TEMP/cookie.txt \"$URL\"";
    $COMMAND.=" -O \"$FILENAME\"" if $FILENAME ne '';
    `$COMMAND`;
    return 1;
}
