#!/usr/bin/perl -w
#
# Copyright (c) 2011 Henrik Brix Andersen <henrik@brixandersen.dk>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

use Getopt::Long qw/:config bundling/;
use Imager::QRCode;
use SVG qw/-nocredits => 1/;

use strict;

my $level = 'H';
my $margin = 1;
my $scale = 10;
my $version = 0;
GetOptions('level|l=s'		=> \$level,
		   'margin|m=i'		=> \$margin,
		   'scale|s=i'		=> \$scale,
		   'version|v=i'	=> \$version,
		   'help|h'			=> sub { usage(); exit });

my $text = $ARGV[0];
unless ($text) {
	usage();
	exit;
}
unless ($level =~ /^[LMQH]$/) {
	usage();
	exit;
}

my $black = Imager::Color->new(0, 0, 0);
my $white = Imager::Color->new(255, 255, 255);
my $qrcode = Imager::QRCode->new(
	'size'			=> 1,
	'margin'		=> $margin,
	'version'		=> $version,
	'level'			=> $level,
	'casesensitive'	=> 1,
	'lightcolor'	=> $white,
	'darkcolor'		=> $black,
    );

my $img = $qrcode->plot($text);
my $width = $img->getwidth;
my $height = $img->getheight;

my $svg = SVG->new('width' => $width * $scale, 'height' => $height * $scale);
my $d;

for (my $y = 0; $y < $height; $y++) {
	my $ys = ($y + 0.5) * $scale;
	$d .= "M 0 $ys ";

	for (my $x = 0; $x < $width; $x++) {
		my $xs = ($x + 1) * $scale;
		my $color = $img->getpixel('x' => $x, 'y' => $y);

		if ($color->equals('other' => $black)) {
			$d .= "H $xs ";
		} else {
			$d .= "M $xs $ys ";
		}
	}
}

$svg->path('d' => $d,
		   'style' => {
			   'fill' => 'none',
			   'stroke' => 'rgb(0,0,0)',
			   'stroke-width' => $scale,
			   'stroke-linecap' => 'butt',
		   });

print $svg->xmlify;

sub usage {
	print STDERR <<EOF
Usage: $0 [options] TEXT

Options:
--level, -l          QR code level (L, M, Q or H)
--margin, -m         margin size
--scale, -s          scale in pixels/block
--version, -v        QR code version

--help, -h           Print this help text

EOF
}
