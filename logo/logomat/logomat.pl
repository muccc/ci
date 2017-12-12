#!/usr/bin/perl
#
# x hat's erfunden. ;)

use Getopt::Long;
use CGI;
use File::Basename;



sub usage() {
        print <<EOF;

Usage:

EOF
	print "	".basename($0)." [--logo|-l <logoname>] [--gradient|-g <blah>] [--scheme|-s <blubb>] [you know how it works...]\n";
        print <<EOF;

--logo|-l <logoname>		name of the logo to generate (muc3, rhf)
--gradient|-g <blah>		rhombusgradient (fixed, exp, linear, blur)
--scheme|-s <blubb>		colorscheme (bow, wob, gow, gob; default: std)
--pagecolor|-p <foo>		background color
--chaosknotencolor|-c <foo>	chaosknoten color
--chaosknotenopacity|-C <foo>	chaosknoten opacity
--rhombuscolor|-r <foo>		rhombus color
--textcolor|-t <foo>		text color

...and if you don't believe me, UTSL.

EOF
	exit(1);
};

my $cgi = new CGI;
sub getcgiinput() {
	my %input;

#	my $cgi = new CGI;
	%input = $cgi->Vars;
	foreach my $fieldname ( keys %input ) {
		$input{$fieldname} = [ split(/\0/,$input{$fieldname}) ];
		my @a = $cgi->upload($fieldname);
		if ($cgi->cgi_error) {
			$errmsg .= $cgi->header(-status=>$cgi->cgi_error);
		};
		for (my $i = 0; $i <= $#{$input{$fieldname}}; $i++ ) {
			$input{$fieldname}[$i] = { "value" => $input{$fieldname}[$i], "handle" => $a[$i], "header" => $cgi->uploadInfo($input{$fieldname}[$i]) };
		};
	};

	return(%input);
};



### main

my %opt = ( "logo" => "muc3", "width" => 800, "height" => 600 );
GetOptions( \%opt, "logo|l=s", "gradient|g=s", "scheme|s=s", "pagecolor|p=s", "chaosknotencolor|c=s", "chaosknotenopacity|C=s", "rhombuscolor|r=s", "textcolor|t=s", "format|f=s", "width|x=i", "height|y=i", "help|h|?" => sub { usage(); } );

my %input;
if ( exists($ENV{"REQUEST_METHOD"}) ) {
	%input = getcgiinput();
	foreach ( "logo","scheme","gradient","pagecolor","chaosknotencolor","rhombuscolor","textcolor" ) {
		( $opt{$_} = $input{$_}[0]{"value"} ) =~ s/[^#0-9a-zA-Z]//g;
	};
	foreach ( "width","height","xscale","yscale","chaosknotenopacity","text" ) {
		( $opt{$_} = $input{$_}[0]{"value"} ) =~ s/[^0-9.]//g;
	};
	$opt{"ornament"} = $input{"ornament"}[0]{"value"};
};

my ($x,$y,$w,$h,$outset,$iter,$r,$id,$o,$transform);
my ($bordercolor,$pagecolor,$chaosknotencolor,$chaosknotenopacity,$rhombuscolor,$textcolor,$brightcolor,$lowcolor,$xscale,$yscale,$ornament,$text);
# defaults and schemas:
$xscale = "1";
$yscale = "1";
if ( $opt{"logo"} eq "muc3" ) {
	$x = 1506.5787;	# starting x-position (lower left corner)
	$y = 763.96448;	# starting y-position (lower left corner)
	$w = 406.72153;	# starting width
	$h = 305.51559;	# starting height
	$outset = 2.5;	# outset step size
	$iter = 39;	# number of iterations (initial one is 0)
	$r = 50;	# corner radius
	$id = 3000;	# starting objectid number
	$o = 1;		# initial opacity (of iteration 0)
	$transform = "transform=\"translate(175.875485288,182.708881)\"";	# move everything to the center.

	$bordercolor = "#666666";	# color of border
	$pagecolor = "#000000";		# color of background
	$chaosknotencolor = "white";	# color of chaosknoten
	$chaosknotenopacity = "0.25";	# opacity of chaosknoten
	$rhombuscolor = "yellow";	# color of rhombus
	$textcolor = "black";		# color of text "µc³"
	if ( $opt{scheme} eq "bow" ) {
		$pagecolor = "white";
		$chaosknotencolor = "black";
		$rhombuscolor = "black";
		$textcolor = "white";
	} elsif ( $opt{scheme} eq "wob" ) {
		$pagecolor = "black";
		$chaosknotencolor = "white";
		$rhombuscolor = "white";
		$textcolor = "black";
	} elsif ( $opt{scheme} eq "gow" ) {
		$pagecolor = "white";
		$chaosknotencolor = "black";
		$rhombuscolor = "#666666";
		$textcolor = "#dddddd";
	} elsif ( $opt{scheme} eq "gob" ) {
		$pagecolor = "black";
		$chaosknotencolor = "white";
		$rhombuscolor = "#dddddd";
		$textcolor = "#666666";
	};
} elsif ( $opt{"logo"} eq "rhf" ) {
	$bordercolor = "#666666";	# color of border
	$pagecolor = "#000000";		# color of background
	$textcolor = "#ff0000";		# color of strokes and fills
} elsif ( $opt{"logo"} eq "pesthoernchen" ) {
	$pagecolor = "#ffffff";		# color of background
	$textcolor = "#000000";		# color of strokes and fills
} elsif ( $opt{"logo"} eq "chaosknoten" ) {
	$pagecolor = "#ffffff";		# color of background
	$textcolor = "#000000";		# color of strokes and fills
} elsif ( $opt{"logo"} eq "fairydust" ) {
	$brightcolor = "#fdcc03";
	$lowcolor = "#fd8e07";
	if ( $opt{scheme} eq "bow" ) {
		$brightcolor = "#ffffff";
		$lowcolor = "#ffffff";
	};
};
# single specifications:
if ( $opt{pagecolor} ) {
	$pagecolor = $opt{pagecolor};
};
if ( $opt{chaosknotencolor} ) {
	$chaosknotencolor = $opt{chaosknotencolor};
};
if ( $opt{chaosknotenopacity} ) {
	$chaosknotenopacity = $opt{chaosknotenopacity};
};
if ( $opt{rhombuscolor} ) {
	$rhombuscolor = $opt{rhombuscolor};
};
if ( $opt{textcolor} ) {
	$textcolor = $opt{textcolor};
};
if ( $opt{xscale} ) {
	$xscale = $opt{xscale};
};
if ( $opt{yscale} ) {
	$yscale = $opt{yscale};
};
if ( $opt{ornament} ) {
	$ornament = $opt{ornament};
};
if ( $opt{text} ) {
	$text = $opt{text};
};

if ( exists($ENV{"REQUEST_METHOD"}) ) {
	if ( $input{"action"}[0]{"value"} eq "print" ) {
		if ( $input{"format"}[0]{"value"} eq "png" ) {
			open(my $fh,">/tmp/".basename($0).".$$.svg");
			print {$fh} svg();
			close($fh);
			system("inkscape -e /tmp/".basename($0).".$$.png -w $opt{width} -h $opt{height} /tmp/".basename($0).".$$.svg");
			print "Content-type: image/png\n\n";
			open(my $fh,"</tmp/".basename($0).".$$.png");
			print join("",<$fh>);
			close($fh);
			unlink("/tmp/".basename($0).".$$.svg");
			unlink("/tmp/".basename($0).".$$.png");
		} else {
			print "Content-type: image/svg+xml\n\n";
			print svg();
		};
	} else {
		print <<EOF;
Content-type: text/html

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
<style TYPE="text/css">
<!--
th	{ text-align: left; }
-->
</style>
</head>
<body>
<p>
<ul>
<li> the (png) image is scaled to the given resolution. so changing the x/y-relation changes the aspect.</li>
<li>svg does not support a background color (still in these svgs there is one defined as per inkscape-extension), so there is one 100% layer in the background filled with the background color. just remove as desired. i guess it would have been a good idea to support a background color, and in case of an opacity of 0 it still could be completely ignored if there is some sort of background defined below the svg, while otherwise this would provide a background - but it seems like the w3c-people do not share this opinion.</li>
</ul>
</p>
<hr>
<h1>µc³</h1>
<ul>
<li>gradient=blur is a gaussian blur filter. svg filters are supported e.g. by firefox 3, but not by firefox 2 and earlier. they also aren't supported by the inkscape (0.44.1) used here to convert svg to png, so the png will be without gradient. newer inkscapes (0.46) do support svg filters.</li>
<li>the font for the text used is utopia. it is in the gsfonts-other package of etch, but not in lenny.</li>
</ul>
<form action="">
<input type="hidden" name="logo" value="muc3">
<table>
<tr><th>colorscheme:</th><td><select name="scheme">
<option value="" selected>yellow on black</option>
<option value="bow">black on white</option>
<option value="wob">white on black</option>
<option value="gow">grey on white</option>
<option value="gob">grey on black</option>
</select></td></tr>
<tr><th>gradient:</th><td><select name="gradient">
<option value="blur" selected>blur</option>
<option value="linear">linear</option>
<option value="exp">exp</option>
<option value="fixed">fixed</option>
</select></td></tr>
<tr><th>pagecolor:</th><td><input type="text" name="pagecolor" value=""></td></tr>
<tr><th>chaosknotencolor:</th><td><input type="text" name="chaosknotencolor" value=""></td></tr>
<tr><th>chaosknotenopacity:</th><td><input type="text" name="chaosknotenopacity" value=""></td></tr>
<tr><th>rhombuscolor:</th><td><input type="text" name="rhombuscolor" value=""></td></tr>
<tr><th>textcolor:</th><td><input type="text" name="textcolor" value=""></td></tr>
<tr><th>format:</th><td><select name="format">
<option value="svg" selected>svg</option>
<option value="png">png</option>
</select> (for png: width: <input type="text" name="width" value="800">, height: <input type="text" name="height" value="600">)</td></tr>
</table>
<input type="submit" name="action" value="print">
</form>
<hr>
<h1>Münchner Eris</h1>
<ul>
<li>the font for the text used is utopia (see µc³)</li>
<li>currently scaling might do strange things with the font</li>
</ul>
<form action="">
<input type="hidden" name="logo" value="muenchnereris">
<table>
<tr><th>pagecolor:</th><td><input type="text" name="pagecolor" value=""></td></tr>
<tr><th>textcolor:</th><td><input type="text" name="textcolor" value=""></td></tr>
<tr><th>x scaling:</th><td><input type="text" name="xscale" value=""></td></tr>
<tr><th>y scaling:</th><td><input type="text" name="yscale" value=""></td></tr>
<tr><th>text:</th><td><input type="checkbox" name="text" value="1" checked></td></tr>
<tr><th>ornament:</th><td><select name="ornament">
<option value="µc³" selected>µc³</option>
<option value="chaosknoten">chaosknoten</option>
<option value="chaoslet">chaoslet</option>
<option value="pesthoernchen">pesthörnchen</option>
<option value="pentagon">pentagon</option>
<option value="hackeroid">hackeroid</option>
</select> (the selected is displayed, the others are in disabled layers)</td></tr>
<tr><th>format:</th><td><select name="format">
<option value="svg" selected>svg</option>
<option value="png">png</option>
</select> (for png: width: <input type="text" name="width" value="411">, height: <input type="text" name="height" value="600">)</td></tr>
</table>
<input type="submit" name="action" value="print">
</form>
<hr>
<h1>RHF</h1>
<p>
<ul>
<li>there seem to exist different ideas on mask elements between ff(3) and inkscape, which effectively makes the star disappear in ff. but it is actually there, as you can see after png conversion (or when loading the svg into inkscape).</li>
<li>the most-'original' picture of this logo (an original logo picture from 18c3) btw had an x-scaling of 1.14 (still, the default here is without any scaling).</li>
</ul>
</p>
<form action="">
<input type="hidden" name="logo" value="rhf">
<table>
<tr><th>pagecolor:</th><td><input type="text" name="pagecolor" value=""></td></tr>
<tr><th>textcolor:</th><td><input type="text" name="textcolor" value=""></td></tr>
<tr><th>x scaling:</th><td><input type="text" name="xscale" value=""></td></tr>
<tr><th>y scaling:</th><td><input type="text" name="yscale" value=""></td></tr>
<tr><th>format:</th><td><select name="format">
<option value="svg" selected>svg</option>
<option value="png">png</option>
</select> (for png: width: <input type="text" name="width" value="800">, height: <input type="text" name="height" value="800">)</td></tr>
</table>
<input type="submit" name="action" value="print">
</form>
<hr>
<h1>Pesthörnchen</h1>
<form action="">
<input type="hidden" name="logo" value="pesthoernchen">
<table>
<tr><th>pagecolor:</th><td><input type="text" name="pagecolor" value=""></td></tr>
<tr><th>textcolor:</th><td><input type="text" name="textcolor" value=""></td></tr>
<!-- tr><th>x scaling:</th><td><input type="text" name="xscale" value=""></td></tr>
<tr><th>y scaling:</th><td><input type="text" name="yscale" value=""></td></tr -->
<tr><th>format:</th><td><select name="format">
<option value="svg" selected>svg</option>
<option value="png">png</option>
</select> (for png: width: <input type="text" name="width" value="800">, height: <input type="text" name="height" value="800">)</td></tr>
</table>
<input type="submit" name="action" value="print">
</form>
<hr>
<h1>Chaosknoten</h1>
<p>
<ul>
<li>ff has a problem with this svg. didn't work out why, yet. conversion to png and loading in inkscape works, though...</li>
</ul>
</p>
<form action="">
<input type="hidden" name="logo" value="chaosknoten">
<table>
<tr><th>pagecolor:</th><td><input type="text" name="pagecolor" value=""></td></tr>
<tr><th>textcolor:</th><td><input type="text" name="textcolor" value=""></td></tr>
<tr><th>format:</th><td><select name="format">
<option value="svg" selected>svg</option>
<option value="png">png</option>
</select> (for png: width: <input type="text" name="width" value="800">, height: <input type="text" name="height" value="600">)</td></tr>
</table>
<input type="submit" name="action" value="print">
</form>
<hr>
<h1>Fairydust</h1>
<p>
<ul>
<li>ff has a problem with this svg. didn't work out why, yet. conversion to png and loading in inkscape works, though...</li>
</ul>
</p>
<form action="">
<input type="hidden" name="logo" value="fairydust">
<table>
<tr><th>colorscheme:</th><td><select name="scheme">
<option value="" selected>yellowish colors</option>
<option value="bow">black on white</option>
</select></td></tr>
<tr><th>pagecolor:</th><td><input type="text" name="pagecolor" value=""></td></tr>
<tr><th>textcolor:</th><td><input type="text" name="textcolor" value=""></td></tr>
<tr><th>format:</th><td><select name="format">
<option value="svg" selected>svg</option>
<option value="png">png</option>
</select> (for png: width: <input type="text" name="width" value="800">, height: <input type="text" name="height" value="800">)</td></tr>
</table>
<input type="submit" name="action" value="print">
</form>
</body>
</html>
EOF
		exit(0);
	};
} else {
	if ( $opt{"format"} eq "png" ) {
		open(my $fh,">/tmp/".basename($0).".$$.svg");
		print {$fh} svg();
		close($fh);
		system("inkscape -e /tmp/".basename($0).".$$.png -w $opt{width} -h $opt{height} /tmp/".basename($0).".$$.svg >/dev/null 2>&1");
		open(my $fh,"</tmp/".basename($0).".$$.png");
		print join("",<$fh>);
		close($fh);
		unlink("/tmp/".basename($0).".$$.svg");
		unlink("/tmp/".basename($0).".$$.png");
	} else {
		print svg();
	};
};

sub svg() {
	if ( $opt{"logo"} eq "muc3" ) {
		return(svg_muc3());
	} elsif ( $opt{"logo"} eq "muenchnereris" ) {
		return(svg_muenchnereris());
	} elsif ( $opt{"logo"} eq "rhf" ) {
		return(svg_rhf());
	} elsif ( $opt{"logo"} eq "fairydust" ) {
		return(svg_fairydust());
	} elsif ( $opt{"logo"} eq "pesthoernchen" ) {
		return(svg_pesthoernchen());
	} elsif ( $opt{"logo"} eq "chaosknoten" ) {
		return(svg_chaosknoten());
	};
};

sub svg_muc3() {
	my $output;
#   width="655.055"
#   height="470.179"
#   inkscape:version="0.44.1"
	$output .= <<EOF;
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://web.resource.org/cc/"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="1052.3622"
   height="744.09448"
   id="svg2217"
   sodipodi:version="0.32"
   inkscape:version="1.0"
   sodipodi:docname="muc3.svg"
   sodipodi:docbase="/what/a/stupid/idea/to/store/the/path/location/of/a/document/in/the/file/itself">
  <metadata
     id="metadata2236">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <defs
     id="defs2234">
    <linearGradient
       id="linearGradient6518">
      <stop
         style="stop-color:yellow;stop-opacity:1;"
         offset="0"
         id="stop6520" />
      <stop
         id="stop6528"
         offset="0.99000001"
         style="stop-color:yellow;stop-opacity:1;" />
      <stop
         style="stop-color:yellow;stop-opacity:0;"
         offset="1"
         id="stop6522" />
    </linearGradient>
    <linearGradient
       id="linearGradient6506">
      <stop
         style="stop-color:yellow;stop-opacity:1;"
         offset="0"
         id="stop6508" />
      <stop
         id="stop6514"
         offset="1"
         style="stop-color:yellow;stop-opacity:1;" />
      <stop
         style="stop-color:yellow;stop-opacity:0;"
         offset="1"
         id="stop6510" />
    </linearGradient>
EOF
	if ( $opt{gradient} eq "blur" ) {
		$output .= <<EOF;
    <filter
       inkscape:collect="always"
       x="-0.10392075"
       width="1.2078415"
       y="-0.096406882"
       height="1.1928138"
       id="filter3494">
      <feGaussianBlur
         inkscape:collect="always"
         stdDeviation="23.264288"
         id="feGaussianBlur3496" />
    </filter>
EOF
	};
	$output .= <<EOF;
  </defs>
  <sodipodi:namedview
     inkscape:window-height="620"
     inkscape:window-width="908"
     inkscape:pageshadow="2"
     inkscape:pageopacity="1"
     guidetolerance="10.0"
     gridtolerance="10.0"
     objecttolerance="10.0"
     borderopacity="1.0"
     bordercolor="$bordercolor"
     pagecolor="$pagecolor"
     id="base"
     showborder="false"
     inkscape:showpageshadow="true"
     inkscape:zoom="0.44344815"
     inkscape:cx="477.08598"
     inkscape:cy="236.54262"
     inkscape:window-x="392"
     inkscape:window-y="479"
     inkscape:current-layer="layer2"
     showguides="false" />
  <g
     inkscape:groupmode="layer"
     id="layer0"
     style="display:inline">
    <rect
       style="opacity:1;fill:$pagecolor;fill-opacity:1;fill-rule:evenodd;stroke:$pagecolor;stroke-width:6;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="rect2543"
       width="100pc"
       height="100pc"
       x="0"
       y="0" />
  </g>
  <g
     inkscape:groupmode="layer"
     id="layer1"
     inkscape:label="chaosknoten"
     style="display:inline"
     $transform>
    <g
       id="g2219"
       style="fill:$chaosknotencolor;opacity:$chaosknotenopacity">
      <path
         style="stroke:none;"
         d="M 294.407,7.95792 C 300.62,8.98492 313.524,28.3799 311.961,63.9999 C 307.661,66.2869 302.672,64.9449 299.414,64.8939 C 289.23,62.2119 298.736,35.3389 284.461,25.3479 C 263.79,10.8809 119.447,14.4069 45.5808,21.1209 C 13.592,24.0289 17.478,87.0639 16.8569,120.43 C 16.34,148.198 17.3017,178.549 28.2758,209.36 C 37.7226,235.884 72.5747,226.769 104.247,227.931 C 161.225,227.931 265.228,229.814 277.777,224.806 C 286.869,221.177 290.573,207.834 292.486,199.231 C 295.837,184.162 292.318,173.624 304.308,173.907 C 310.621,174.056 311.863,179.764 310.9,190.679 C 309.899,202.025 306.507,217.12 301.772,234.684 C 298.351,247.372 274.76,244.813 259.144,244.813 C 180.218,242.704 100.45,245.236 24.0554,243.125 C 1.9155,242.514 1.46946,137.911 0.285625,118.923 C -1.10525,96.6069 2.51438,7.01993 21.3615,6.01993 C 35.3674,5.27692 113.628,0.0309143 159.959,0.0189209 C 205.016,0.00692749 252.988,1.11093 294.407,7.95792"
         id="path2221" />
      <path
         style="stroke:none;"
         d="M 223.69,24.0759 C 229.177,39.6919 215.671,64.1719 235.93,72.6129 C 309.368,85.2749 395.047,57.8409 457.512,96.2479 C 474.394,112.708 487.056,131.701 495.075,151.96 L 495.075,142.675 C 485.79,116.929 466.797,94.9819 448.648,72.6129 C 453.713,65.8599 459.622,73.8789 464.686,75.9889 C 483.257,99.2019 502.249,122.838 509.425,150.694 C 510.69,152.382 513.223,155.759 515.333,152.804 L 518.288,149.85 C 511.957,119.884 492.964,95.4039 476.926,69.6579 C 484.101,65.0149 491.276,73.0349 497.185,77.6769 C 509.425,97.9359 522.931,118.195 527.573,141.83 C 530.949,144.362 535.17,139.72 536.858,136.765 C 534.326,118.194 527.994,101.734 520.397,86.1179 C 521.663,84.0079 521.663,81.0529 524.618,81.0529 C 542.767,90.7599 542.345,111.864 548.675,128.324 C 554.584,127.902 557.538,109.331 565.135,120.305 C 567.667,127.058 555.006,137.61 568.09,138.454 C 561.759,168.842 528.416,192.478 499.294,199.231 C 484.1,202.607 463.841,207.249 452.445,195.433 C 454.555,189.946 462.152,189.102 467.639,188.258 C 501.404,186.992 533.481,174.752 553.74,147.74 L 552.896,146.896 C 520.819,168.421 481.146,189.102 441.472,173.064 C 438.096,172.22 436.407,167.577 438.518,165.045 C 439.362,162.513 436.83,161.247 435.563,160.824 C 368.455,163.778 297.967,154.5 232.97,165.051 C 225.84,166.209 225.036,172.797 223.686,178.133 C 220.272,191.644 228.896,210.78 220.862,217.979 C 220.862,217.979 214.926,219.72 210.606,217.802 C 209.595,212.193 206.379,180.658 213.554,163.776 C 222.631,142.419 303.508,149.623 326.888,149.15 C 369.61,148.287 419.526,146.896 459.622,149.851 C 448.226,138.455 430.5,138.033 413.195,138.455 C 358.327,137.611 272.591,137.896 237.819,135.989 C 186.388,133.167 167.977,184.882 135.478,218.647 L 120.284,218.647 C 140.543,190.37 162.381,158.125 190.346,133.391 C 194.855,129.403 197.991,128.776 205.54,126.639 C 226.565,120.686 430.499,127.483 430.499,127.483 C 439.784,129.593 449.914,130.859 458.777,134.657 C 453.712,121.573 437.252,118.197 424.168,116.51 C 351.151,114.4 277.291,116.088 205.54,111.445 C 186.125,105.536 175.996,81.4789 160.801,66.7059 L 128.302,25.3439 L 144.762,26.1879 C 165.865,50.6669 180.337,80.6939 207.649,100.048 C 213.669,104.314 342.251,103.075 410.233,103.002 C 421.193,102.99 444.003,110.177 458.775,118.197 C 461.307,114.821 457.087,111.866 454.554,109.334 C 423.743,79.7899 360.192,88.9909 337.226,89.0699 C 296.941,89.2099 248.993,97.5919 215.667,76.8349 C 207.526,71.7639 208.915,40.9599 212.714,24.0769 L 223.687,24.0769"
         id="path2223" />
      <path
         style="stroke:none;"
         d="M 575.267,153.649 C 568.092,184.038 545.723,211.471 517.444,226.666 C 499.717,230.465 476.926,242.282 462.576,224.556 C 472.284,215.693 490.01,221.602 501.406,214.426 C 530.95,205.985 555.264,179.952 570.202,153.649 C 572.112,152.328 573.397,150.826 575.267,153.649"
         id="path2225" />
      <path
         style="stroke:none;"
         d="M 584.142,179.84 C 579.077,206.008 566.415,233.442 539.403,246.526 C 527.585,252.013 509.015,258.344 498.041,248.636 L 498.041,244.415 C 539.825,246.103 560.928,202.209 577.811,172.665 C 582.454,172.243 582.876,176.463 584.142,179.84"
         id="path2227" />
      <path
         style="stroke:none;"
         d="M 611.567,280.265 C 631.446,284.489 650.816,264.65 655.037,290.396 C 638.154,299.259 615.363,296.727 597.637,291.662 C 593.838,299.259 599.325,307.7 597.637,316.986 C 595.105,341.888 585.819,365.523 563.872,380.717 C 557.515,384.017 556.195,385.964 552.441,386.626 C 553.579,380.924 553.968,376.273 554.941,372.727 C 559.287,369.807 578.444,357.507 579.066,341.043 C 588.773,306.434 578.222,272.247 555.008,246.923 L 570.202,232.995 C 579.065,250.721 589.098,275.49 611.566,280.264"
         id="path2229" />
      <path
         style="stroke:none;"
         d="M 542.769,257.054 C 567.248,304.325 544.457,359.615 538.548,408.152 C 541.08,426.301 543.613,444.871 558.807,457.533 C 557.119,461.754 559.651,472.305 552.898,469.773 C 531.373,458.377 524.198,435.586 524.62,411.951 C 523.776,370.167 546.145,336.824 540.658,294.618 L 536.86,286.6 C 519.555,305.17 500.141,328.384 501.407,357.505 L 490.011,359.615 C 477.349,319.097 521.666,295.872 527.575,259.575 C 527.575,259.575 537.282,255.789 542.769,257.054"
         id="path2231" />
      <path
         style="stroke:none;"
         d="M 488.47856,375 C 456.38563,375 469.68577,392 471.508,392 C 518.88908,392 518.88908,392 518.88908,385 C 518.88908,375 523.88908,375 506.86334,375 C 498.48597,375 498.69368,375 488.47856,375 L 488.47856,375 L 488.47856,375 z "
         id="path1928" />
    </g>
  </g>
  <g
     inkscape:groupmode="layer"
     id="layer2"
     inkscape:label="rhombus"
     style="fill:$rhombuscolor;stroke:$rhombuscolor;opacity:1;display:inline"
     $transform>
    <g
       id="g2993"
       transform="matrix(0.998795,4.906767e-2,-4.906767e-2,0.998795,-980.8202,11.83299)">
EOF
	# the above is turned -2.8125 deg clockwise, which looks better.
	#       transform="translate(-988.6302,76.53911)">
	#EOF

	if ( $opt{gradient} eq "blur" ) {
		my $filterx = $x-($iter*$outset)/2;
		my $filtery = $y-($iter*$outset)/2;
		my $filterw = $w+($iter*$outset);
		my $filterh = $h+($iter*$outset);
		$output .= <<EOF;
      <rect
         style="opacity:$o;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline;filter:url(#filter3494)"
         transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
         y="$filtery"
         x="$filterx"
         height="$filterh"
         width="$filterw"
         id="rect$id"
         rx="$r"
         ry="$r" />
EOF
	} else {
		for ( my $i = 0; $i <= $iter; $i++ ) {
			$output .= <<EOF;
      <rect
         style="opacity:$o;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
         transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
         y="$y"
         x="$x"
         height="$h"
         width="$w"
         id="rect$id"
         rx="$r"
         ry="$r" />
EOF
			if ( $opt{gradient} eq "fixed" ) {	# fixed
				$o = .1;			# fixed opacity for every layer
			} else {
				my $ostep = 1/($iter+1);	# for linear
				my $exp = 1.2;			# for exp: the exponent
				my $div = 1;			# for exp: the divisor of iteration
				my $osoll;			# for exp
				$o = 0;				# in the beginning, there is no opacity...
				my $osum = 0;			# we need to use the 'sum' of the previous opacities, i.e. the effective opacity below...
				for ( my $n = 0; $n < ($iter-$i); $n++ ) {
					if ( $opt{gradient} eq "exp" ) {	# exp
#						$osoll = ((($n/$div)**(1/$exp))/(($iter/$div)**(1/$exp)));
						$osoll = ($n*$ostep)*((($n/$div)**(1/$exp))/(($iter/$div)**(1/$exp))); # linear*exp
						$o =  1-((1-$osoll)/(1-$osum));
					} else {				# linear
						$o = $ostep/(1-$osum);
					};

					$osum = 1-(1-$o)*(1-$osum);
					#print "$n: opacity:$o sum:$osum step:$ostep soll:$osoll\n";
				};
			};
			$w = $w+$outset;	# increase width
			$h = $h+$outset;	# increase height
			$x = $x-($outset/2);	# decrease x
			$y = $y-($outset/2);	# decrease y
			$id++;			# next id
		};
	};

	$output .= <<EOF;
    </g>
  </g>
  <g
     inkscape:groupmode="layer"
     id="layer3"
     inkscape:label="µc³"
     style="display:inline;fill:$textcolor;"
     $transform>
    <g
       transform="translate(12.48528,8.72792)"
       id="g1896">
      <text
         xml:space="preserve"
         style="font-size:224px;font-style:italic;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;opacity:1;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Utopia"
         x="295.19415"
         y="247"
         id="text1949"
         sodipodi:linespacing="125%"><tspan
           sodipodi:role="line"
           id="tspan1951"
           x="295.19415"
           y="247">c</tspan></text>
      <text
         xml:space="preserve"
         style="font-size:224px;font-style:italic;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Utopia"
         x="170"
         y="247"
         id="text1888"
         sodipodi:linespacing="125%"><tspan
           sodipodi:role="line"
           id="tspan1890"
           x="170"
           y="247">µ</tspan></text>
      <text
         xml:space="preserve"
         style="font-size:224px;font-style:italic;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Utopia"
         x="394"
         y="247"
         id="text1892"
         sodipodi:linespacing="125%"><tspan
           sodipodi:role="line"
           id="tspan1894"
           x="394"
           y="247">³</tspan></text>
    </g>
  </g>
</svg>
EOF
	return($output);
};

sub svg_rhf() {
	my $output;

	$output .= <<EOF;
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!-- Created with Inkscape (http://www.inkscape.org/) -->
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   width="500"
   height="500"
   id="svg2"
   sodipodi:version="0.32"
   inkscape:version="0.46"
   sodipodi:docbase="/what/a/stupid/idea/to/save/pathnames/in/imagefiles"
   sodipodi:docname="18c3x.svg"
   version="1.0"
   style="display:inline"
   inkscape:output_extension="org.inkscape.output.svg.inkscape">
  <defs
     id="defs4">
    <inkscape:perspective
       sodipodi:type="inkscape:persp3d"
       inkscape:vp_x="0 : 526.18109 : 1"
       inkscape:vp_y="0 : 1000 : 0"
       inkscape:vp_z="744.09448 : 526.18109 : 1"
       inkscape:persp3d-origin="372.04724 : 350.78739 : 1"
       id="perspective105" />
    <mask
       id="keyboard-mask"
       maskUnits="userSpaceOnUse">
      <g
         id="keyboard-mask-layer">
        <rect
           style="opacity:1;fill:#ffffff;fill-opacity:1;fill-rule:evenodd;stroke:#ffffff;stroke-width:6;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="keyboard-mask-rect-all"
           width="100pc"
           height="100pc"
           x="0"
           y="0" />
        <rect
           style="opacity:1;fill:#000000;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="keyboard-mask-rect-alpha"
           width="3.35"
           height="1.33"
           x="216.88"
           y="279.4"
           rx="0"
           ry="0" />
        <rect
           style="opacity:1;fill:#000000;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-width:0;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
           id="keyboard-mask-rect-num"
           width="0.85"
           height="1.03"
           x="220.15"
           y="279.718"
           rx="0"
           ry="0" />
      </g>
    </mask>
  </defs>
  <sodipodi:namedview
     id="base"
     pagecolor="$pagecolor"
     bordercolor="#666666"
     borderopacity="1.0"
     inkscape:pageopacity="0"
     inkscape:pageshadow="2"
     inkscape:zoom="1.8101934"
     inkscape:cx="196.75773"
     inkscape:cy="136.12275"
     inkscape:document-units="px"
     inkscape:current-layer="layer1"
     inkscape:window-width="908"
     inkscape:window-height="982"
     inkscape:window-x="0"
     inkscape:window-y="0"
     showgrid="true"
     width="500px"
     height="500px">
    <inkscape:grid
       type="xygrid"
       id="grid2446" />
  </sodipodi:namedview>
  <metadata
     id="metadata7">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
    </rdf:RDF>
  </metadata>
EOF

	# background
	$output .= <<EOF;
  <g
     inkscape:groupmode="layer"
     id="background-layer"
     style="display:inline">
    <rect
       style="opacity:1;fill:$pagecolor;fill-opacity:1;fill-rule:evenodd;stroke:$pagecolor;stroke-width:6;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="background-rect"
       width="100pc"
       height="100pc"
       x="0"
       y="0" />
  </g>
EOF

	$output .= <<EOF;
  <g
     inkscape:label="Layer 1"
     inkscape:groupmode="layer"
     style="stroke:$textcolor;fill:$textcolor;display:inline"
EOF
	if ($xscale != 1 || $yscale != 1 ) {
		my $xmove = ($xscale-1)/2*(-320);
		my $ymove = ($yscale-1)/2*(-320);
		$output .= <<EOF;
     transform="scale($xscale,$yscale) translate($xmove,$ymove)"
EOF
     	};
	$output .= <<EOF;
     id="layer1">
EOF

	# star
	$output .= <<EOF;
    <path
       sodipodi:type="star"
       style="opacity:1;fill:none;fill-opacity:1;fill-rule:evenodd;stroke-width:0.09520076;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="star-path"
       sodipodi:sides="5"
       sodipodi:cx="218.95056"
       sodipodi:cy="279.9743"
       sodipodi:r1="2.2561212"
       sodipodi:r2="0.86693585"
       sodipodi:arg1="-0.31290123"
       sodipodi:arg2="0.3154173"
       inkscape:flatsided="false"
       inkscape:rounded="0"
       inkscape:randomized="0"
       d="M 221.09714,279.27982 L 219.77473,280.24324 L 220.27438,281.80121 L 218.94947,280.84124 L 217.62215,281.79787 L 218.12572,280.24116 L 216.80574,279.27443 L 218.44187,279.2723 L 218.9534,277.71818 L 219.46102,279.27358 L 221.09714,279.27982 z"
       transform="matrix(63.0247,0,0,63.0247,-13548.58,-17401.31)"
       mask="url(#keyboard-mask)" />
EOF

	sub sprintkey($$$$$$) {
		my $key		= shift;
		my $x		= shift;
		my $y		= shift;
		my $stroke	= shift;
		my $w		= shift;
		my $h		= shift;

		my $output = <<EOF;
    <rect
       style="opacity:1;fill-opacity:1;fill-rule:evenodd;stroke-width:$stroke;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
       id="keyboard-rect-$key"
       width="$w"
       height="$h"
       x="$x"
       y="$y"
       rx="0"
       ry="0" />
EOF
		return($output);
	};

	my $key;
	my %keyboard;		# position of the keyboard(-start) i.e. x/y of upper left corner
	$keyboard{x}	= 127;
	$keyboard{y}	= 214;
	my %key;		# dimensions (and spacing) of a standard key
	$key{stroke}	= 2.5;
	$key{w}		= 7.5;
	$key{h}		= 7.5;
	$key{xstep}	= $key{w}+$key{stroke}+1;
	$key{ystep}	= $key{h}+$key{stroke}+1;
	my %block;		# extra spacing for blocks (e.g. f-key-row % alpha, cursor-block % alpha or cursor-block % num-block)
	$block{xstep}	= 4;
	$block{ystep}	= 9;

	# row 1
	my $x = $keyboard{x};
	my $y = $keyboard{y};

	$key = "ESC";
	$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
	$x += $key{xstep};

	$x += $key{xstep};
	foreach my $key ( "F1", "F2", "F3", "F4" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$x += $key{xstep}/2;
	foreach my $key ( "F5", "F6", "F7", "F8" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$x += $key{xstep}/2;
	foreach my $key ( "F9", "F10", "F11", "F12" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$x += $block{xstep};
	foreach my $key ( "PRINT", "SCROLL", "PAUSE" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	# row 2
	$x = $keyboard{x};
	$y += $key{ystep}+$block{ystep};

	foreach my $key ( "^", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$key = "BACKSPACE";
	$w = 18.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 22;

	$x += $block{xstep};
	foreach my $key ( "INSERT", "HOME", "PGUP" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$x += $block{xstep};
	foreach my $key ( "NUM-LOCK", "NUM-/", "NUM-*", "NUM--" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	# row 3
	$x = $keyboard{x};
	$y += $key{ystep};

	$key = "TAB";
	$w = 13.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 17;

	foreach my $key ( "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$key = "\\";
	$w = 12.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 16;

	$x += $block{xstep};
	foreach my $key ( "DELETE", "END", "PGDOWN" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$x += $block{xstep};
	foreach my $key ( "NUM-7", "NUM-8", "NUM-9" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$key = "NUM-+";
	$h = $key{h}+$key{ystep};
	$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$h);

	# row 4
	$x = $keyboard{x};
	$y += $key{ystep};

	$key = "CAPS";
	$w = 16.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 20;

	foreach my $key ( "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$key = "ENTER";
	$w = 20.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 24;

	$x += $block{xstep};
	$x += 3*$key{xstep};
	$x += $block{xstep};

	foreach my $key ( "NUM-4", "NUM-5", "NUM-6" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	# row 4
	$x = $keyboard{x};
	$y += $key{ystep};

	$key = "SHIFT-L";
	$w = 22.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 26;

	foreach my $key ( "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$key = "SHIFT-R";
	$w = 25.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 29;

	$x += $block{xstep};
	$x += $key{xstep};

	$key = "CURSOR-UP";
	$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
	$x += $key{xstep};

	$x += $key{xstep};
	$x += $block{xstep};

	foreach my $key ( "NUM-1", "NUM-2", "NUM-3" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$key = "NUM-ENTER";
	$h = $key{h}+$key{ystep};
	$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$h);

	# row 5
	$x = $keyboard{x};
	$y += $key{ystep};

	$key = "CTRL-L";
	$w = 13.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 17;

	$x += $key{xstep};

	$key = "ALT-L";
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 17;

	$key = "SPACE";
	$w = 73.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 77;

	$key = "ALT-R";
	$w = 13.5;
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	#$x += 17;

	$key = "CTRL-R";
	$x += 15+$key{xstep};
	#
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	#$x += 17;

	$x += 21;
	#$x += $block{xstep};

	foreach my $key ( "CURSOR-LEFT", "CURSOR-DOWN", "CURSOR-RIGHT" ) {
		$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});
		$x += $key{xstep};
	};

	$x += $block{xstep};

	$key = "NUM-0";
	$w = $key{w}+$key{xstep};
	$output .= sprintkey($key,$x,$y,$key{stroke},$w,$key{h});
	$x += 2*$key{xstep};

	$key = "NUM-.";
	$output .= sprintkey($key,$x,$y,$key{stroke},$key{w},$key{h});

	$output .= <<EOF;
  </g>
</svg>
EOF

	return($output);
};

sub svg_fairydust() {
	my $output;
	$output .= <<EOF;
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns:xlink="http://www.w3.org/1999/xlink" height="842" width="595" viewBox="0 0 595 842">
  <defs>
    <style type="text/css"><![CDATA[
.p0 { stroke:none;fill:$textcolor; }
.p1 { stroke:none;fill:$lowcolor; }
.p2 { stroke:none;fill:$brightcolor; }
]]></style>
  </defs>
  <g transform="matrix(1 0 0 -1 0 842)" id="page-1" xml:space="preserve">
<path d="M501.9150 -662.8540C491.1348 -660.0742 484.2187 -659.5361 480.0215 -659.7998C478.6816 -659.8843 477.6201 -660.0454 476.7959 -660.2236C462.8271 -669.5771 417.4297 -694.8955 356.4746 -677.4170C330.9512 -670.0981 307.9951 -659.3159 290.9878 -650.1289C287.8354 -648.4258 284.8892 -646.7783 282.1675 -645.2173C282.1675 -645.2173 279.6309 -646.1860 279.6309 -646.1860C279.5571 -646.2158 267.1851 -651.3120 237.1958 -650.2598C229.2949 -649.9829 218.5742 -647.2612 209.8643 -644.6260C201.1372 -641.9858 194.2480 -639.3682 194.1641 -639.2671C194.1470 -639.2471 193.5439 -638.5220 192.9941 -637.3462C192.4438 -636.1719 191.9331 -634.5181 192.1421 -632.6572C192.2207 -631.9541 192.2939 -631.3613 192.3608 -630.8486C171.9126 -623.3506 155.7310 -615.4932 155.7310 -615.4932C155.7310 -615.4932 155.4619 -614.1108 155.2661 -612.8379C155.0791 -611.6182 154.8882 -610.1133 155.0132 -609.4629C155.5298 -606.7690 159.6758 -602.7402 162.8643 -600.2720C164.9341 -598.6690 168.5230 -597.0269 171.5439 -595.7969C174.5859 -594.5591 177.2852 -593.6592 177.2852 -593.6592C177.2852 -593.6592 182.2261 -595.3662 189.9819 -597.0928C197.7471 -598.8232 208.4922 -600.6289 220.4131 -600.9341C231.7998 -601.2261 238.8848 -599.9512 243.1060 -598.6201C245.2158 -597.9551 246.6099 -597.2759 247.4668 -596.7720C248.2861 -596.2900 249.8481 -595.5034 249.8623 -595.4321C250.2017 -593.6987 250.6260 -591.9336 251.1401 -590.1411C253.7837 -580.9233 258.0601 -573.5166 263.0679 -568.3027C263.0679 -568.3027 263.2085 -568.1509 263.0791 -567.4619C263.0791 -567.4619 262.6240 -563.2061 260.4521 -557.6460C258.2710 -552.0649 254.3521 -545.0278 247.3921 -539.1690C241.1519 -533.9150 233.2939 -529.7881 226.9790 -526.9697C220.6772 -524.1582 215.8501 -522.6338 215.5098 -522.3081C215.3701 -522.1479 215.1899 -521.9121 215.0210 -521.6001C214.6821 -520.9722 214.3911 -520.0449 214.5527 -518.7739C214.5527 -518.7739 221.7148 -500.9883 221.7148 -500.9883C225.9761 -500.7617 231.8872 -500.6519 252.0112 -506.4228C272.1660 -512.2021 285.5288 -519.5518 299.9043 -528.8018C309.9141 -535.2441 318.1397 -543.2529 323.8613 -549.6460C329.5918 -556.0488 332.8506 -560.8892 332.9541 -561.2051C332.9619 -561.2363 332.9697 -561.2788 332.9775 -561.3144C349.0635 -562.9038 367.5508 -565.8462 386.3535 -571.2383C423.2480 -581.8169 447.0234 -603.1108 461.5713 -621.7578C471.1768 -634.0698 476.7607 -645.2270 479.4492 -651.3970C480.0440 -651.9658 480.8291 -652.6328 481.8643 -653.3740C485.2842 -655.8218 491.4355 -659.0850 502.0615 -662.3579C502.0615 -662.3579 501.9150 -662.8540 501.9150 -662.8540Z" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p0"/>
<path d="M238.4409 -551.7178C227.8023 -544.3525 220.0010 -546.9497 216.5083 -553.5757C213.1314 -559.9824 192.4770 -552.7505 182.6269 -550.1538C172.7759 -547.5557 71.6382 -524.8296 71.6382 -524.8296C71.6382 -524.8296 168.6929 -558.9858 182.5151 -564.7988C197.2974 -571.0156 203.5161 -575.4458 207.7573 -581.8594C212.8623 -589.5796 220.5972 -594.0508 229.7261 -596.0635C235.7993 -597.4028 241.5933 -594.2827 244.7910 -592.0435C244.9429 -590.7485 245.3257 -589.4424 245.5566 -588.1318C246.1147 -584.9648 246.9893 -574.4458 252.9082 -567.2427C252.9082 -567.2427 248.4531 -558.6484 238.4409 -551.7178Z" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p0"/>
<path d="M434.1875 -670.8921C434.1875 -670.8921 437.0225 -666.5176 437.6719 -662.0088C437.7139 -661.7173 438.5889 -657.5088 436.9736 -651.4985C436.2510 -648.8096 434.9639 -646.6387 434.9639 -646.6387C434.9639 -646.6387 437.8809 -648.1338 440.7412 -652.5913C442.0147 -654.5752 443.2217 -657.9058 443.4639 -658.2432C443.7139 -658.5918 457.0479 -658.4253 458.3809 -658.3838C459.3818 -658.3525 473.1455 -657.8208 478.8018 -656.4932C479.4883 -656.3320 473.7549 -661.8213 463.3379 -665.4253C455.4170 -668.1655 448.7031 -669.6924 434.1875 -670.8921Z" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p1"/>
<path d="M206.7602 -629.4473C187.4712 -623.9160 157.2773 -612.3721 157.2773 -612.3721C157.2773 -612.3721 184.4981 -628.0894 212.2583 -636.0493C242.2544 -644.6499 261.3276 -645.8013 280.8237 -643.9741C300.1602 -642.1611 310.7852 -637.7529 312.7773 -630.8081C314.8105 -623.7183 300.1992 -608.0933 270.9956 -598.8701C261.7632 -595.9541 252.1421 -596.1382 252.1421 -596.1382C252.1421 -596.1382 258.2563 -597.0840 268.1597 -600.2021C277.0874 -603.0132 292.7192 -611.2100 297.7270 -615.3179C299.7305 -616.9609 302.2461 -619.1279 304.1621 -621.2012C306.1660 -623.3731 307.2383 -625.1641 306.9551 -626.1528C304.7441 -633.8608 250.0366 -641.8560 206.7602 -629.4473" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p1"/>
<path fill-rule="evenodd" d="M333.2617 -561.3682C333.2617 -561.3682 330.9043 -558.2261 330.9043 -558.2261C328.8906 -557.9180 326.0059 -557.6191 321.4434 -557.4741C316.8750 -557.3291 311.0254 -557.0649 303.5527 -557.3691C286.2729 -558.0713 271.0327 -564.6660 271.0327 -564.6660C271.0327 -564.6660 275.3667 -563.3643 282.1870 -562.1382C289.0151 -560.9111 298.3340 -559.7822 308.2969 -560.0689C324.9277 -560.5478 333.2617 -561.3682 333.2617 -561.3682" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p1"/>
<path d="M253.0679 -567.4111C251.6284 -565.2173 248.8550 -562.1690 243.5435 -558.9819C235.5718 -554.1992 230.8550 -556.2202 229.0352 -562.3530C226.5972 -570.5742 212.6602 -563.9150 201.2925 -560.8608C183.1001 -555.9741 122.0913 -539.1138 122.0913 -539.1138C122.0913 -539.1138 183.8403 -559.2231 201.7861 -567.6958C214.9165 -573.8950 209.2270 -586.8814 218.3574 -580.5029C221.7632 -578.1240 231.5757 -576.3643 237.0737 -582.9263C240.4526 -586.9580 243.3071 -588.6509 245.3530 -589.3242C245.3530 -589.3242 245.5269 -588.3003 245.5269 -588.3003C246.8980 -580.5181 249.5161 -573.3804 253.0679 -567.4111" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p1"/>
<path d="M350.2705 -647.1304C341.7041 -644.9409 319.3428 -638.7637 312.9766 -636.0288C312.9766 -636.0288 323.5264 -645.5620 347.5810 -655.8711C363.5205 -662.7021 377.4639 -665.3745 378.4228 -665.5664C378.5352 -665.5889 377.7383 -664.0508 377.1836 -660.6113C376.8799 -658.7300 377.0361 -655.0015 377.4570 -652.7852C377.4873 -652.6260 363.9580 -650.6289 350.2705 -647.1304Z" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p1"/>
<path d="M247.1690 -581.3408C246.8481 -582.4580 246.5527 -583.5942 246.2861 -584.7481C244.8462 -585.1079 243.0732 -584.7749 241.1348 -582.7100C235.2109 -576.3979 230.6519 -575.4868 226.8608 -574.6528C224.0190 -574.0293 209.9893 -566.6162 209.9893 -566.6162C209.9893 -566.6162 216.9971 -568.9170 221.6431 -569.3740C235.9731 -570.7813 236.1362 -561.2451 241.9609 -561.2148C246.9248 -561.1899 250.1250 -566.1050 251.8091 -569.7319C251.8091 -569.7319 248.1772 -577.8320 247.1690 -581.3408Z" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p2"/>
<path d="M436.8555 -662.4141C437.5547 -649.0679 425.0078 -637.9258 409.3486 -637.1050C393.6904 -636.2852 380.0459 -646.0552 379.3457 -659.4009C378.6475 -672.7481 391.1943 -683.8901 406.8535 -684.7100C422.5117 -685.5312 436.1553 -675.7612 436.8555 -662.4141" transform="matrix(1.000 0.000 0.000 -1.00 0.000 0.000)" class="p2"/>
</g>
</svg>
EOF
	return($output);
};

sub svg_pesthoernchen() {
	my $output;
	$output .= <<EOF;
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   version="1.1"
   baseProfile="full"
   id="body"
   width="8in"
   height="8in"
   viewBox="0 0 1 1"
   preserveAspectRatio="none"
   sodipodi:version="0.32"
   inkscape:version="0.46"
   sodipodi:docname="Pesthoernchen-from-eps.svg"
   inkscape:output_extension="org.inkscape.output.svg.inkscape">
  <metadata
     id="metadata76">
    <rdf:RDF>
      <cc:Work
         rdf:about="">
        <dc:format>image/svg+xml</dc:format>
        <dc:type
           rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
      </cc:Work>
    </rdf:RDF>
  </metadata>
  <defs
     id="defs74">
    <inkscape:perspective
       sodipodi:type="inkscape:persp3d"
       inkscape:vp_x="0 : 360 : 1"
       inkscape:vp_y="0 : 1000 : 0"
       inkscape:vp_z="720 : 360 : 1"
       inkscape:persp3d-origin="360 : 240 : 1"
       id="perspective78" />
  </defs>
  <sodipodi:namedview
     inkscape:window-height="996"
     inkscape:window-width="1021"
     inkscape:pageshadow="2"
     inkscape:pageopacity="0.0"
     guidetolerance="10.0"
     gridtolerance="10.0"
     objecttolerance="10.0"
     borderopacity="1.0"
     bordercolor="#666666"
     pagecolor="$pagecolor"
     id="base"
     showgrid="false"
     inkscape:zoom="0.25043365"
     inkscape:cx="934.63361"
     inkscape:cy="1506.3529"
     inkscape:window-x="0"
     inkscape:window-y="0"
     inkscape:current-layer="body" />
  <title
     id="title3">SVG drawing</title>
  <desc
     id="desc5">This was produced by version 4.2 of GNU libplot, a free library for exporting 2-D vector graphics.</desc>
  <rect
     id="background"
     x="0"
     y="0"
     width="100pc"
     height="100pc"
     stroke="none"
     fill="$pagecolor" />
  <g
     id="content"
EOF
	if ($xscale != 1 || $yscale != 1 ) {
	# this doesn't make sense. we have to get rid of the matrix() first.
		my $xmove = ($xscale-1)/2*(-100);
		my $ymove = ($yscale-1)/2*(-100);
		$output .= <<EOF;
     transform="matrix(1.7361e-3,0,0,-1.7361e-3,-2.3439051,4.6037963) scale($xscale,$yscale) translate($xmove,$ymove)"
EOF
	} else {
		$output .= <<EOF;
     transform="matrix(1.7361e-3,0,0,-1.7361e-3,-2.3439051,4.6037963)"
EOF
     	};
	$output .= <<EOF;
     xml:space="preserve"
     stroke-miterlimit="10.433"
     fill-rule="even-odd"
     font-style="normal"
     font-variant="normal"
     font-weight="normal"
     font-stretch="normal"
     font-size-adjust="none"
     letter-spacing="normal"
     word-spacing="normal"
     style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;letter-spacing:normal;word-spacing:normal;text-anchor:start;fill:none;fill-opacity:1;stroke:$textcolor;stroke-width:1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10.43299961;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1">
<path
   d="M 1624.2,2528.4 L 1624.7,2528.4 L 1625.1,2528.4 L 1625.6,2528.4 L 1626.1,2528.4 L 1627,2528.4 L 1627.9,2528.4 L 1628.8,2528.4 L 1629.2,2528.4 L 1629.7,2528.4 L 1630.1,2528.4 L 1630.6,2528.4 L 1631.1,2528.4 L 1631.6,2528.4 C 1660.2,2526.2 1680.4,2509.8 1699,2489 C 1703.7,2482.7 1707.4,2477.4 1711.2,2470.5 C 1712.7,2467.9 1713.8,2465.2 1715.4,2462 C 1718.6,2455.1 1720.7,2447.7 1722.8,2439.7 C 1722.8,2439.2 1722.8,2438.1 1723.4,2437.6 C 1724.4,2437.6 1723.9,2438.6 1725,2439.2 C 1725,2441.9 1726,2444 1726,2446.6 C 1727.1,2448.7 1727.1,2450.4 1727.6,2452.5 C 1731.3,2472.1 1732.9,2492.3 1727.6,2511.9 C 1729.2,2514 1732.4,2512.4 1735.1,2512.9 C 1747.2,2513.4 1758.9,2512.9 1771.1,2513.4 C 1783.3,2512.9 1795.5,2512.9 1807.2,2513.4 C 1807.2,2498.1 1806.1,2482.2 1803.5,2466.8 C 1801.9,2458.8 1800.3,2452 1798.2,2444.5 C 1793.9,2430.7 1788.6,2417.5 1783.3,2405.2 C 1781.2,2401.6 1779.6,2398.3 1777.5,2394.6 C 1765.3,2372.3 1749.4,2350.1 1728.7,2334.7 C 1718.1,2326.2 1704.8,2321.4 1692.6,2314.5 C 1691.5,2310.8 1691.5,2307.1 1688.9,2304.9 C 1685.7,2303.4 1681.4,2303.4 1677.7,2303.9 C 1676.2,2304.9 1674.6,2305.5 1673,2307.1 C 1671.3,2305.5 1670.3,2303.4 1667.7,2302.9 C 1662.8,2302.3 1657,2301.8 1653.8,2305.5 C 1653.3,2305.5 1652.8,2305.5 1652.8,2304.9 C 1649.1,2300.7 1642.2,2301.8 1636.8,2301.3 C 1634.3,2301.8 1631.6,2302.9 1630,2304.4 C 1623.1,2301.3 1615.7,2302.9 1608.2,2305.5 C 1607.7,2305.5 1607.2,2306 1607.2,2307.1 C 1604,2305.5 1601.3,2302.3 1597.1,2303.4 C 1593.4,2304.9 1590.7,2306 1588.6,2309.2 L 1584.4,2306 C 1579,2307.1 1574.8,2309.8 1571.1,2313.4 C 1567.9,2317.2 1568.9,2323.5 1567.4,2327.8 L 1562.6,2330.9 C 1559.4,2333.6 1557.3,2334.7 1554.6,2336.8 C 1542.5,2346.3 1530.8,2359.1 1521.7,2370.7 C 1517,2376.6 1513.2,2382.4 1509.6,2388.8 C 1502.6,2401.6 1497.3,2414.8 1493.1,2429.6 C 1491,2435 1489.9,2440.3 1488.3,2445.6 C 1488.3,2447.1 1487.2,2448.2 1487.2,2449.8 C 1486.7,2453.5 1485.7,2456.7 1485.7,2459.9 C 1484.6,2464.1 1484.6,2468.9 1483.6,2473.7 C 1482,2486.4 1482.5,2498.6 1481.4,2510.9 L 1522.3,2511.4 C 1522.3,2510.3 1521.7,2508.7 1521.7,2507.1 C 1521.2,2502.4 1521.2,2498.1 1521.2,2493.9 C 1522.3,2474.7 1527.1,2454.6 1534,2436.6 C 1534.5,2436.6 1534.5,2436.1 1535,2436.1 L 1536.1,2442.4 C 1536.6,2451.4 1539.3,2461 1542.5,2468.9 L 1545.1,2474.2 C 1545.6,2476.9 1547.2,2479 1548.3,2481.6 C 1550.9,2485.9 1553.5,2489 1556.2,2493.3 C 1558.4,2495.4 1559.9,2498.1 1562,2499.7 C 1577.4,2516.7 1600.3,2527.3 1624.2,2528.4 z"
   id="path9"
   style="fill:$textcolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1624.2,2528.4 L 1624.7,2528.4 L 1625.1,2528.4 L 1625.6,2528.4 L 1626.1,2528.4 L 1627,2528.4 L 1627.9,2528.4 L 1628.8,2528.4 L 1629.2,2528.4 L 1629.7,2528.4 L 1630.1,2528.4 L 1630.6,2528.4 L 1631.1,2528.4 L 1631.6,2528.4 C 1660.2,2526.2 1680.4,2509.8 1699,2489 C 1703.7,2482.7 1707.4,2477.4 1711.2,2470.5 C 1712.7,2467.9 1713.8,2465.2 1715.4,2462 C 1718.6,2455.1 1720.7,2447.7 1722.8,2439.7 C 1722.8,2439.2 1722.8,2438.1 1723.4,2437.6 C 1724.4,2437.6 1723.9,2438.6 1725,2439.2 C 1725,2441.9 1726,2444 1726,2446.6 C 1727.1,2448.7 1727.1,2450.4 1727.6,2452.5 C 1731.3,2472.1 1732.9,2492.3 1727.6,2511.9 C 1729.2,2514 1732.4,2512.4 1735.1,2512.9 C 1747.2,2513.4 1758.9,2512.9 1771.1,2513.4 C 1783.3,2512.9 1795.5,2512.9 1807.2,2513.4 C 1807.2,2498.1 1806.1,2482.2 1803.5,2466.8 C 1801.9,2458.8 1800.3,2452 1798.2,2444.5 C 1793.9,2430.7 1788.6,2417.5 1783.3,2405.2 C 1781.2,2401.6 1779.6,2398.3 1777.5,2394.6 C 1765.3,2372.3 1749.4,2350.1 1728.7,2334.7 C 1718.1,2326.2 1704.8,2321.4 1692.6,2314.5 C 1691.5,2310.8 1691.5,2307.1 1688.9,2304.9 C 1685.7,2303.4 1681.4,2303.4 1677.7,2303.9 C 1676.2,2304.9 1674.6,2305.5 1673,2307.1 C 1671.3,2305.5 1670.3,2303.4 1667.7,2302.9 C 1662.8,2302.3 1657,2301.8 1653.8,2305.5 C 1653.3,2305.5 1652.8,2305.5 1652.8,2304.9 C 1649.1,2300.7 1642.2,2301.8 1636.8,2301.3 C 1634.3,2301.8 1631.6,2302.9 1630,2304.4 C 1623.1,2301.3 1615.7,2302.9 1608.2,2305.5 C 1607.7,2305.5 1607.2,2306 1607.2,2307.1 C 1604,2305.5 1601.3,2302.3 1597.1,2303.4 C 1593.4,2304.9 1590.7,2306 1588.6,2309.2 L 1584.4,2306 C 1579,2307.1 1574.8,2309.8 1571.1,2313.4 C 1567.9,2317.2 1568.9,2323.5 1567.4,2327.8 L 1562.6,2330.9 C 1559.4,2333.6 1557.3,2334.7 1554.6,2336.8 C 1542.5,2346.3 1530.8,2359.1 1521.7,2370.7 C 1517,2376.6 1513.2,2382.4 1509.6,2388.8 C 1502.6,2401.6 1497.3,2414.8 1493.1,2429.6 C 1491,2435 1489.9,2440.3 1488.3,2445.6 C 1488.3,2447.1 1487.2,2448.2 1487.2,2449.8 C 1486.7,2453.5 1485.7,2456.7 1485.7,2459.9 C 1484.6,2464.1 1484.6,2468.9 1483.6,2473.7 C 1482,2486.4 1482.5,2498.6 1481.4,2510.9 L 1522.3,2511.4 C 1522.3,2510.3 1521.7,2508.7 1521.7,2507.1 C 1521.2,2502.4 1521.2,2498.1 1521.2,2493.9 C 1522.3,2474.7 1527.1,2454.6 1534,2436.6 C 1534.5,2436.6 1534.5,2436.1 1535,2436.1 L 1536.1,2442.4 C 1536.6,2451.4 1539.3,2461 1542.5,2468.9 L 1545.1,2474.2 C 1545.6,2476.9 1547.2,2479 1548.3,2481.6 C 1550.9,2485.9 1553.5,2489 1556.2,2493.3 C 1558.4,2495.4 1559.9,2498.1 1562,2499.7 C 1577.4,2516.7 1600.3,2527.3 1624.2,2528.4 z"
   id="path11"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1669.8,2459.4 L 1671.9,2459.4 L 1674.1,2459.4 L 1676.3,2459.3 L 1677.5,2459.3 L 1678.6,2459.2 L 1679.7,2459.2 L 1680.8,2459.1 L 1682,2459 L 1683.1,2458.9 L 1684.3,2458.8 L 1685.4,2458.7 L 1686.6,2458.5 L 1687.8,2458.3 C 1693.7,2456.2 1696.8,2452.5 1701.6,2448.2 L 1704.2,2444 L 1706.9,2437.6 C 1709.1,2429.6 1707.4,2420.6 1704.2,2413.2 C 1700.6,2409.5 1696.3,2405.8 1691,2404.7 C 1679.8,2401.6 1673,2390.9 1659.7,2392.5 C 1659.2,2393.1 1658.7,2393.6 1658.1,2393.6 C 1656,2396.7 1654.9,2401.6 1653.3,2405.8 C 1651.2,2410.6 1650.2,2415.3 1648,2420.1 C 1645.3,2427 1644.8,2435.5 1646.9,2442.4 C 1648,2445.1 1650.2,2447.1 1650.7,2449.3 C 1654.4,2454.1 1658.7,2455.6 1663.4,2458.3 C 1665.5,2458.8 1667.7,2458.8 1669.8,2459.4 z"
   id="path13"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1669.8,2459.4 L 1671.9,2459.4 L 1674.1,2459.4 L 1676.3,2459.3 L 1677.5,2459.3 L 1678.6,2459.2 L 1679.7,2459.2 L 1680.8,2459.1 L 1682,2459 L 1683.1,2458.9 L 1684.3,2458.8 L 1685.4,2458.7 L 1686.6,2458.5 L 1687.8,2458.3 C 1693.7,2456.2 1696.8,2452.5 1701.6,2448.2 L 1704.2,2444 L 1706.9,2437.6 C 1709.1,2429.6 1707.4,2420.6 1704.2,2413.2 C 1700.6,2409.5 1696.3,2405.8 1691,2404.7 C 1679.8,2401.6 1673,2390.9 1659.7,2392.5 C 1659.2,2393.1 1658.7,2393.6 1658.1,2393.6 C 1656,2396.7 1654.9,2401.6 1653.3,2405.8 C 1651.2,2410.6 1650.2,2415.3 1648,2420.1 C 1645.3,2427 1644.8,2435.5 1646.9,2442.4 C 1648,2445.1 1650.2,2447.1 1650.7,2449.3 C 1654.4,2454.1 1658.7,2455.6 1663.4,2458.3 C 1665.5,2458.8 1667.7,2458.8 1669.8,2459.4 z"
   id="path15"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1605.6,2457.8 L 1606,2457.8 L 1606.4,2457.8 L 1606.8,2457.8 L 1607.2,2457.8 L 1607.7,2457.8 L 1608.1,2457.8 L 1608.3,2457.8 L 1608.5,2457.8 L 1608.7,2457.8 L 1608.9,2457.8 L 1609.1,2457.8 L 1609.3,2457.7 L 1609.5,2457.7 L 1609.7,2457.6 L 1609.8,2457.6 L 1610,2457.5 L 1610.2,2457.4 L 1610.4,2457.3 L 1610.5,2457.2 L 1610.7,2457.1 L 1610.8,2457 L 1611,2456.9 L 1611.1,2456.7 L 1611.2,2456.6 L 1611.3,2456.4 L 1611.4,2456.2 C 1615.7,2449.8 1620.4,2442.4 1620.4,2433.9 C 1619.3,2421.1 1618.3,2408.4 1615.1,2396.2 C 1614.1,2392.5 1610.9,2389.3 1607.7,2388.8 C 1598.1,2386.7 1591.3,2393.6 1583.9,2397.3 C 1574.3,2398.9 1565.3,2401.6 1559.9,2409.5 C 1557.3,2413.2 1559.4,2417.5 1557.8,2421.7 C 1557.3,2429.1 1557.8,2438.1 1563.1,2442.4 C 1567.4,2445.1 1572.7,2446.6 1576.9,2448.7 C 1583.9,2450.4 1588.6,2454.1 1594.9,2455.6 C 1596.5,2456.2 1598.7,2456.2 1600.3,2457.2 C 1602.4,2457.2 1604,2457.2 1605.6,2457.8 z"
   id="path17"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1605.6,2457.8 L 1606,2457.8 L 1606.4,2457.8 L 1606.8,2457.8 L 1607.2,2457.8 L 1607.7,2457.8 L 1608.1,2457.8 L 1608.3,2457.8 L 1608.5,2457.8 L 1608.7,2457.8 L 1608.9,2457.8 L 1609.1,2457.8 L 1609.3,2457.7 L 1609.5,2457.7 L 1609.7,2457.6 L 1609.8,2457.6 L 1610,2457.5 L 1610.2,2457.4 L 1610.4,2457.3 L 1610.5,2457.2 L 1610.7,2457.1 L 1610.8,2457 L 1611,2456.9 L 1611.1,2456.7 L 1611.2,2456.6 L 1611.3,2456.4 L 1611.4,2456.2 C 1615.7,2449.8 1620.4,2442.4 1620.4,2433.9 C 1619.3,2421.1 1618.3,2408.4 1615.1,2396.2 C 1614.1,2392.5 1610.9,2389.3 1607.7,2388.8 C 1598.1,2386.7 1591.3,2393.6 1583.9,2397.3 C 1574.3,2398.9 1565.3,2401.6 1559.9,2409.5 C 1557.3,2413.2 1559.4,2417.5 1557.8,2421.7 C 1557.3,2429.1 1557.8,2438.1 1563.1,2442.4 C 1567.4,2445.1 1572.7,2446.6 1576.9,2448.7 C 1583.9,2450.4 1588.6,2454.1 1594.9,2455.6 C 1596.5,2456.2 1598.7,2456.2 1600.3,2457.2 C 1602.4,2457.2 1604,2457.2 1605.6,2457.8 z"
   id="path19"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1636.8,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1637,2439.2 L 1637,2439.2 L 1637,2439.2 L 1637,2439.2 L 1637.1,2439.2 L 1637.1,2439.2 L 1637.1,2439.2 L 1637.2,2439.2 L 1637.2,2439.2 L 1637.2,2439.2 L 1637.3,2439.2 L 1637.3,2439.2 L 1637.3,2439.2 L 1637.3,2439.2 L 1637.3,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 C 1639,2436.6 1638.5,2432.3 1639,2429.1 C 1640.1,2419.1 1643.3,2409 1643.3,2399.4 C 1643.8,2396.2 1643.8,2393.6 1644.3,2390.4 C 1646.4,2379.7 1642.2,2370.2 1639.5,2360.2 C 1639,2359.1 1639,2358 1639,2356.4 C 1639,2355.9 1637.9,2355.3 1636.8,2354.8 L 1635.3,2361.7 C 1634.8,2362.2 1633.2,2362.8 1632.6,2362.2 C 1631.6,2361.2 1631,2360.7 1631.6,2359.6 C 1631.6,2356.4 1632.6,2353.2 1630.5,2350.6 C 1630.5,2350.6 1630,2350.6 1630,2350.6 C 1624.7,2359.6 1621.5,2371.8 1620.4,2383 C 1620.9,2399.4 1626.8,2414.2 1626.3,2430.1 C 1627.3,2431.2 1627.3,2432.3 1627.8,2432.8 C 1631,2423.8 1627.3,2411.1 1631.6,2402.6 C 1632.1,2402.1 1632.6,2402.1 1633.2,2401.6 C 1633.2,2401.6 1633.2,2402.1 1633.2,2402.1 C 1635.3,2413.2 1633.2,2426.5 1635.8,2438.6 C 1635.8,2439.2 1636.3,2439.2 1636.8,2439.2 L 1636.8,2439.2 z"
   id="path21"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1636.8,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1636.9,2439.2 L 1637,2439.2 L 1637,2439.2 L 1637,2439.2 L 1637,2439.2 L 1637.1,2439.2 L 1637.1,2439.2 L 1637.1,2439.2 L 1637.2,2439.2 L 1637.2,2439.2 L 1637.2,2439.2 L 1637.3,2439.2 L 1637.3,2439.2 L 1637.3,2439.2 L 1637.3,2439.2 L 1637.3,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 L 1637.4,2439.2 C 1639,2436.6 1638.5,2432.3 1639,2429.1 C 1640.1,2419.1 1643.3,2409 1643.3,2399.4 C 1643.8,2396.2 1643.8,2393.6 1644.3,2390.4 C 1646.4,2379.7 1642.2,2370.2 1639.5,2360.2 C 1639,2359.1 1639,2358 1639,2356.4 C 1639,2355.9 1637.9,2355.3 1636.8,2354.8 L 1635.3,2361.7 C 1634.8,2362.2 1633.2,2362.8 1632.6,2362.2 C 1631.6,2361.2 1631,2360.7 1631.6,2359.6 C 1631.6,2356.4 1632.6,2353.2 1630.5,2350.6 C 1630.5,2350.6 1630,2350.6 1630,2350.6 C 1624.7,2359.6 1621.5,2371.8 1620.4,2383 C 1620.9,2399.4 1626.8,2414.2 1626.3,2430.1 C 1627.3,2431.2 1627.3,2432.3 1627.8,2432.8 C 1631,2423.8 1627.3,2411.1 1631.6,2402.6 C 1632.1,2402.1 1632.6,2402.1 1633.2,2401.6 C 1633.2,2401.6 1633.2,2402.1 1633.2,2402.1 C 1635.3,2413.2 1633.2,2426.5 1635.8,2438.6 C 1635.8,2439.2 1636.3,2439.2 1636.8,2439.2 L 1636.8,2439.2 z"
   id="path23"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.2,2430.7 L 1718.2,2430.7 L 1718.2,2430.7 L 1718.2,2430.7 L 1718.2,2430.7 L 1718.3,2430.7 L 1718.3,2430.7 L 1718.4,2430.7 L 1718.4,2430.7 L 1718.4,2430.7 L 1718.4,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 C 1719.1,2430.1 1719.7,2429.6 1719.7,2429.1 C 1719.7,2426 1717,2423.8 1717,2420.6 C 1715.9,2415.9 1716.5,2410.6 1716.5,2405.8 C 1716.5,2405.8 1717,2405.8 1717.5,2405.2 C 1717,2404.1 1718.1,2402.6 1717.5,2401.6 C 1718.1,2398.3 1718.1,2395.7 1718.6,2393.1 C 1719.1,2386.7 1719.1,2380.8 1718.6,2375.5 C 1718.6,2375 1718.6,2374.5 1718.6,2374.5 C 1718.6,2373.9 1718.6,2373.9 1718.1,2373.4 C 1718.1,2372.9 1718.6,2372.9 1718.6,2372.3 L 1717.5,2365.4 C 1715.4,2361.7 1714.3,2357.5 1710.1,2355.3 C 1709.6,2355.3 1709.1,2355.3 1708.5,2355.3 C 1707.4,2355.3 1706.9,2357 1707.4,2357.5 C 1711.7,2360.2 1714.9,2364.4 1715.4,2370.7 C 1716.5,2376.1 1716.5,2380.8 1716.5,2386.1 C 1714.9,2401 1709.6,2417.5 1718.1,2430.7 L 1718.1,2430.7 z"
   id="path25"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.1,2430.7 L 1718.2,2430.7 L 1718.2,2430.7 L 1718.2,2430.7 L 1718.2,2430.7 L 1718.2,2430.7 L 1718.3,2430.7 L 1718.3,2430.7 L 1718.4,2430.7 L 1718.4,2430.7 L 1718.4,2430.7 L 1718.4,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.5,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 L 1718.6,2430.7 C 1719.1,2430.1 1719.7,2429.6 1719.7,2429.1 C 1719.7,2426 1717,2423.8 1717,2420.6 C 1715.9,2415.9 1716.5,2410.6 1716.5,2405.8 C 1716.5,2405.8 1717,2405.8 1717.5,2405.2 C 1717,2404.1 1718.1,2402.6 1717.5,2401.6 C 1718.1,2398.3 1718.1,2395.7 1718.6,2393.1 C 1719.1,2386.7 1719.1,2380.8 1718.6,2375.5 C 1718.6,2375 1718.6,2374.5 1718.6,2374.5 C 1718.6,2373.9 1718.6,2373.9 1718.1,2373.4 C 1718.1,2372.9 1718.6,2372.9 1718.6,2372.3 L 1717.5,2365.4 C 1715.4,2361.7 1714.3,2357.5 1710.1,2355.3 C 1709.6,2355.3 1709.1,2355.3 1708.5,2355.3 C 1707.4,2355.3 1706.9,2357 1707.4,2357.5 C 1711.7,2360.2 1714.9,2364.4 1715.4,2370.7 C 1716.5,2376.1 1716.5,2380.8 1716.5,2386.1 C 1714.9,2401 1709.6,2417.5 1718.1,2430.7 L 1718.1,2430.7 z"
   id="path27"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1537.6,2425.4 L 1537.7,2425.4 L 1537.7,2425.4 L 1537.8,2425.4 L 1537.9,2425.4 L 1537.9,2425.4 L 1538,2425.3 L 1538.1,2425.3 L 1538.1,2425.3 L 1538.2,2425.3 L 1538.3,2425.3 L 1538.3,2425.2 L 1538.4,2425.2 L 1538.5,2425.2 L 1538.5,2425.1 L 1538.6,2425.1 L 1538.7,2425.1 L 1538.7,2425 L 1538.8,2425 L 1538.9,2424.9 L 1538.9,2424.9 L 1539,2424.9 L 1539,2424.8 L 1539.1,2424.8 L 1539.1,2424.7 L 1539.2,2424.7 L 1539.2,2424.6 L 1539.2,2424.6 L 1539.2,2424.5 L 1539.3,2424.5 L 1539.3,2424.4 L 1539.3,2424.4 L 1539.3,2424.4 L 1539.3,2424.3 L 1539.3,2424.3 C 1539.8,2422.2 1540.9,2421.1 1541.4,2419.6 C 1541.9,2418.5 1543,2418 1542.5,2416.4 L 1543.5,2412.6 L 1545.1,2406.8 L 1545.1,2403.6 L 1545.6,2397.3 L 1545.1,2395.7 L 1544,2380.3 C 1545.1,2379.7 1544,2378.7 1544.5,2378.2 C 1544.5,2378.2 1544.5,2378.2 1545.1,2377.7 L 1545.1,2371.8 C 1545.1,2371.8 1545.6,2371.3 1546.1,2371.3 L 1547.2,2364.9 L 1548.8,2361.2 C 1549.9,2360.2 1550.4,2358 1550.4,2355.9 C 1550.4,2354.8 1549.9,2354.8 1549.4,2354.8 C 1545.1,2359.6 1542.5,2367.1 1540.9,2375 C 1540.9,2376.6 1541.4,2377.7 1540.9,2379.2 C 1540.9,2393.6 1543.5,2409.5 1536.6,2422.7 C 1536.6,2423.3 1536.1,2424.3 1536.1,2424.9 C 1536.6,2424.9 1537.1,2425.4 1537.6,2425.4 z"
   id="path29"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1537.6,2425.4 L 1537.7,2425.4 L 1537.7,2425.4 L 1537.8,2425.4 L 1537.9,2425.4 L 1537.9,2425.4 L 1538,2425.3 L 1538.1,2425.3 L 1538.1,2425.3 L 1538.2,2425.3 L 1538.3,2425.3 L 1538.3,2425.2 L 1538.4,2425.2 L 1538.5,2425.2 L 1538.5,2425.1 L 1538.6,2425.1 L 1538.7,2425.1 L 1538.7,2425 L 1538.8,2425 L 1538.9,2424.9 L 1538.9,2424.9 L 1539,2424.9 L 1539,2424.8 L 1539.1,2424.8 L 1539.1,2424.7 L 1539.2,2424.7 L 1539.2,2424.6 L 1539.2,2424.6 L 1539.2,2424.5 L 1539.3,2424.5 L 1539.3,2424.4 L 1539.3,2424.4 L 1539.3,2424.4 L 1539.3,2424.3 L 1539.3,2424.3 C 1539.8,2422.2 1540.9,2421.1 1541.4,2419.6 C 1541.9,2418.5 1543,2418 1542.5,2416.4 L 1543.5,2412.6 L 1545.1,2406.8 L 1545.1,2403.6 L 1545.6,2397.3 L 1545.1,2395.7 L 1544,2380.3 C 1545.1,2379.7 1544,2378.7 1544.5,2378.2 C 1544.5,2378.2 1544.5,2378.2 1545.1,2377.7 L 1545.1,2371.8 C 1545.1,2371.8 1545.6,2371.3 1546.1,2371.3 L 1547.2,2364.9 L 1548.8,2361.2 C 1549.9,2360.2 1550.4,2358 1550.4,2355.9 C 1550.4,2354.8 1549.9,2354.8 1549.4,2354.8 C 1545.1,2359.6 1542.5,2367.1 1540.9,2375 C 1540.9,2376.6 1541.4,2377.7 1540.9,2379.2 C 1540.9,2393.6 1543.5,2409.5 1536.6,2422.7 C 1536.6,2423.3 1536.1,2424.3 1536.1,2424.9 C 1536.6,2424.9 1537.1,2425.4 1537.6,2425.4 z"
   id="path31"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1622,2334.7 L 1622.2,2334.7 L 1622.3,2334.7 L 1622.5,2334.7 L 1622.6,2334.6 L 1623,2334.6 L 1623.3,2334.6 L 1623.6,2334.5 L 1624,2334.5 L 1624.3,2334.4 L 1624.6,2334.3 L 1624.8,2334.2 L 1624.9,2334.2 L 1625.1,2334.1 L 1625.2,2334.1 L 1625.4,2334 L 1625.5,2333.9 L 1625.7,2333.9 L 1625.8,2333.8 L 1626,2333.7 L 1626.1,2333.6 L 1626.2,2333.6 L 1626.3,2333.5 L 1626.5,2333.4 L 1626.6,2333.3 L 1626.7,2333.2 L 1626.8,2333.1 C 1626.8,2332.6 1626.8,2332 1626.8,2332 C 1627.3,2324.6 1628.9,2316.1 1626.3,2309.2 C 1622,2307.1 1616.7,2309.2 1611.9,2310.3 C 1611.4,2310.3 1610.9,2310.8 1610.3,2311.3 C 1609.3,2315.6 1610.9,2320.9 1611.4,2325.1 C 1611.9,2327.3 1612.4,2328.3 1613,2329.3 L 1619.9,2333.6 L 1622,2334.7 z"
   id="path33"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1622,2334.7 L 1622.2,2334.7 L 1622.3,2334.7 L 1622.5,2334.7 L 1622.6,2334.6 L 1623,2334.6 L 1623.3,2334.6 L 1623.6,2334.5 L 1624,2334.5 L 1624.3,2334.4 L 1624.6,2334.3 L 1624.8,2334.2 L 1624.9,2334.2 L 1625.1,2334.1 L 1625.2,2334.1 L 1625.4,2334 L 1625.5,2333.9 L 1625.7,2333.9 L 1625.8,2333.8 L 1626,2333.7 L 1626.1,2333.6 L 1626.2,2333.6 L 1626.3,2333.5 L 1626.5,2333.4 L 1626.6,2333.3 L 1626.7,2333.2 L 1626.8,2333.1 C 1626.8,2332.6 1626.8,2332 1626.8,2332 C 1627.3,2324.6 1628.9,2316.1 1626.3,2309.2 C 1622,2307.1 1616.7,2309.2 1611.9,2310.3 C 1611.4,2310.3 1610.9,2310.8 1610.3,2311.3 C 1609.3,2315.6 1610.9,2320.9 1611.4,2325.1 C 1611.9,2327.3 1612.4,2328.3 1613,2329.3 L 1619.9,2333.6 L 1622,2334.7 z"
   id="path35"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1641.7,2334.7 L 1641.9,2334.6 L 1642.2,2334.6 L 1642.4,2334.5 L 1642.7,2334.4 L 1642.9,2334.4 L 1643.2,2334.3 L 1643.4,2334.2 L 1643.6,2334.1 L 1643.9,2334 L 1644.1,2333.9 L 1644.3,2333.8 L 1644.6,2333.7 L 1644.8,2333.6 L 1645,2333.4 L 1645.2,2333.3 L 1645.4,2333.2 L 1645.6,2333 L 1645.8,2332.9 L 1646,2332.7 L 1646.2,2332.6 L 1646.4,2332.4 L 1646.6,2332.3 L 1646.8,2332.1 L 1646.9,2331.9 L 1647.1,2331.8 L 1647.3,2331.6 L 1647.4,2331.4 L 1647.5,2331.2 L 1647.7,2331 L 1647.8,2330.8 L 1647.9,2330.6 L 1648,2330.4 C 1650.2,2324.1 1652.8,2315.6 1649.1,2309.8 C 1648.6,2309.2 1648.6,2308.7 1648,2308.2 C 1643.8,2306 1637.4,2307.1 1632.6,2308.7 L 1633.2,2330.9 C 1634.8,2334.2 1638.5,2334.2 1641.7,2334.7 z"
   id="path37"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1641.7,2334.7 L 1641.9,2334.6 L 1642.2,2334.6 L 1642.4,2334.5 L 1642.7,2334.4 L 1642.9,2334.4 L 1643.2,2334.3 L 1643.4,2334.2 L 1643.6,2334.1 L 1643.9,2334 L 1644.1,2333.9 L 1644.3,2333.8 L 1644.6,2333.7 L 1644.8,2333.6 L 1645,2333.4 L 1645.2,2333.3 L 1645.4,2333.2 L 1645.6,2333 L 1645.8,2332.9 L 1646,2332.7 L 1646.2,2332.6 L 1646.4,2332.4 L 1646.6,2332.3 L 1646.8,2332.1 L 1646.9,2331.9 L 1647.1,2331.8 L 1647.3,2331.6 L 1647.4,2331.4 L 1647.5,2331.2 L 1647.7,2331 L 1647.8,2330.8 L 1647.9,2330.6 L 1648,2330.4 C 1650.2,2324.1 1652.8,2315.6 1649.1,2309.8 C 1648.6,2309.2 1648.6,2308.7 1648,2308.2 C 1643.8,2306 1637.4,2307.1 1632.6,2308.7 L 1633.2,2330.9 C 1634.8,2334.2 1638.5,2334.2 1641.7,2334.7 z"
   id="path39"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1782.3,2330.9 L 1783.1,2330.8 L 1784,2330.7 L 1784.8,2330.5 L 1785.7,2330.4 L 1786.5,2330.2 L 1787.3,2330 L 1788.1,2329.7 L 1789,2329.5 L 1789.8,2329.2 L 1790.6,2328.9 L 1791.4,2328.5 L 1792.2,2328.2 L 1792.9,2327.8 L 1793.7,2327.4 L 1794.5,2327 L 1795.2,2326.6 L 1795.9,2326.1 L 1796.6,2325.6 L 1797.3,2325.1 L 1798,2324.6 L 1798.7,2324.1 L 1799.3,2323.5 L 1799.9,2322.9 L 1800.5,2322.3 L 1801.1,2321.7 L 1801.7,2321 L 1802.2,2320.4 L 1802.7,2319.7 L 1803.2,2318.9 L 1803.7,2318.2 L 1804.1,2317.4 L 1804.5,2316.7 C 1808.8,2308.2 1806.1,2297.5 1802.4,2289.6 C 1800.3,2284.8 1797.1,2281.1 1795,2277.4 C 1795,2276.9 1795,2276.9 1795.5,2276.3 C 1797.6,2276.9 1799.2,2279.5 1801.4,2281.1 C 1804,2280 1806.1,2276.3 1807.7,2273.7 C 1808.3,2272.6 1808.3,2271 1809.3,2269.4 C 1809.9,2266.2 1809.3,2263.6 1809.3,2259.9 C 1808.3,2251.4 1802.9,2245 1797.1,2240.8 C 1787.5,2236 1776.4,2233.4 1766.9,2237.6 C 1762.1,2240.2 1757.3,2244.5 1755.7,2249.8 C 1754.1,2255.6 1754.1,2260.9 1755.7,2266.2 C 1755.7,2266.8 1755.7,2266.8 1755.2,2266.8 C 1755.2,2267.3 1754.1,2267.3 1753.6,2267.3 C 1752,2265.2 1751.5,2262.5 1751,2259.4 L 1729.2,2259.4 L 1704.8,2297.5 L 1753.6,2298.1 C 1754.1,2308.7 1757.9,2320.3 1766.9,2326.2 C 1768,2326.8 1769,2327.8 1770.1,2328.3 C 1774.3,2329.9 1778,2330.9 1782.3,2330.9 z"
   id="path41"
   style="fill:$textcolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1782.3,2330.9 L 1783.1,2330.8 L 1784,2330.7 L 1784.8,2330.5 L 1785.7,2330.4 L 1786.5,2330.2 L 1787.3,2330 L 1788.1,2329.7 L 1789,2329.5 L 1789.8,2329.2 L 1790.6,2328.9 L 1791.4,2328.5 L 1792.2,2328.2 L 1792.9,2327.8 L 1793.7,2327.4 L 1794.5,2327 L 1795.2,2326.6 L 1795.9,2326.1 L 1796.6,2325.6 L 1797.3,2325.1 L 1798,2324.6 L 1798.7,2324.1 L 1799.3,2323.5 L 1799.9,2322.9 L 1800.5,2322.3 L 1801.1,2321.7 L 1801.7,2321 L 1802.2,2320.4 L 1802.7,2319.7 L 1803.2,2318.9 L 1803.7,2318.2 L 1804.1,2317.4 L 1804.5,2316.7 C 1808.8,2308.2 1806.1,2297.5 1802.4,2289.6 C 1800.3,2284.8 1797.1,2281.1 1795,2277.4 C 1795,2276.9 1795,2276.9 1795.5,2276.3 C 1797.6,2276.9 1799.2,2279.5 1801.4,2281.1 C 1804,2280 1806.1,2276.3 1807.7,2273.7 C 1808.3,2272.6 1808.3,2271 1809.3,2269.4 C 1809.9,2266.2 1809.3,2263.6 1809.3,2259.9 C 1808.3,2251.4 1802.9,2245 1797.1,2240.8 C 1787.5,2236 1776.4,2233.4 1766.9,2237.6 C 1762.1,2240.2 1757.3,2244.5 1755.7,2249.8 C 1754.1,2255.6 1754.1,2260.9 1755.7,2266.2 C 1755.7,2266.8 1755.7,2266.8 1755.2,2266.8 C 1755.2,2267.3 1754.1,2267.3 1753.6,2267.3 C 1752,2265.2 1751.5,2262.5 1751,2259.4 L 1729.2,2259.4 L 1704.8,2297.5 L 1753.6,2298.1 C 1754.1,2308.7 1757.9,2320.3 1766.9,2326.2 C 1768,2326.8 1769,2327.8 1770.1,2328.3 C 1774.3,2329.9 1778,2330.9 1782.3,2330.9 z"
   id="path43"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1659.2,2330.4 L 1659.8,2330.4 L 1660.4,2330.4 L 1661,2330.4 L 1661.6,2330.3 L 1662.2,2330.2 L 1662.9,2330.1 L 1663.5,2330 L 1663.8,2330 L 1664.1,2329.9 L 1664.4,2329.8 L 1664.7,2329.7 L 1665,2329.6 L 1665.2,2329.6 L 1665.5,2329.4 L 1665.8,2329.3 L 1666.1,2329.2 L 1666.3,2329.1 L 1666.6,2329 L 1666.8,2328.8 L 1667.1,2328.7 L 1667.3,2328.5 L 1667.5,2328.3 L 1667.8,2328.1 L 1668,2328 L 1668.2,2327.8 C 1668.7,2321.4 1669.2,2315 1667.7,2309.8 C 1665,2307.6 1661.3,2307.6 1658.1,2309.2 C 1655.4,2310.8 1655.4,2314.5 1655.4,2317.2 C 1656,2321.4 1654.9,2325.7 1656.5,2329.3 C 1658.1,2329.9 1658.7,2330.4 1659.2,2330.4 z"
   id="path45"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1659.2,2330.4 L 1659.8,2330.4 L 1660.4,2330.4 L 1661,2330.4 L 1661.6,2330.3 L 1662.2,2330.2 L 1662.9,2330.1 L 1663.5,2330 L 1663.8,2330 L 1664.1,2329.9 L 1664.4,2329.8 L 1664.7,2329.7 L 1665,2329.6 L 1665.2,2329.6 L 1665.5,2329.4 L 1665.8,2329.3 L 1666.1,2329.2 L 1666.3,2329.1 L 1666.6,2329 L 1666.8,2328.8 L 1667.1,2328.7 L 1667.3,2328.5 L 1667.5,2328.3 L 1667.8,2328.1 L 1668,2328 L 1668.2,2327.8 C 1668.7,2321.4 1669.2,2315 1667.7,2309.8 C 1665,2307.6 1661.3,2307.6 1658.1,2309.2 C 1655.4,2310.8 1655.4,2314.5 1655.4,2317.2 C 1656,2321.4 1654.9,2325.7 1656.5,2329.3 C 1658.1,2329.9 1658.7,2330.4 1659.2,2330.4 z"
   id="path47"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1597.1,2329.9 L 1597.7,2329.8 L 1598.3,2329.7 L 1598.9,2329.6 L 1599.5,2329.5 L 1600,2329.3 L 1600.6,2329.2 L 1600.9,2329.1 L 1601.1,2329 L 1601.4,2328.9 L 1601.7,2328.8 L 1601.9,2328.7 L 1602.2,2328.5 L 1602.4,2328.4 L 1602.7,2328.3 L 1602.9,2328.1 L 1603.1,2327.9 L 1603.3,2327.8 L 1603.6,2327.6 L 1603.8,2327.4 L 1604,2327.2 L 1604.2,2327 L 1604.4,2326.7 L 1604.5,2326.5 L 1604.7,2326.2 L 1604.9,2326 L 1605,2325.7 C 1606.1,2321.4 1605,2316.1 1604,2311.9 C 1603.4,2311.3 1602.9,2310.3 1602.4,2309.8 C 1599.2,2307.6 1595.5,2309.8 1592.9,2310.8 C 1589.1,2315 1590.7,2320.9 1591.3,2325.1 C 1591.3,2326.8 1592.3,2327.3 1592.9,2328.3 L 1597.1,2329.9 z"
   id="path49"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1597.1,2329.9 L 1597.7,2329.8 L 1598.3,2329.7 L 1598.9,2329.6 L 1599.5,2329.5 L 1600,2329.3 L 1600.6,2329.2 L 1600.9,2329.1 L 1601.1,2329 L 1601.4,2328.9 L 1601.7,2328.8 L 1601.9,2328.7 L 1602.2,2328.5 L 1602.4,2328.4 L 1602.7,2328.3 L 1602.9,2328.1 L 1603.1,2327.9 L 1603.3,2327.8 L 1603.6,2327.6 L 1603.8,2327.4 L 1604,2327.2 L 1604.2,2327 L 1604.4,2326.7 L 1604.5,2326.5 L 1604.7,2326.2 L 1604.9,2326 L 1605,2325.7 C 1606.1,2321.4 1605,2316.1 1604,2311.9 C 1603.4,2311.3 1602.9,2310.3 1602.4,2309.8 C 1599.2,2307.6 1595.5,2309.8 1592.9,2310.8 C 1589.1,2315 1590.7,2320.9 1591.3,2325.1 C 1591.3,2326.8 1592.3,2327.3 1592.9,2328.3 L 1597.1,2329.9 z"
   id="path51"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1684.7,2329.9 L 1684.8,2329.8 L 1685,2329.7 L 1685.2,2329.6 L 1685.3,2329.4 L 1685.5,2329.3 L 1685.6,2329.1 L 1685.8,2328.9 L 1685.9,2328.8 L 1686,2328.6 L 1686.1,2328.4 L 1686.2,2328.2 L 1686.3,2328 L 1686.4,2327.8 L 1686.5,2327.6 L 1686.5,2327.3 L 1686.6,2327.1 L 1686.8,2326.7 L 1686.9,2326.2 L 1687,2325.7 L 1687.2,2325.3 L 1687.3,2324.8 L 1687.4,2324.6 L 1687.5,2324.4 L 1687.5,2324.1 L 1687.6,2323.9 L 1687.7,2323.7 L 1687.8,2323.5 C 1687.8,2318.8 1688.3,2314 1686.2,2310.3 C 1683.6,2308.7 1679.3,2309.2 1676.2,2310.3 C 1675.1,2311.3 1674.6,2311.9 1674.6,2312.9 C 1673.5,2316.7 1673.5,2320.9 1674.6,2325.1 C 1676.7,2327.8 1680.9,2328.8 1684.7,2329.9 z"
   id="path53"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1684.7,2329.9 L 1684.8,2329.8 L 1685,2329.7 L 1685.2,2329.6 L 1685.3,2329.4 L 1685.5,2329.3 L 1685.6,2329.1 L 1685.8,2328.9 L 1685.9,2328.8 L 1686,2328.6 L 1686.1,2328.4 L 1686.2,2328.2 L 1686.3,2328 L 1686.4,2327.8 L 1686.5,2327.6 L 1686.5,2327.3 L 1686.6,2327.1 L 1686.8,2326.7 L 1686.9,2326.2 L 1687,2325.7 L 1687.2,2325.3 L 1687.3,2324.8 L 1687.4,2324.6 L 1687.5,2324.4 L 1687.5,2324.1 L 1687.6,2323.9 L 1687.7,2323.7 L 1687.8,2323.5 C 1687.8,2318.8 1688.3,2314 1686.2,2310.3 C 1683.6,2308.7 1679.3,2309.2 1676.2,2310.3 C 1675.1,2311.3 1674.6,2311.9 1674.6,2312.9 C 1673.5,2316.7 1673.5,2320.9 1674.6,2325.1 C 1676.7,2327.8 1680.9,2328.8 1684.7,2329.9 z"
   id="path55"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1574.8,2329.3 L 1575.8,2329.3 L 1576.8,2329.3 L 1577.8,2329.3 L 1578.3,2329.3 L 1578.8,2329.3 L 1579.4,2329.3 L 1579.9,2329.2 L 1580.4,2329.2 L 1581,2329.1 L 1581.5,2329.1 L 1582.1,2329 L 1582.7,2328.9 L 1583.3,2328.8 C 1584.4,2328.3 1584.9,2328.3 1585.4,2327.8 C 1587,2323 1585.9,2317.2 1584.4,2312.4 C 1583.9,2311.9 1583.3,2311.9 1583.3,2311.3 C 1580.1,2311.9 1576.9,2313.4 1574.8,2315 C 1573.2,2318.8 1571.6,2323 1572.7,2327.3 C 1572.7,2327.8 1573.2,2328.3 1573.2,2328.8 L 1574.8,2329.3 z"
   id="path57"
   style="fill:$pagecolor;stroke:$pagecolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1574.8,2329.3 L 1575.8,2329.3 L 1576.8,2329.3 L 1577.8,2329.3 L 1578.3,2329.3 L 1578.8,2329.3 L 1579.4,2329.3 L 1579.9,2329.2 L 1580.4,2329.2 L 1581,2329.1 L 1581.5,2329.1 L 1582.1,2329 L 1582.7,2328.9 L 1583.3,2328.8 C 1584.4,2328.3 1584.9,2328.3 1585.4,2327.8 C 1587,2323 1585.9,2317.2 1584.4,2312.4 C 1583.9,2311.9 1583.3,2311.9 1583.3,2311.3 C 1580.1,2311.9 1576.9,2313.4 1574.8,2315 C 1573.2,2318.8 1571.6,2323 1572.7,2327.3 C 1572.7,2327.8 1573.2,2328.3 1573.2,2328.8 L 1574.8,2329.3 z"
   id="path59"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1525.5,2325.1 L 1526.8,2325.1 L 1528,2325 L 1528.7,2324.9 L 1529.3,2324.9 L 1530,2324.8 L 1530.6,2324.7 L 1531.2,2324.6 L 1531.8,2324.4 L 1532.5,2324.3 L 1533.1,2324.1 L 1533.7,2324 L 1534.3,2323.8 L 1534.9,2323.6 L 1535.4,2323.3 L 1536,2323.1 L 1536.6,2322.8 L 1537.1,2322.5 L 1537.6,2322.2 L 1538.2,2321.9 L 1538.7,2321.6 L 1539.2,2321.2 L 1539.7,2320.9 L 1540.1,2320.5 L 1540.6,2320.1 L 1541,2319.6 L 1541.4,2319.2 L 1541.8,2318.7 L 1542.2,2318.2 L 1542.6,2317.7 L 1543,2317.2 C 1546.7,2312.4 1548.8,2305.5 1547.2,2299.1 C 1547.2,2297.5 1546.7,2296.5 1546.7,2295.4 L 1596,2296.5 C 1596.5,2296.5 1596.5,2295.9 1596.5,2295.4 L 1573.8,2258.3 L 1544.5,2258.3 L 1538.7,2265.2 C 1538.2,2265.2 1537.1,2264.1 1537.1,2263.6 C 1540.9,2258.8 1543.5,2251.9 1541.4,2244.5 C 1538.7,2237.6 1533.4,2230.7 1527.1,2228 C 1519.1,2225.4 1511.1,2230.1 1505.8,2234.9 C 1498.4,2241.8 1493.6,2249.8 1493.1,2260.4 C 1493.1,2262.5 1493.6,2263.6 1494.7,2265.7 C 1495.2,2268.9 1496.8,2270.4 1498.4,2273.1 C 1500.6,2275.8 1502.6,2277.9 1504.8,2279.5 C 1506.9,2281.1 1509,2281.6 1510.6,2284.3 L 1510.6,2285.4 C 1509,2286.9 1507.4,2285.4 1506.4,2284.8 C 1505.3,2283.8 1504.8,2283.8 1504.2,2283.2 C 1500.6,2285.9 1498.9,2289.6 1497.9,2294.4 C 1496.8,2301.8 1498.9,2309.8 1503.7,2314.5 C 1505.8,2316.7 1508,2318.8 1510.1,2319.8 C 1514.9,2322.5 1520.7,2324.6 1525.5,2325.1 z"
   id="path61"
   style="fill:$textcolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1525.5,2325.1 L 1526.8,2325.1 L 1528,2325 L 1528.7,2324.9 L 1529.3,2324.9 L 1530,2324.8 L 1530.6,2324.7 L 1531.2,2324.6 L 1531.8,2324.4 L 1532.5,2324.3 L 1533.1,2324.1 L 1533.7,2324 L 1534.3,2323.8 L 1534.9,2323.6 L 1535.4,2323.3 L 1536,2323.1 L 1536.6,2322.8 L 1537.1,2322.5 L 1537.6,2322.2 L 1538.2,2321.9 L 1538.7,2321.6 L 1539.2,2321.2 L 1539.7,2320.9 L 1540.1,2320.5 L 1540.6,2320.1 L 1541,2319.6 L 1541.4,2319.2 L 1541.8,2318.7 L 1542.2,2318.2 L 1542.6,2317.7 L 1543,2317.2 C 1546.7,2312.4 1548.8,2305.5 1547.2,2299.1 C 1547.2,2297.5 1546.7,2296.5 1546.7,2295.4 L 1596,2296.5 C 1596.5,2296.5 1596.5,2295.9 1596.5,2295.4 L 1573.8,2258.3 L 1544.5,2258.3 L 1538.7,2265.2 C 1538.2,2265.2 1537.1,2264.1 1537.1,2263.6 C 1540.9,2258.8 1543.5,2251.9 1541.4,2244.5 C 1538.7,2237.6 1533.4,2230.7 1527.1,2228 C 1519.1,2225.4 1511.1,2230.1 1505.8,2234.9 C 1498.4,2241.8 1493.6,2249.8 1493.1,2260.4 C 1493.1,2262.5 1493.6,2263.6 1494.7,2265.7 C 1495.2,2268.9 1496.8,2270.4 1498.4,2273.1 C 1500.6,2275.8 1502.6,2277.9 1504.8,2279.5 C 1506.9,2281.1 1509,2281.6 1510.6,2284.3 L 1510.6,2285.4 C 1509,2286.9 1507.4,2285.4 1506.4,2284.8 C 1505.3,2283.8 1504.8,2283.8 1504.2,2283.2 C 1500.6,2285.9 1498.9,2289.6 1497.9,2294.4 C 1496.8,2301.8 1498.9,2309.8 1503.7,2314.5 C 1505.8,2316.7 1508,2318.8 1510.1,2319.8 C 1514.9,2322.5 1520.7,2324.6 1525.5,2325.1 z"
   id="path63"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1678.8,2297 L 1686.2,2297 L 1705.8,2267.3 C 1713.3,2265.7 1718.1,2261.4 1722.8,2255.6 C 1727.1,2249.3 1728.1,2240.2 1725.5,2232.8 C 1721.2,2228 1717,2224.3 1711.2,2224.3 C 1706.4,2225.9 1703.2,2227.5 1701.1,2231.2 C 1701.1,2233.9 1704.8,2234.9 1704.2,2238.6 C 1704.2,2238.6 1704.2,2239.2 1704.2,2239.2 C 1704.2,2239.2 1703.7,2239.7 1703.7,2239.7 C 1699,2233.4 1691,2228.5 1682,2228.5 C 1676.7,2229.6 1671.3,2231.7 1668.7,2236 C 1665.5,2239.7 1665,2245 1666.6,2249.3 C 1668.2,2254.5 1671.9,2258.8 1676.2,2262 C 1676.2,2263 1675.1,2263 1674.6,2263.6 L 1669.8,2261.4 L 1650.7,2295.9 C 1650.7,2297 1651.2,2296.5 1651.8,2297 C 1661.3,2297 1669.8,2297 1678.8,2297 z"
   id="path65"
   style="fill:$textcolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1678.8,2297 L 1686.2,2297 L 1705.8,2267.3 C 1713.3,2265.7 1718.1,2261.4 1722.8,2255.6 C 1727.1,2249.3 1728.1,2240.2 1725.5,2232.8 C 1721.2,2228 1717,2224.3 1711.2,2224.3 C 1706.4,2225.9 1703.2,2227.5 1701.1,2231.2 C 1701.1,2233.9 1704.8,2234.9 1704.2,2238.6 C 1704.2,2238.6 1704.2,2239.2 1704.2,2239.2 C 1704.2,2239.2 1703.7,2239.7 1703.7,2239.7 C 1699,2233.4 1691,2228.5 1682,2228.5 C 1676.7,2229.6 1671.3,2231.7 1668.7,2236 C 1665.5,2239.7 1665,2245 1666.6,2249.3 C 1668.2,2254.5 1671.9,2258.8 1676.2,2262 C 1676.2,2263 1675.1,2263 1674.6,2263.6 L 1669.8,2261.4 L 1650.7,2295.9 C 1650.7,2297 1651.2,2296.5 1651.8,2297 C 1661.3,2297 1669.8,2297 1678.8,2297 z"
   id="path67"
   style="stroke-width:0.21600001;stroke-linecap:square" />
<path
   d="M 1624.7,2296.5 L 1646.4,2296.5 C 1647.5,2296.5 1646.4,2295.4 1645.9,2294.9 C 1640.6,2285.9 1635.8,2277.9 1631,2269.4 C 1628.9,2265.7 1626.3,2262 1624.2,2258.3 C 1624.2,2258.3 1624.2,2258.3 1624.7,2257.8 C 1626.8,2258.8 1628.9,2257.8 1630.5,2256.1 C 1633.7,2252.4 1633.2,2246.6 1632.1,2241.8 C 1630,2235.5 1623.6,2231.2 1617.8,2229.1 C 1614.1,2228 1609.8,2227.5 1607.2,2230.1 C 1605,2233.4 1607.2,2237 1605.6,2239.7 C 1605,2240.2 1604.5,2240.2 1604,2240.2 C 1603.4,2240.2 1602.9,2239.2 1602.4,2238.6 C 1604,2234.4 1601.3,2231.7 1598.1,2229.1 C 1594.9,2226.5 1590.7,2223.8 1585.9,2224.3 C 1582.8,2225.4 1580.6,2228 1578.5,2230.1 C 1576.4,2233.9 1574.3,2239.7 1575.9,2245 C 1576.4,2250.9 1580.1,2255.6 1584.9,2258.8 C 1589.7,2262.5 1595.5,2262.5 1600.8,2262 C 1601.9,2262 1601.3,2262.5 1601.3,2263.6 L 1596,2265.7 L 1615.1,2296.5 L 1624.7,2296.5 z"
   id="path69"
   style="fill:$textcolor;stroke-width:0;stroke-linecap:square" />
<path
   d="M 1624.7,2296.5 L 1646.4,2296.5 C 1647.5,2296.5 1646.4,2295.4 1645.9,2294.9 C 1640.6,2285.9 1635.8,2277.9 1631,2269.4 C 1628.9,2265.7 1626.3,2262 1624.2,2258.3 C 1624.2,2258.3 1624.2,2258.3 1624.7,2257.8 C 1626.8,2258.8 1628.9,2257.8 1630.5,2256.1 C 1633.7,2252.4 1633.2,2246.6 1632.1,2241.8 C 1630,2235.5 1623.6,2231.2 1617.8,2229.1 C 1614.1,2228 1609.8,2227.5 1607.2,2230.1 C 1605,2233.4 1607.2,2237 1605.6,2239.7 C 1605,2240.2 1604.5,2240.2 1604,2240.2 C 1603.4,2240.2 1602.9,2239.2 1602.4,2238.6 C 1604,2234.4 1601.3,2231.7 1598.1,2229.1 C 1594.9,2226.5 1590.7,2223.8 1585.9,2224.3 C 1582.8,2225.4 1580.6,2228 1578.5,2230.1 C 1576.4,2233.9 1574.3,2239.7 1575.9,2245 C 1576.4,2250.9 1580.1,2255.6 1584.9,2258.8 C 1589.7,2262.5 1595.5,2262.5 1600.8,2262 C 1601.9,2262 1601.3,2262.5 1601.3,2263.6 L 1596,2265.7 L 1615.1,2296.5 L 1624.7,2296.5 z"
   id="path71"
   style="stroke-width:0.21600001;stroke-linecap:square" />
</g></svg>
EOF
	return($output);
};

sub svg_chaosknoten() {
	my $output;
	$output .= <<EOF;
<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<svg width="655.055" height="470.179">
EOF

	# background
	$output .= <<EOF;
  <g
     inkscape:groupmode="layer"
     id="background-layer"
     style="display:inline">
    <rect
       style="opacity:1;fill:$pagecolor;fill-opacity:1;fill-rule:evenodd;stroke:$pagecolor;stroke-width:6;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
       id="background-rect"
       width="100pc"
       height="100pc"
       x="0"
       y="0" />
  </g>
EOF

	$output .= <<EOF;
<g>
<path style="stroke:none; fill:$textcolor" d="M 294.407 7.95792C 300.62 8.98492 313.524 28.3799 311.961 63.9999C 307.661 66.2869 302.672 64.9449 299.414 64.8939C 289.23 62.2119 298.736 35.3389 284.461 25.3479C 263.79 10.8809 119.447 14.4069 45.5808 21.1209C 13.592 24.0289 17.478 87.0639 16.8569 120.43C 16.34 148.198 17.3017 178.549 28.2758 209.36C 37.7226 235.884 72.5747 226.769 104.247 227.931C 161.225 227.931 265.228 229.814 277.777 224.806C 286.869 221.177 290.573 207.834 292.486 199.231C 295.837 184.162 292.318 173.624 304.308 173.907C 310.621 174.056 311.863 179.764 310.9 190.679C 309.899 202.025 306.507 217.12 301.772 234.684C 298.351 247.372 274.76 244.813 259.144 244.813C 180.218 242.704 100.45 245.236 24.0554 243.125C 1.9155 242.514 1.46946 137.911 0.285625 118.923C -1.10525 96.6069 2.51438 7.01993 21.3615 6.01993C 35.3674 5.27692 113.628 0.0309143 159.959 0.0189209C 205.016 0.00692749 252.988 1.11093 294.407 7.95792"/>
<path style="stroke:none; fill:$textcolor" d="M 223.69 24.0759C 229.177 39.6919 215.671 64.1719 235.93 72.6129C 309.368 85.2749 395.047 57.8409 457.512 96.2479C 474.394 112.708 487.056 131.701 495.075 151.96L 495.075 142.675C 485.79 116.929 466.797 94.9819 448.648 72.6129C 453.713 65.8599 459.622 73.8789 464.686 75.9889C 483.257 99.2019 502.249 122.838 509.425 150.694C 510.69 152.382 513.223 155.759 515.333 152.804L 518.288 149.85C 511.957 119.884 492.964 95.4039 476.926 69.6579C 484.101 65.0149 491.276 73.0349 497.185 77.6769C 509.425 97.9359 522.931 118.195 527.573 141.83C 530.949 144.362 535.17 139.72 536.858 136.765C 534.326 118.194 527.994 101.734 520.397 86.1179C 521.663 84.0079 521.663 81.0529 524.618 81.0529C 542.767 90.7599 542.345 111.864 548.675 128.324C 554.584 127.902 557.538 109.331 565.135 120.305C 567.667 127.058 555.006 137.61 568.09 138.454C 561.759 168.842 528.416 192.478 499.294 199.231C 484.1 202.607 463.841 207.249 452.445 195.433C 454.555 189.946 462.152 189.102 467.639 188.258C 501.404 186.992 533.481 174.752 553.74 147.74L 552.896 146.896C 520.819 168.421 481.146 189.102 441.472 173.064C 438.096 172.22 436.407 167.577 438.518 165.045C 439.362 162.513 436.83 161.247 435.563 160.824C 368.455 163.778 297.967 154.5 232.97 165.051C 225.84 166.209 225.036 172.797 223.686 178.133C 220.272 191.644 228.896 210.78 220.862 217.979C 220.862 217.979 214.926 219.72 210.606 217.802C 209.595 212.193 206.379 180.658 213.554 163.776C 222.631 142.419 303.508 149.623 326.888 149.15C 369.61 148.287 419.526 146.896 459.622 149.851C 448.226 138.455 430.5 138.033 413.195 138.455C 358.327 137.611 272.591 137.896 237.819 135.989C 186.388 133.167 167.977 184.882 135.478 218.647L 120.284 218.647C 140.543 190.37 162.381 158.125 190.346 133.391C 194.855 129.403 197.991 128.776 205.54 126.639C 226.565 120.686 430.499 127.483 430.499 127.483C 439.784 129.593 449.914 130.859 458.777 134.657C 453.712 121.573 437.252 118.197 424.168 116.51C 351.151 114.4 277.291 116.088 205.54 111.445C 186.125 105.536 175.996 81.4789 160.801 66.7059L 128.302 25.3439L 144.762 26.1879C 165.865 50.6669 180.337 80.6939 207.649 100.048C 213.669 104.314 342.251 103.075 410.233 103.002C 421.193 102.99 444.003 110.177 458.775 118.197C 461.307 114.821 457.087 111.866 454.554 109.334C 423.743 79.7899 360.192 88.9909 337.226 89.0699C 296.941 89.2099 248.993 97.5919 215.667 76.8349C 207.526 71.7639 208.915 40.9599 212.714 24.0769L 223.687 24.0769"/>
<path style="stroke:none; fill:$textcolor" d="M 575.267 153.649C 568.092 184.038 545.723 211.471 517.444 226.666C 499.717 230.465 476.926 242.282 462.576 224.556C 472.284 215.693 490.01 221.602 501.406 214.426C 530.95 205.985 555.264 179.952 570.202 153.649C 572.112 152.328 573.397 150.826 575.267 153.649"/>
<path style="stroke:none; fill:$textcolor" d="M 584.142 179.84C 579.077 206.008 566.415 233.442 539.403 246.526C 527.585 252.013 509.015 258.344 498.041 248.636L 498.041 244.415C 539.825 246.103 560.928 202.209 577.811 172.665C 582.454 172.243 582.876 176.463 584.142 179.84"/>
<path style="stroke:none; fill:$textcolor" d="M 611.567 280.265C 631.446 284.489 650.816 264.65 655.037 290.396C 638.154 299.259 615.363 296.727 597.637 291.662C 593.838 299.259 599.325 307.7 597.637 316.986C 595.105 341.888 585.819 365.523 563.872 380.717C 557.515 384.017 556.195 385.964 552.441 386.626C 553.579 380.924 553.968 376.273 554.941 372.727C 559.287 369.807 578.444 357.507 579.066 341.043C 588.773 306.434 578.222 272.247 555.008 246.923L 570.202 232.995C 579.065 250.721 589.098 275.49 611.566 280.264"/>
<path style="stroke:none; fill:$textcolor" d="M 542.769 257.054C 567.248 304.325 544.457 359.615 538.548 408.152C 541.08 426.301 543.613 444.871 558.807 457.533C 557.119 461.754 559.651 472.305 552.898 469.773C 531.373 458.377 524.198 435.586 524.62 411.951C 523.776 370.167 546.145 336.824 540.658 294.618L 536.86 286.6C 519.555 305.17 500.141 328.384 501.407 357.505L 490.011 359.615C 477.349 319.097 521.666 295.872 527.575 259.575C 527.575 259.575 537.282 255.789 542.769 257.054"/>
</g>
</svg>
EOF
	return($output);
};

sub svg_muenchnereris() {
	my $output;
	$output .= <<EOF;
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   xmlns:dc="http://purl.org/dc/elements/1.1/"
   xmlns:cc="http://creativecommons.org/ns#"
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns:svg="http://www.w3.org/2000/svg"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
   version="1.0"
   width="208.769"
   height="305"
   viewBox="-0.116 5 209 280"
   enable-background="new -0.116 -0.748 209 253"
   xml:space="preserve"
   id="svg2"
   sodipodi:version="0.32"
   inkscape:version="0.46"
   sodipodi:docname="muenchnereris-x.svg"
   sodipodi:docbase="/home/x"
   inkscape:export-filename="/what/a/stupid/idea/to/store/paths/in/image/files"
   inkscape:export-xdpi="86.120003"
   inkscape:export-ydpi="86.120003"
   inkscape:output_extension="org.inkscape.output.svg.inkscape">
<metadata
   id="metadata87">
	<rdf:RDF>
		<cc:Work rdf:about="">
			<dc:format>image/svg+xml</dc:format>
			<dc:type rdf:resource="http://purl.org/dc/dcmitype/StillImage" />
		</cc:Work>
	</rdf:RDF>
</metadata>
<defs
   id="defs85">
	<inkscape:perspective
	   sodipodi:type="inkscape:persp3d"
	   inkscape:vp_x="0 : 126.5 : 1"
	   inkscape:vp_y="0 : 1000 : 0"
	   inkscape:vp_z="209 : 126.5 : 1"
	   inkscape:persp3d-origin="104.5 : 84.333333 : 1"
	   id="perspective160" />
	<clipPath
	   id="clip0">
		<rect
		   id="rect2239"
		   height="160"
		   width="160"
		   x="0"
		   y="0" />
	</clipPath>
</defs>
<sodipodi:namedview
   inkscape:window-height="714"
   inkscape:window-width="1392"
   inkscape:pageshadow="2"
   inkscape:pageopacity="0"
   guidetolerance="10.0"
   gridtolerance="10.0"
   objecttolerance="10.0"
   borderopacity="1.0"
   bordercolor="#666666"
   pagecolor="#ffffff"
   id="base"
   inkscape:zoom="1.6086956"
   inkscape:cx="46.957296"
   inkscape:cy="285.30597"
   inkscape:window-x="0"
   inkscape:window-y="0"
   inkscape:current-layer="layer7"
   showgrid="false" />
<path
   d="M -0.116,43.599725 L -0.116,190.30372 C -0.116,256.10472 53.083,295.42472 104.514,295.42472 C 154.998,295.42472 208.653,258.58172 208.653,190.30372 L 208.653,43.599725 L -0.116,43.599725 z"
   id="wappen-background"
   style="fill:#ffffff" />
<g
   id="eris-head"
   transform="translate(-177.2009,132.46888)">
	<path
   id="path2246"
   d="M 260.13349,-81.147898 C 254.60214,-83.493982 247.92715,-83.08337 242.95318,-79.845884 C 239.53312,-77.89691 236.23974,-74.538642 231.89826,-75.486657 C 231.61794,-77.121633 231.43255,-78.768286 231.30563,-80.418566 C 230.48236,-79.765854 229.65476,-79.117034 228.81333,-78.483168 C 228.91685,-75.91966 229.00262,-72.43137 232.15994,-71.734095 C 239.38096,-70.821168 244.37841,-77.271486 250.84358,-79.043246 C 256.76663,-80.070083 260.70675,-74.311035 265.84014,-72.519656 C 273.64784,-70.773598 282.06666,-75.22671 289.49308,-70.977985 C 300.38897,-65.178949 299.9147,-47.909632 290.35348,-41.498687 C 289.85536,-41.502204 288.8591,-41.509253 288.36097,-41.512769 C 287.98477,-41.613414 287.23234,-41.814689 286.85613,-41.915318 C 286.63598,-38.038549 285.71418,-34.113892 286.59754,-30.232906 C 293.33249,-15.714711 276.62644,-11.605634 276.60888,-31.357188 C 278.62902,-32.977554 280.93148,-34.425625 282.2521,-36.726541 C 283.15032,-38.633909 283.03289,-40.827866 283.17735,-42.893401 C 281.01197,-40.088284 279.62373,-36.481252 276.42628,-34.632761 C 273.76635,-32.871106 270.68248,-31.908122 267.58869,-31.168361 C 267.17713,-33.416847 266.78344,-35.661552 266.97918,-37.956765 C 265.32582,-38.891968 263.70466,-39.882828 262.11103,-40.920156 C 263.19708,-43.981019 263.78717,-47.186403 264.1146,-50.426049 C 266.39772,-50.929521 268.67144,-51.446689 270.92811,-52.044721 C 267.79791,-52.713675 264.64135,-52.331799 261.52903,-51.943033 C 262.16647,-55.198036 263.01713,-58.400989 263.95895,-61.572948 C 268.1672,-62.052299 272.86764,-61.890477 276.34042,-59.026098 C 278.59976,-57.156741 278.53117,-53.975555 279.2062,-51.382197 C 279.79592,-52.270711 280.3818,-53.160529 280.97189,-54.046578 C 282.56959,-53.019628 285.43249,-52.558179 284.98851,-50.099583 C 285.08374,-47.561312 283.06915,-45.740079 281.87439,-43.728724 C 283.30494,-44.197757 284.72633,-44.689604 286.13168,-45.220837 C 286.65539,-46.246619 287.20127,-47.259921 287.72804,-48.282036 C 287.62084,-49.979062 287.70678,-51.746324 287.05075,-53.361877 C 286.15704,-55.420947 283.52459,-55.023037 281.7514,-55.663586 C 281.20948,-58.329549 281.07339,-61.441793 278.82879,-63.364537 C 276.23017,-65.884798 272.45475,-66.02806 269.11177,-66.516784 C 269.02937,-67.132746 268.86459,-68.36467 268.78221,-68.980616 C 265.62942,-66.986766 262.86557,-64.281747 259.20527,-63.180887 C 254.77735,-61.518863 249.95329,-61.756583 245.28483,-61.476464 C 249.85385,-57.989787 255.65564,-58.485217 260.79884,-59.859121 C 260.08274,-56.595913 259.77983,-53.204102 260.92099,-49.953039 C 269.97914,-42.402282 300.32764,-22.374989 291.80267,-28.067363 C 289.23521,-31.055246 288.85092,-35.17737 288.27789,-38.885124 C 294.95028,-39.521852 300.86648,-44.368313 302.59477,-50.835289 C 303.91372,-56.609219 303.52339,-63.101379 300.1397,-68.23623 C 298.0422,-71.950007 294.12202,-74.028794 290.35891,-75.658129 C 282.95072,-77.883719 275.27233,-76.277751 267.80772,-75.767917 C 264.20683,-75.385356 263.1631,-80.01207 260.13349,-81.147898 z"
   style="fill:none;stroke:#000000;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10"
   sodipodi:nodetypes="ccccccccccccccccccccccccccccccccccccccccccccccc" />
	<path
   id="path2248"
   d="M 260.13349,-81.147898 C 254.60214,-83.493982 247.92715,-83.08337 242.95318,-79.845884 C 239.53312,-77.89691 236.23974,-74.538642 231.89826,-75.486657 C 231.61794,-77.121633 231.43255,-78.768286 231.30563,-80.418566 C 230.48236,-79.765854 229.65476,-79.117034 228.81333,-78.483168 C 228.91685,-75.91966 229.00262,-72.43137 232.15994,-71.734095 C 239.38096,-70.821168 244.37841,-77.271486 250.84358,-79.043246 C 256.76663,-80.070083 260.70675,-74.311035 265.84014,-72.519656 C 273.64784,-70.773598 282.06666,-75.22671 289.49308,-70.977985 C 300.38897,-65.178949 299.9147,-47.909632 290.35348,-41.498687 C 289.85536,-41.502204 288.8591,-41.509253 288.36097,-41.512769 C 287.98477,-41.613414 287.23234,-41.814689 286.85613,-41.915318 C 286.63598,-38.038549 285.71418,-34.113892 286.59754,-30.232906 C 287.43487,-27.187023 289.95919,-25.058256 292.03715,-22.823561 C 288.14537,-17.181311 280.5586,-16.065213 274.3769,-18.647361 C 276.97984,-22.366416 276.56874,-27.013833 276.60888,-31.357188 C 278.62902,-32.977554 280.93148,-34.425625 282.2521,-36.726541 C 283.15032,-38.633909 283.03289,-40.827866 283.17735,-42.893401 C 281.01197,-40.088284 279.62373,-36.481252 276.42628,-34.632761 C 273.76635,-32.871106 270.68248,-31.908122 267.58869,-31.168361 C 267.17713,-33.416847 266.78344,-35.661552 266.97918,-37.956765 C 265.32582,-38.891968 263.70466,-39.882828 262.11103,-40.920156 C 263.19708,-43.981019 263.78717,-47.186403 264.1146,-50.426049 C 266.39772,-50.929521 268.67144,-51.446689 270.92811,-52.044721 C 267.79791,-52.713675 264.64135,-52.331799 261.52903,-51.943033 C 262.16647,-55.198036 263.01713,-58.400989 263.95895,-61.572948 C 268.1672,-62.052299 272.86764,-61.890477 276.34042,-59.026098 C 278.59976,-57.156741 278.53117,-53.975555 279.2062,-51.382197 C 279.79592,-52.270711 280.3818,-53.160529 280.97189,-54.046578 C 282.56959,-53.019628 285.43249,-52.558179 284.98851,-50.099583 C 285.08374,-47.561312 283.06915,-45.740079 281.87439,-43.728724 C 283.30494,-44.197757 284.72633,-44.689604 286.13168,-45.220837 C 286.65539,-46.246619 287.20127,-47.259921 287.72804,-48.282036 C 287.62084,-49.979062 287.70678,-51.746324 287.05075,-53.361877 C 286.15704,-55.420947 283.52459,-55.023037 281.7514,-55.663586 C 281.20948,-58.329549 281.07339,-61.441793 278.82879,-63.364537 C 276.23017,-65.884798 272.45475,-66.02806 269.11177,-66.516784 C 269.02937,-67.132746 268.86459,-68.36467 268.78221,-68.980616 C 265.62942,-66.986766 262.86557,-64.281747 259.20527,-63.180887 C 254.77735,-61.518863 249.95329,-61.756583 245.28483,-61.476464 C 249.85385,-57.989787 255.65564,-58.485217 260.79884,-59.859121 C 260.08274,-56.595913 259.77983,-53.204102 260.92099,-49.953039 C 261.93374,-47.091151 260.93997,-44.195862 260.04876,-41.497096 C 259.92629,-41.104859 259.68139,-40.320371 259.55894,-39.928119 C 260.23872,-39.811662 261.59828,-39.578733 262.27807,-39.462261 C 262.95848,-37.518444 264.07171,-35.779698 265.3191,-34.147395 C 265.97341,-32.433018 265.83982,-30.298609 267.25108,-28.945038 C 269.96217,-27.780672 272.61372,-29.570084 275.12887,-30.320608 C 274.33374,-26.670985 271.9438,-22.499526 267.69732,-22.560535 C 263.44435,-14.906634 281.53979,-4.9045496 303.67985,-24.473856 C 300.67384,-24.893192 296.43472,-23.650039 294.7924,-27.069083 C 293.76156,-27.244175 292.52133,-27.116418 291.80267,-28.067363 C 289.23521,-31.055246 288.85092,-35.17737 288.27789,-38.885124 C 294.95028,-39.521852 300.86648,-44.368313 302.59477,-50.835289 C 303.91372,-56.609219 303.52339,-63.101379 300.1397,-68.23623 C 298.0422,-71.950007 294.12202,-74.028794 290.35891,-75.658129 C 282.95072,-77.883719 275.27233,-76.277751 267.80772,-75.767917 C 264.20683,-75.385356 263.1631,-80.01207 260.13349,-81.147898 z"
   style="fill:#000000;fill-rule:nonzero;stroke:none"
   sodipodi:nodetypes="cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc" />
	<path
   id="path2250"
   d="M 265.84014,-72.519656 C 260.70675,-74.311035 256.76663,-80.070083 250.84358,-79.043246 C 244.37841,-77.271486 239.38096,-70.821168 232.15994,-71.734095 C 229.00262,-72.43137 228.91685,-75.91966 228.81333,-78.483168 C 225.90277,-78.473862 224.10585,-76.603396 224.09164,-73.710689 C 223.09454,-73.878476 222.09716,-74.048849 221.09643,-74.215313 C 221.04176,-72.962334 220.9866,-71.70909 220.93093,-70.455553 C 218.73684,-70.380681 216.54075,-70.303381 214.34693,-70.183994 C 213.94811,-68.270838 213.84858,-66.23819 212.99201,-64.462887 C 210.23893,-62.306733 206.23307,-61.536878 204.56877,-58.172424 C 203.01168,-55.089091 204.38832,-51.476271 206.55302,-48.990677 C 206.4985,-55.727715 210.92237,-62.795085 217.75497,-64.09469 C 222.82983,-64.736055 225.97465,-57.90612 223.45809,-54.051287 C 221.72013,-51.724982 218.5904,-52.246434 216.06268,-52.611862 C 215.82563,-53.752204 215.59008,-54.892711 215.35603,-56.033368 C 217.15737,-55.992252 219.56492,-54.579767 220.78929,-56.487932 C 222.16162,-57.814126 221.89578,-60.741309 219.60629,-60.878266 C 213.40342,-61.728625 209.07666,-55.217211 209.96032,-49.520133 C 212.53503,-49.643646 215.1096,-49.773342 217.68835,-49.784005 C 215.95784,-48.758743 214.21647,-47.748857 212.53059,-46.648077 C 216.07371,-46.78232 219.68512,-47.568 222.492,-49.788173 C 228.47921,-54.320208 231.9588,-61.45159 238.32582,-65.579801 C 244.45754,-69.975298 253.11146,-71.624353 259.9384,-67.355661 C 254.9414,-67.361113 249.45729,-68.559934 244.95082,-65.89596 C 235.42044,-60.630241 232.25344,-48.783493 222.74983,-43.484029 C 218.71954,-41.193577 213.87701,-41.716356 209.46647,-42.623027 C 209.80592,-40.544491 210.16227,-38.467522 210.60891,-36.4061 C 213.33978,-36.948972 216.07716,-37.475695 218.856,-37.738048 C 217.49208,-36.58713 216.093,-35.477193 214.71916,-34.334292 C 225.08761,-34.24988 232.07113,-42.621469 238.36784,-49.57613 C 242.19268,-54.087116 248.61833,-54.859257 254.20048,-53.6317 C 249.71945,-51.930012 244.70675,-51.130603 241.01759,-47.862561 C 236.17422,-43.742734 233.91291,-37.173536 228.32238,-33.809846 C 223.3243,-30.333495 216.91276,-30.70971 211.08877,-31.452531 C 211.50816,-28.889084 211.22576,-25.231487 214.16244,-24.050491 C 219.54888,-22.033443 225.19052,-24.563033 229.52656,-27.599329 C 234.64356,-31.008735 237.40895,-36.979757 242.80599,-40.034956 C 246.45205,-42.302099 251.03607,-42.113524 255.13841,-41.196201 C 256.77743,-41.282783 258.41224,-41.411466 260.04876,-41.497096 C 260.93997,-44.195862 261.93374,-47.091151 260.92099,-49.953039 C 259.77983,-53.204102 260.08274,-56.595913 260.79884,-59.859121 C 255.65564,-58.485217 249.85385,-57.989787 245.28483,-61.476464 C 249.95329,-61.756583 254.77735,-61.518863 259.20527,-63.180887 C 262.86557,-64.281747 265.62942,-66.986766 268.78221,-68.980616 C 268.86459,-68.36467 269.02937,-67.132746 269.11177,-66.516784 C 272.45475,-66.02806 276.23017,-65.884798 278.82879,-63.364537 C 281.07339,-61.441793 281.20948,-58.329549 281.7514,-55.663586 C 283.52459,-55.023037 286.15704,-55.420947 287.05075,-53.361877 C 287.70678,-51.746324 287.62084,-49.979062 287.72804,-48.282036 L 287.78907,-47.102807 C 290.78215,-50.393715 291.53198,-54.883523 292.37643,-59.118214 C 293.55235,-56.892327 295.32933,-54.616609 294.87109,-51.971972 C 294.28736,-47.701704 290.98429,-44.631217 288.36097,-41.512769 C 288.8591,-41.509253 289.85536,-41.502204 290.35348,-41.498687 C 299.9147,-47.909632 300.38897,-65.178949 289.49308,-70.977985 C 282.06666,-75.22671 273.64784,-70.773598 265.84014,-72.519656 z"
   style="fill:none;stroke:#c79c63;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2252"
   d="M 265.84014,-72.519656 C 260.70675,-74.311035 256.76663,-80.070083 250.84358,-79.043246 C 244.37841,-77.271486 239.38096,-70.821168 232.15994,-71.734095 C 229.00262,-72.43137 228.91685,-75.91966 228.81333,-78.483168 C 225.90277,-78.473862 224.10585,-76.603396 224.09164,-73.710689 C 223.09454,-73.878476 222.09716,-74.048849 221.09643,-74.215313 C 221.04176,-72.962334 220.9866,-71.70909 220.93093,-70.455553 C 218.73684,-70.380681 216.54075,-70.303381 214.34693,-70.183994 C 213.94811,-68.270838 213.84858,-66.23819 212.99201,-64.462887 C 210.23893,-62.306733 206.23307,-61.536878 204.56877,-58.172424 C 203.01168,-55.089091 204.38832,-51.476271 206.55302,-48.990677 C 206.4985,-55.727715 210.92237,-62.795085 217.75497,-64.09469 C 222.82983,-64.736055 225.97465,-57.90612 223.45809,-54.051287 C 221.72013,-51.724982 218.5904,-52.246434 216.06268,-52.611862 C 215.82563,-53.752204 215.59008,-54.892711 215.35603,-56.033368 C 217.15737,-55.992252 219.56492,-54.579767 220.78929,-56.487932 C 222.16162,-57.814126 221.89578,-60.741309 219.60629,-60.878266 C 213.40342,-61.728625 209.07666,-55.217211 209.96032,-49.520133 C 212.53503,-49.643646 215.1096,-49.773342 217.68835,-49.784005 C 215.95784,-48.758743 214.21647,-47.748857 212.53059,-46.648077 C 216.07371,-46.78232 219.68512,-47.568 222.492,-49.788173 C 228.47921,-54.320208 231.9588,-61.45159 238.32582,-65.579801 C 244.45754,-69.975298 253.11146,-71.624353 259.9384,-67.355661 C 254.9414,-67.361113 249.45729,-68.559934 244.95082,-65.89596 C 235.42044,-60.630241 232.25344,-48.783493 222.74983,-43.484029 C 218.71954,-41.193577 213.87701,-41.716356 209.46647,-42.623027 C 209.80592,-40.544491 210.16227,-38.467522 210.60891,-36.4061 C 213.33978,-36.948972 216.07716,-37.475695 218.856,-37.738048 C 217.49208,-36.58713 216.093,-35.477193 214.71916,-34.334292 C 225.08761,-34.24988 232.07113,-42.621469 238.36784,-49.57613 C 242.19268,-54.087116 248.61833,-54.859257 254.20048,-53.6317 C 249.71945,-51.930012 244.70675,-51.130603 241.01759,-47.862561 C 236.17422,-43.742734 233.91291,-37.173536 228.32238,-33.809846 C 223.3243,-30.333495 216.91276,-30.70971 211.08877,-31.452531 C 211.50816,-28.889084 211.22576,-25.231487 214.16244,-24.050491 C 219.54888,-22.033443 225.19052,-24.563033 229.52656,-27.599329 C 234.64356,-31.008735 237.40895,-36.979757 242.80599,-40.034956 C 246.45205,-42.302099 251.03607,-42.113524 255.13841,-41.196201 C 256.77743,-41.282783 258.41224,-41.411466 260.04876,-41.497096 C 260.93997,-44.195862 261.93374,-47.091151 260.92099,-49.953039 C 259.77983,-53.204102 260.08274,-56.595913 260.79884,-59.859121 C 255.65564,-58.485217 249.85385,-57.989787 245.28483,-61.476464 C 249.95329,-61.756583 254.77735,-61.518863 259.20527,-63.180887 C 262.86557,-64.281747 265.62942,-66.986766 268.78221,-68.980616 C 268.86459,-68.36467 269.02937,-67.132746 269.11177,-66.516784 C 272.45475,-66.02806 276.23017,-65.884798 278.82879,-63.364537 C 281.07339,-61.441793 281.20948,-58.329549 281.7514,-55.663586 C 283.52459,-55.023037 286.15704,-55.420947 287.05075,-53.361877 C 287.70678,-51.746324 287.62084,-49.979062 287.72804,-48.282036 L 287.78907,-47.102807 C 290.78215,-50.393715 291.53198,-54.883523 292.37643,-59.118214 C 293.55235,-56.892327 295.32933,-54.616609 294.87109,-51.971972 C 294.28736,-47.701704 290.98429,-44.631217 288.36097,-41.512769 C 288.8591,-41.509253 289.85536,-41.502204 290.35348,-41.498687 C 299.9147,-47.909632 300.38897,-65.178949 289.49308,-70.977985 C 282.06666,-75.22671 273.64784,-70.773598 265.84014,-72.519656 z"
   style="fill:#c79c63;fill-rule:nonzero;stroke:none" />
	<path
   id="path2254"
   d="M 228.96078,-69.493675 C 226.44473,-70.75669 224.08955,-72.374201 221.35926,-73.161044 C 221.65594,-70.926969 221.98565,-68.202117 224.3341,-67.127021 C 228.45681,-65.309256 233.47433,-65.779641 236.81935,-68.7725 C 234.20335,-68.974388 231.52731,-68.81082 228.96078,-69.493675 z"
   style="fill:none;stroke:#ca6633;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2256"
   d="M 228.96078,-69.493675 C 226.44473,-70.75669 224.08955,-72.374201 221.35926,-73.161044 C 221.65594,-70.926969 221.98565,-68.202117 224.3341,-67.127021 C 228.45681,-65.309256 233.47433,-65.779641 236.81935,-68.7725 C 234.20335,-68.974388 231.52731,-68.81082 228.96078,-69.493675 z"
   style="fill:#ca6633;fill-rule:nonzero;stroke:none" />
	<path
   id="path2258"
   d="M 290.77821,-65.862598 C 285.88566,-69.340364 279.15014,-71.832785 273.51214,-69.065292 C 277.10038,-67.904049 280.95306,-67.520564 284.34494,-65.779056 C 287.18543,-64.248642 286.45478,-60.532934 287.07531,-57.905466 C 288.28329,-58.997752 289.58731,-60.017708 290.54409,-61.350882 C 290.75622,-62.843473 290.71954,-64.357784 290.77821,-65.862598 z"
   style="fill:none;stroke:#ca6633;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2260"
   d="M 290.77821,-65.862598 C 285.88566,-69.340364 279.15014,-71.832785 273.51214,-69.065292 C 277.10038,-67.904049 280.95306,-67.520564 284.34494,-65.779056 C 287.18543,-64.248642 286.45478,-60.532934 287.07531,-57.905466 C 288.28329,-58.997752 289.58731,-60.017708 290.54409,-61.350882 C 290.75622,-62.843473 290.71954,-64.357784 290.77821,-65.862598 z"
   style="fill:#ca6633;fill-rule:nonzero;stroke:none" />
	<path
   id="path2262"
   d="M 259.9384,-67.355661 C 253.11146,-71.624353 244.45754,-69.975298 238.32582,-65.579801 C 231.9588,-61.45159 228.47921,-54.320208 222.492,-49.788173 C 219.68512,-47.568 216.07371,-46.78232 212.53059,-46.648077 C 214.21647,-47.748857 215.95784,-48.758743 217.68835,-49.784005 C 215.1096,-49.773342 212.53503,-49.643646 209.96032,-49.520133 C 209.07666,-55.217211 213.40342,-61.728625 219.60629,-60.878266 C 221.89578,-60.741309 222.16162,-57.814126 220.78929,-56.487932 C 219.56492,-54.579767 217.15737,-55.992252 215.35603,-56.033368 C 215.59008,-54.892711 215.82563,-53.752204 216.06268,-52.611862 C 218.5904,-52.246434 221.72013,-51.724982 223.45809,-54.051287 C 225.97465,-57.90612 222.82983,-64.736055 217.75497,-64.09469 C 210.92237,-62.795085 206.4985,-55.727715 206.55302,-48.990677 C 208.18872,-46.071275 207.4515,-42.917647 207.03227,-39.845134 C 206.55305,-37.148574 208.9568,-35.167066 209.63976,-32.742784 C 209.17729,-29.273563 208.56591,-25.197491 211.41091,-22.440965 C 214.46575,-18.356065 220.07096,-19.126889 224.37391,-19.936357 C 232.3749,-21.793046 236.64974,-29.356673 242.27207,-34.557174 C 245.78918,-38.361529 250.93838,-40.089257 255.98977,-40.782302 L 255.13841,-41.196201 C 251.03607,-42.113524 246.45205,-42.302099 242.80599,-40.034956 C 237.40895,-36.979757 234.64356,-31.008735 229.52656,-27.599329 C 225.19052,-24.563033 219.54888,-22.033443 214.16244,-24.050491 C 211.22576,-25.231487 211.50816,-28.889084 211.08877,-31.452531 C 216.91276,-30.70971 223.3243,-30.333495 228.32238,-33.809846 C 233.91291,-37.173536 236.17422,-43.742734 241.01759,-47.862561 C 244.70675,-51.130603 249.71945,-51.930012 254.20048,-53.6317 C 248.61833,-54.859257 242.19268,-54.087116 238.36784,-49.57613 C 232.07113,-42.621469 225.08761,-34.24988 214.71916,-34.334292 C 216.093,-35.477193 217.49208,-36.58713 218.856,-37.738048 C 216.07716,-37.475695 213.33978,-36.948972 210.60891,-36.4061 C 210.16227,-38.467522 209.80592,-40.544491 209.46647,-42.623027 C 213.87701,-41.716356 218.71954,-41.193577 222.74983,-43.484029 C 232.25344,-48.783493 235.42044,-60.630241 244.95082,-65.89596 C 249.45729,-68.559934 254.9414,-67.361113 259.9384,-67.355661 z"
   style="fill:none;stroke:#000000;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2264"
   d="M 259.9384,-67.355661 C 253.11146,-71.624353 244.45754,-69.975298 238.32582,-65.579801 C 231.9588,-61.45159 228.47921,-54.320208 222.492,-49.788173 C 219.68512,-47.568 216.07371,-46.78232 212.53059,-46.648077 C 214.21647,-47.748857 215.95784,-48.758743 217.68835,-49.784005 C 215.1096,-49.773342 212.53503,-49.643646 209.96032,-49.520133 C 209.07666,-55.217211 213.40342,-61.728625 219.60629,-60.878266 C 221.89578,-60.741309 222.16162,-57.814126 220.78929,-56.487932 C 219.56492,-54.579767 217.15737,-55.992252 215.35603,-56.033368 C 215.59008,-54.892711 215.82563,-53.752204 216.06268,-52.611862 C 218.5904,-52.246434 221.72013,-51.724982 223.45809,-54.051287 C 225.97465,-57.90612 222.82983,-64.736055 217.75497,-64.09469 C 210.92237,-62.795085 206.4985,-55.727715 206.55302,-48.990677 C 208.18872,-46.071275 207.4515,-42.917647 207.03227,-39.845134 C 206.55305,-37.148574 208.9568,-35.167066 209.63976,-32.742784 C 209.17729,-29.273563 208.56591,-25.197491 211.41091,-22.440965 C 214.46575,-18.356065 220.07096,-19.126889 224.37391,-19.936357 C 232.3749,-21.793046 236.64974,-29.356673 242.27207,-34.557174 C 245.78918,-38.361529 250.93838,-40.089257 255.98977,-40.782302 L 255.13841,-41.196201 C 251.03607,-42.113524 246.45205,-42.302099 242.80599,-40.034956 C 237.40895,-36.979757 234.64356,-31.008735 229.52656,-27.599329 C 225.19052,-24.563033 219.54888,-22.033443 214.16244,-24.050491 C 211.22576,-25.231487 211.50816,-28.889084 211.08877,-31.452531 C 216.91276,-30.70971 223.3243,-30.333495 228.32238,-33.809846 C 233.91291,-37.173536 236.17422,-43.742734 241.01759,-47.862561 C 244.70675,-51.130603 249.71945,-51.930012 254.20048,-53.6317 C 248.61833,-54.859257 242.19268,-54.087116 238.36784,-49.57613 C 232.07113,-42.621469 225.08761,-34.24988 214.71916,-34.334292 C 216.093,-35.477193 217.49208,-36.58713 218.856,-37.738048 C 216.07716,-37.475695 213.33978,-36.948972 210.60891,-36.4061 C 210.16227,-38.467522 209.80592,-40.544491 209.46647,-42.623027 C 213.87701,-41.716356 218.71954,-41.193577 222.74983,-43.484029 C 232.25344,-48.783493 235.42044,-60.630241 244.95082,-65.89596 C 249.45729,-68.559934 254.9414,-67.361113 259.9384,-67.355661 z"
   style="fill:#000000;fill-rule:nonzero;stroke:none" />
	<path
   id="path2266"
   d="M 276.34042,-59.026098 C 272.86764,-61.890477 268.1672,-62.052299 263.95895,-61.572948 C 263.01713,-58.400989 262.16647,-55.198036 261.52903,-51.943033 C 264.64135,-52.331799 267.79791,-52.713675 270.92811,-52.044721 C 268.67144,-51.446689 266.39772,-50.929521 264.1146,-50.426049 C 263.78717,-47.186403 263.19708,-43.981019 262.11103,-40.920156 C 263.70466,-39.882828 265.32582,-38.891968 266.97918,-37.956765 C 266.78344,-35.661552 267.17713,-33.416847 267.58869,-31.168361 C 270.68248,-31.908122 273.76635,-32.871106 276.42628,-34.632761 C 279.62373,-36.481252 281.01197,-40.088284 283.17735,-42.893401 C 283.03289,-40.827866 283.15032,-38.633909 282.2521,-36.726541 C 280.93148,-34.425625 278.62902,-32.977554 276.60888,-31.357188 C 276.56874,-27.013833 276.97984,-22.366416 274.3769,-18.647361 C 280.5586,-16.065213 288.14537,-17.181311 292.03715,-22.823561 C 289.95919,-25.058256 287.43487,-27.187023 286.59754,-30.232906 C 285.71418,-34.113892 286.63598,-38.038549 286.85613,-41.915318 C 286.61656,-43.01795 286.37507,-44.119785 286.13168,-45.220837 C 284.72633,-44.689604 283.30494,-44.197757 281.87439,-43.728724 C 283.06915,-45.740079 285.08374,-47.561312 284.98851,-50.099583 C 285.43249,-52.558179 282.56959,-53.019628 280.97189,-54.046578 C 280.3818,-53.160529 279.79592,-52.270711 279.2062,-51.382197 C 278.53117,-53.975555 278.59976,-57.156741 276.34042,-59.026098 z"
   style="fill:none;stroke:#dec7b8;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2268"
   d="M 276.34042,-59.026098 C 272.86764,-61.890477 268.1672,-62.052299 263.95895,-61.572948 C 263.01713,-58.400989 262.16647,-55.198036 261.52903,-51.943033 C 264.64135,-52.331799 267.79791,-52.713675 270.92811,-52.044721 C 268.67144,-51.446689 266.39772,-50.929521 264.1146,-50.426049 C 263.78717,-47.186403 263.19708,-43.981019 262.11103,-40.920156 C 263.70466,-39.882828 265.32582,-38.891968 266.97918,-37.956765 C 266.78344,-35.661552 267.17713,-33.416847 267.58869,-31.168361 C 270.68248,-31.908122 273.76635,-32.871106 276.42628,-34.632761 C 279.62373,-36.481252 281.01197,-40.088284 283.17735,-42.893401 C 283.03289,-40.827866 283.15032,-38.633909 282.2521,-36.726541 C 280.93148,-34.425625 278.62902,-32.977554 276.60888,-31.357188 C 276.56874,-27.013833 276.97984,-22.366416 274.3769,-18.647361 C 280.5586,-16.065213 288.14537,-17.181311 292.03715,-22.823561 C 289.95919,-25.058256 287.43487,-27.187023 286.59754,-30.232906 C 285.71418,-34.113892 286.63598,-38.038549 286.85613,-41.915318 C 286.61656,-43.01795 286.37507,-44.119785 286.13168,-45.220837 C 284.72633,-44.689604 283.30494,-44.197757 281.87439,-43.728724 C 283.06915,-45.740079 285.08374,-47.561312 284.98851,-50.099583 C 285.43249,-52.558179 282.56959,-53.019628 280.97189,-54.046578 C 280.3818,-53.160529 279.79592,-52.270711 279.2062,-51.382197 C 278.53117,-53.975555 278.59976,-57.156741 276.34042,-59.026098 z"
   style="fill:#f9b385;fill-opacity:1;fill-rule:nonzero;stroke:none" />
	<path
   id="path2270"
   d="M 294.87109,-51.971972 C 295.32933,-54.616609 293.55235,-56.892327 292.37643,-59.118214 C 291.53198,-54.883523 290.78215,-50.393715 287.78907,-47.102807 L 287.72804,-48.282036 C 287.20127,-47.259921 286.65539,-46.246619 286.13168,-45.220837 C 286.37507,-44.119785 286.61656,-43.01795 286.85613,-41.915318 C 287.23234,-41.814689 287.98477,-41.613414 288.36097,-41.512769 C 290.98429,-44.631217 294.28736,-47.701704 294.87109,-51.971972 z"
   style="fill:none;stroke:#ca6633;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2272"
   d="M 294.87109,-51.971972 C 295.32933,-54.616609 293.55235,-56.892327 292.37643,-59.118214 C 291.53198,-54.883523 290.78215,-50.393715 287.78907,-47.102807 L 287.72804,-48.282036 C 287.20127,-47.259921 286.65539,-46.246619 286.13168,-45.220837 C 286.37507,-44.119785 286.61656,-43.01795 286.85613,-41.915318 C 287.23234,-41.814689 287.98477,-41.613414 288.36097,-41.512769 C 290.98429,-44.631217 294.28736,-47.701704 294.87109,-51.971972 z"
   style="fill:#ca6633;fill-rule:nonzero;stroke:none" />
	<path
   id="path2274"
   d="M 258.3341,-44.196523 C 257.46434,-50.078385 250.25704,-50.927017 245.76399,-49.127585 C 242.49673,-47.723317 240.76612,-44.283005 240.55204,-40.833562 C 243.20462,-42.180904 245.55316,-44.030961 248.19718,-45.384199 C 251.51304,-46.840209 255.1044,-45.267291 258.3341,-44.196523 z"
   style="fill:none;stroke:#ca6633;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2276"
   d="M 258.3341,-44.196523 C 257.46434,-50.078385 250.25704,-50.927017 245.76399,-49.127585 C 242.49673,-47.723317 240.76612,-44.283005 240.55204,-40.833562 C 243.20462,-42.180904 245.55316,-44.030961 248.19718,-45.384199 C 251.51304,-46.840209 255.1044,-45.267291 258.3341,-44.196523 z"
   style="fill:#ca6633;fill-rule:nonzero;stroke:none" />
	<path
   id="path2278"
   d="M 270.64444,-48.382712 C 268.51399,-48.113586 266.40324,-47.733583 264.28874,-47.366054 C 265.14996,-46.700672 266.24232,-44.481871 267.46565,-45.75566 C 268.59944,-46.540633 269.61967,-47.468009 270.64444,-48.382712 z"
   style="fill:none;stroke:#000000;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2280"
   d="M 270.64444,-48.382712 C 268.51399,-48.113586 266.40324,-47.733583 264.28874,-47.366054 C 265.14996,-46.700672 266.24232,-44.481871 267.46565,-45.75566 C 268.59944,-46.540633 269.61967,-47.468009 270.64444,-48.382712 z"
   style="fill:#000000;fill-rule:nonzero;stroke:none" />
	<path
   id="path2282"
   d="M 308.99534,-18.184579 C 304.96722,-22.079505 298.98599,-20.389287 294.07205,-21.910309 C 291.32994,-16.402718 284.51196,-14.613016 278.73849,-15.377737 C 275.94601,-15.777503 273.92567,-17.978811 271.48059,-19.183168 C 267.91522,-19.414023 264.22715,-19.084891 261.04878,-17.417074 C 261.0487,-17.092932 261.04853,-16.444666 261.04846,-16.120526 C 266.42092,-13.943507 271.81858,-11.162404 277.69885,-11.052929 C 288.63055,-10.459053 299.16404,-13.992109 308.99534,-18.184579 z"
   style="fill:none;stroke:#dec7b8;stroke-width:0.1;stroke-linecap:butt;stroke-linejoin:miter;stroke-miterlimit:10" />
	<path
   id="path2284"
   d="M 308.99534,-18.184579 C 304.96722,-22.079505 298.98599,-20.389287 294.07205,-21.910309 C 291.32994,-16.402718 284.51196,-14.613016 278.73849,-15.377737 C 275.94601,-15.777503 273.92567,-17.978811 271.48059,-19.183168 C 267.91522,-19.414023 264.22715,-19.084891 261.04878,-17.417074 C 261.0487,-17.092932 261.04853,-16.444666 261.04846,-16.120526 C 266.42092,-13.943507 271.81858,-11.162404 277.69885,-11.052929 C 288.63055,-10.459053 299.16404,-13.992109 308.99534,-18.184579 z"
   style="fill:#f9b385;fill-opacity:1;fill-rule:nonzero;stroke:none" />
</g>
<g
   style="fill:#ffc700;fill-opacity:1;stroke:#745300;stroke-width:27.13714218;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
   id="eris-kallisti"
   transform="matrix(1.36081e-2,0,0,-1.596593e-2,128.6174,143.86872)">
	<desc
   id="desc2342">Golden Apple of Eris</desc>
	<path
   style="fill:#ffc700;fill-opacity:1;stroke:#745300;stroke-width:27.13714218;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
   d="M 3602.13,3255.08 C 3258.12,2942.85 3412.92,2157.98 4031.46,1955.14 C 4313.26,1864.28 4665.74,1886.19 4924.41,2081.33 C 5136.61,2238.53 5313,2468.34 5281.22,2933.87 C 5263.18,3195.58 4871.97,3665.46 4358.61,3377.42 C 4217.28,3449.57 3946.84,3572.68 3602.14,3255.08 L 3602.13,3255.08 z"
   id="path2344" />
	<path
   style="fill:#ffc700;fill-opacity:1;stroke:#745300;stroke-width:27.13714218;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1"
   d="M 4394.16,3624.72 C 4606.36,3620.95 4849.02,3694.53 4859.86,4051.17 C 4761.85,4060.97 4477.19,4008.27 4457.05,3741.36 C 4442.63,3545.6 4368.28,3642.75 4337.79,3786.86 C 4291.47,3772.58 4325.27,3784.39 4263.9,3760.91 C 4415.72,3515.06 4343.36,3387.47 4372.53,3389.69 C 4405.11,3392.18 4395.02,3505.86 4394.17,3624.74 L 4394.16,3624.72 z"
   id="path2346" />
</g>
<g
   style="fill:none;stroke:#000000;stroke-width:38.53789902;stroke-linecap:round;stroke-linejoin:round"
   id="g2348"
   transform="matrix(1.347712e-2,0,0,-1.478303e-2,129.2003,143.04324)">
	<desc
   id="desc2350">&quot;To the prettiest one&quot; (Kallisti) inscription: καλλιστι (καλλιστῃ)</desc>
	<path
   d="M 3598.62,2858.71 C 3619.18,2868.73 3629.5,2888.17 3639.34,2882.66 C 3683.4,2858.39 3578.87,2550.76 3587.27,2577.22 C 3610.7,2648.89 3785.51,2891.98 3773.85,2882.39 C 3766.46,2877.08 3677.71,2728.34 3691.95,2601.1 C 3697.77,2556.01 3728.72,2585.43 3757.63,2638.29"
   id="path2352" />
	<path
   d="M 4021.44,2874.16 C 3992.2,2791.44 3904.38,2569.52 3842.36,2575.27 C 3769.72,2581.84 3826.32,2860.69 3915.64,2865.72 C 3976.34,2869.03 3894.45,2444.99 3987.69,2618.27"
   id="path2354" />
	<path
   d="M 4054.45,3032.15 C 4191.78,3208.74 4057.98,2432.97 4206.17,2604.54"
   id="path2356" />
	<path
   d="M 4027,2577.1 L 4123.76,2877.6"
   id="path2358" />
	<path
   d="M 4278.11,3035.58 C 4415.44,3212.17 4281.64,2436.4 4429.83,2607.97"
   id="path2360" />
	<path
   d="M 4250.63,2580.51 L 4347.39,2881.01"
   id="path2362" />
	<path
   d="M 4510.32,2891.34 C 4493.1,2715.89 4438.28,2443.27 4559,2668.08"
   id="path2364" />
	<path
   d="M 4802.63,2861.05 C 4776.86,2877.29 4714.51,2911.04 4667.05,2850.28 C 4621.84,2791.29 4592.76,2595.97 4679.3,2577.28 C 4733.16,2564.49 4816.33,2808.59 4705.35,2826.06"
   id="path2366" />
	<path
   d="M 4945.57,2860.42 C 4916.33,2683.25 4852.92,2474.18 4971.92,2644.03"
   id="path2368" />
	<path
   style="fill:#000000;stroke:none"
   d="M 5043.48,2917.82 C 5028.84,2827.34 4994.3,2832.56 4942.9,2836.12 C 4882.94,2840.27 4891.17,2852.78 4851.47,2784.46 L 4838.46,2785.25 C 4864.67,2924.52 4912.84,2881.75 4968.63,2879.4 C 4995.02,2878.3 5011.89,2885.07 5029.23,2917.82 L 5043.49,2917.82"
   id="path2370" />
	<path
   d="M 5095.36,2886.2 C 5078.14,2710.75 5023.32,2438.13 5144.04,2662.94"
   id="path2372" />
</g>
<path
   d="M 1.915,45.631725 L 1.915,190.30372 C 1.915,228.69072 19.592,252.82472 34.421,266.30972 C 53.349,283.52172 78.897,293.39372 104.513,293.39372 C 154.012,293.39372 206.619,257.26272 206.619,190.30372 L 206.619,45.631725 L 1.915,45.631725 z M 202.683,49.568725 C 202.683,53.397725 202.683,190.30372 202.683,190.30372 C 202.683,254.70472 152.105,289.45672 104.514,289.45672 C 79.864,289.45672 55.282,279.95872 37.07,263.39572 C 22.829,250.44472 5.852,227.24972 5.852,190.30272 C 5.852,190.30272 5.852,53.396725 5.852,49.567725 C 9.674,49.568725 198.863,49.568725 202.683,49.568725 z"
   id="wappen-frame" />
<g
   id="eris-foot-right"
   transform="translate(-0.116,43.599725)">
	<path
   d="M 95.259,192.663 L 95.259,207.27 L 73.259,221.788 C 73.259,221.788 71.739,222.861 71.364,222.361 C 70.989,221.861 71.759,217.663 72.259,215.788 C 72.759,213.913 73.401,211.709 75.634,209.663 C 78.527,207.014 82.259,202.288 83.509,200.288 C 84.759,198.288 85.509,198.341 85.509,194.788 C 85.509,192.913 85.634,192.648 85.634,192.648 L 95.259,192.663 z"
   id="path12"
   style="fill:#c20000" />
</g>
<g
   id="eris-foot-left"
   transform="translate(-0.116,43.599725)">
	<path
   d="M 113.036,206.55 L 134.916,221.276 C 134.916,221.276 136.081,221.747 136.446,221.538 C 136.811,221.329 136.454,220.023 136.326,218.967 C 135.961,215.939 134.342,210.351 133.089,209.463 C 128.066,205.904 126.092,202.936 125.047,201.265 C 123.818,199.298 122.436,197.349 122.436,194.529 C 122.436,193.328 122.436,192.545 122.436,192.545 L 113.037,192.545 L 113.037,206.55 L 113.036,206.55 z"
   id="path16"
   style="fill:#c20000" />
</g>
<g
   id="eris-hand-left"
   transform="translate(-0.116,43.599725)">
	<path
   d="M 163.576,62.283 C 166.885,61.612 167.978,60.861 167.978,60.861 L 167.978,54.741 L 177.199,50.565 C 177.199,50.565 178.483,49.926 179.259,49.926 C 180.253,49.926 180.886,50.345 181.247,50.707 C 181.64,51.1 181.776,51.809 181.411,52.06 C 181.119,52.261 174.184,56.452 174.184,56.452 L 180.252,67.82 L 163.565,76.767 L 163.576,62.283 z"
   id="path24"
   style="fill:#f9b385" />
	<path
   d="M 173.843,56.371 C 173.843,56.371 173.947,60.314 173.447,61.647 C 172.947,62.98 171.774,65.233 170.4,65.772 C 169.603,66.085 167.9,65.678 168.051,66.788 C 168.194,67.833 168.829,68.121 169.968,67.788 C 171.947,67.21 174.697,65.069 175.385,61.663 C 175.97,58.769 175.712,57.877 175.822,57.538 C 175.978,57.054 179.441,55.179 181.01,54.304 C 182.085,53.704 183.401,53.07 183.052,52.455 C 182.758,51.936 182.155,51.393 181.427,51.913 C 180.071,52.881 173.843,56.371 173.843,56.371 z"
   id="path62" />
</g>
<g
   id="eris-hand-right"
   transform="translate(-0.116,43.599725)">
	<path
   d="M 44.894,76.395 L 44.894,61.967 C 44.894,61.967 43.644,61.459 42.769,61.043 C 41.201,60.296 40.348,59.53 40.348,59.53 L 40.348,53.93 C 40.348,53.93 32.685,47.418 30.81,45.209 C 29.78,43.996 29.217,43.766 28.867,45.397 C 28.679,46.272 28.609,47.251 28.687,49.055 C 28.726,49.959 30.664659,50.613224 29.807659,50.152224 C 27.469718,46.196997 24.781165,44.486587 21.848981,41.543012 C 19.001384,42.305224 21.86812,43.259286 21.036877,42.420191 C 18.990096,40.355276 24.152956,48.727976 26.015504,50.168413 C 26.594219,50.891379 25.729127,51.471327 24.807192,51.304629 C 22.413149,50.871753 16.671829,48.368093 16.476,48.617329 C 16.047,49.162329 15.39,49.513 15.913,49.958 C 16.065,50.087 17.945,51.163 20.007,52.521 C 22.304,54.035 24.945,55.99 24.945,55.99 C 24.945,55.99 23.994,56.683 23.632,56.834 C 22.507,57.303 22.663,58.209 22.788,58.772 C 23.012,59.779 22.257,60.022 21.694,60.678 C 21.173,61.286 20.163,62.241 21.663,62.866 C 21.947,62.985 29.32,66.178 31.632,67.304 C 38.884,70.834 44.894,76.395 44.894,76.395 z"
   id="path28"
   sodipodi:nodetypes="ccsccsssccscsssscsssssc"
   style="fill:#f9b385" />
	<g
   id="g52">
		<path
   d="M 28.874,48.327 C 28.395,48.356 28.951,50.209 29.873,51.153 C 30.522,51.818 32.258,53.627 32.623,54.277 C 33.584,55.994 32.966,59.726 33.634,61.059 C 34.174,62.137 35.481,64.322 37.62,64.212 C 39.285,64.127 39.048,63.261 38.334,62.903 C 37.62,62.545 35.525,62.48 34.788,60.023 C 34.082,57.669 35.37,55.864 33.216,52.676 C 31.986,50.858 29.676,48.278 28.874,48.327 z"
   id="path54" />
	</g>
	<g
   id="g56">
		<path
   d="M 28.668,58.156 C 29.34,58.681 29.749,60.392 30.535,60.22 C 31.356,60.04 31.125,58.893 30.363,57.984 C 29.601,57.075 28.176,55.861 27.39,55.846 C 26.038,55.821 25.008,56.043 24.392,56.263 C 23.704,56.509 23.557,57.025 23.778,57.221 C 24.103,57.51 24.331,57.416 24.958,57.295 C 25.72,57.148 27.317,57.099 28.668,58.156 z"
   id="path58" />
	</g>
</g>
<path
   d="M 24.596,102.61572 C 25.329,102.53072 26.463,102.93572 27.25,103.86872 C 28.037,104.80172 29.068,106.07972 28.38,106.39972 C 27.692,106.71972 27.495,106.10472 26.955,105.53972 C 26.415,104.97472 25.186,103.69672 24.326,103.74572 C 23.605,103.78672 23.271,104.26172 22.704,104.26172 C 22.311,104.26172 22.163,103.86872 22.385,103.52472 C 22.607,103.18072 22.9,102.81172 24.596,102.61572 z"
   id="path60" />
<path
   d="M 112.19617,101.46298 C 114.25717,104.08898 126.331,109.26172 137.331,109.76172 C 148.331,110.26172 163.461,105.88272 163.461,105.88272 L 163.436,238.13672 C 163.436,238.13672 154.894,237.76172 149.457,234.13672 C 146.482,232.15372 144.332,227.94872 143.894,226.38672 C 143.074,223.45472 142.769,220.44872 142.769,220.44872 L 142.769,155.71972 C 142.769,155.71972 142.102,151.21972 139.769,147.38672 C 137.436,143.55372 129.769,135.88672 129.769,135.88672 L 129.769,236.38672 L 77.269,236.38672 L 77.269,138.38672 C 77.269,138.38672 68.887,147.49772 67.221,149.99772 C 65.555,152.49772 65.436,152.85872 65.436,156.05372 C 65.436,157.38672 65.436,215.32472 65.436,215.32472 C 65.436,215.32472 65.433,223.22172 64.332,225.69972 C 63.082,228.51272 60.725,232.38172 53.769,235.44972 C 49.519,237.32472 44.769,237.05372 44.769,237.05372 L 44.769,105.55372 C 44.769,105.55372 49.034,107.43072 54.144,108.82472 C 59.644,110.32472 68.656,110.71172 75.894,109.38772 C 86.373,107.47072 95.061,105.91646 95.061,105.91646 L 96.152385,105.36548 C 98.333928,104.192 97.048049,104.40639 97.475671,103.66989 C 99.476977,102.93361 102.36966,103.15792 104.82028,103.03441 C 106.12382,102.96871 111.48634,100.35063 112.19617,101.46298 z"
   id="path34"
   sodipodi:nodetypes="csccssccsccccsscssccsscccsc" />
<g
   id="eris-collar"
   style="fill:#e3cc0b;fill-opacity:1"
   transform="translate(-0.116,43.599725)">
	<path
   d="M 103.972,78.669 C 110.178,78.669 117.167,76.317 121.283,72.986 C 125.399,69.655 128.141,65.67 128.141,65.67 L 130.82,66.911 C 130.82,66.911 129.182,70.281 125.724,73.378 C 120.107,78.408 113.902,81.608 104.103,81.608 C 93.064,81.608 87.643,78.733 83.331,75.99 C 76.698,71.77 75.493,66.975 75.493,66.975 L 77.975,66.257 C 77.975,66.257 79.282,70.307 85.487,73.965 C 91.692,77.623 97.505,78.669 103.972,78.669 z"
   id="path38"
   style="fill:#e3cc0b;fill-opacity:1" />
</g>
<g
   inkscape:groupmode="layer"
   id="layer1"
   inkscape:label="µc³"
EOF
	if ( $ornament eq "µc³" ) {
		$output .= <<EOF;
   style="opacity:1;display:inline"
EOF
	} else {
		$output .= <<EOF;
   style="display:none"
EOF
	};
	$output .= <<EOF;
   transform="translate(-0.116,43.599725)">
	<g
   id="g2219"
   style="opacity:0.4;fill:#ffffff;fill-opacity:1;display:inline"
   transform="matrix(5e-2,0,0,5e-2,86.51379,95.89688)">
		<path
   style="fill:#ffffff;stroke:none"
   d="M 294.407,7.95792 C 300.62,8.98492 313.524,28.3799 311.961,63.9999 C 307.661,66.2869 302.672,64.9449 299.414,64.8939 C 289.23,62.2119 298.736,35.3389 284.461,25.3479 C 263.79,10.8809 119.447,14.4069 45.5808,21.1209 C 13.592,24.0289 17.478,87.0639 16.8569,120.43 C 16.34,148.198 17.3017,178.549 28.2758,209.36 C 37.7226,235.884 72.5747,226.769 104.247,227.931 C 161.225,227.931 265.228,229.814 277.777,224.806 C 286.869,221.177 290.573,207.834 292.486,199.231 C 295.837,184.162 292.318,173.624 304.308,173.907 C 310.621,174.056 311.863,179.764 310.9,190.679 C 309.899,202.025 306.507,217.12 301.772,234.684 C 298.351,247.372 274.76,244.813 259.144,244.813 C 180.218,242.704 100.45,245.236 24.0554,243.125 C 1.9155,242.514 1.46946,137.911 0.285625,118.923 C -1.10525,96.6069 2.51438,7.01993 21.3615,6.01993 C 35.3674,5.27692 113.628,0.0309143 159.959,0.0189209 C 205.016,0.00692749 252.988,1.11093 294.407,7.95792"
   id="path2221" />
		<path
   style="fill:#ffffff;stroke:none"
   d="M 223.69,24.0759 C 229.177,39.6919 215.671,64.1719 235.93,72.6129 C 309.368,85.2749 395.047,57.8409 457.512,96.2479 C 474.394,112.708 487.056,131.701 495.075,151.96 L 495.075,142.675 C 485.79,116.929 466.797,94.9819 448.648,72.6129 C 453.713,65.8599 459.622,73.8789 464.686,75.9889 C 483.257,99.2019 502.249,122.838 509.425,150.694 C 510.69,152.382 513.223,155.759 515.333,152.804 L 518.288,149.85 C 511.957,119.884 492.964,95.4039 476.926,69.6579 C 484.101,65.0149 491.276,73.0349 497.185,77.6769 C 509.425,97.9359 522.931,118.195 527.573,141.83 C 530.949,144.362 535.17,139.72 536.858,136.765 C 534.326,118.194 527.994,101.734 520.397,86.1179 C 521.663,84.0079 521.663,81.0529 524.618,81.0529 C 542.767,90.7599 542.345,111.864 548.675,128.324 C 554.584,127.902 557.538,109.331 565.135,120.305 C 567.667,127.058 555.006,137.61 568.09,138.454 C 561.759,168.842 528.416,192.478 499.294,199.231 C 484.1,202.607 463.841,207.249 452.445,195.433 C 454.555,189.946 462.152,189.102 467.639,188.258 C 501.404,186.992 533.481,174.752 553.74,147.74 L 552.896,146.896 C 520.819,168.421 481.146,189.102 441.472,173.064 C 438.096,172.22 436.407,167.577 438.518,165.045 C 439.362,162.513 436.83,161.247 435.563,160.824 C 368.455,163.778 297.967,154.5 232.97,165.051 C 225.84,166.209 225.036,172.797 223.686,178.133 C 220.272,191.644 228.896,210.78 220.862,217.979 C 220.862,217.979 214.926,219.72 210.606,217.802 C 209.595,212.193 206.379,180.658 213.554,163.776 C 222.631,142.419 303.508,149.623 326.888,149.15 C 369.61,148.287 419.526,146.896 459.622,149.851 C 448.226,138.455 430.5,138.033 413.195,138.455 C 358.327,137.611 272.591,137.896 237.819,135.989 C 186.388,133.167 167.977,184.882 135.478,218.647 L 120.284,218.647 C 140.543,190.37 162.381,158.125 190.346,133.391 C 194.855,129.403 197.991,128.776 205.54,126.639 C 226.565,120.686 430.499,127.483 430.499,127.483 C 439.784,129.593 449.914,130.859 458.777,134.657 C 453.712,121.573 437.252,118.197 424.168,116.51 C 351.151,114.4 277.291,116.088 205.54,111.445 C 186.125,105.536 175.996,81.4789 160.801,66.7059 L 128.302,25.3439 L 144.762,26.1879 C 165.865,50.6669 180.337,80.6939 207.649,100.048 C 213.669,104.314 342.251,103.075 410.233,103.002 C 421.193,102.99 444.003,110.177 458.775,118.197 C 461.307,114.821 457.087,111.866 454.554,109.334 C 423.743,79.7899 360.192,88.9909 337.226,89.0699 C 296.941,89.2099 248.993,97.5919 215.667,76.8349 C 207.526,71.7639 208.915,40.9599 212.714,24.0769 L 223.687,24.0769"
   id="path2223" />
		<path
   style="fill:#ffffff;stroke:none"
   d="M 575.267,153.649 C 568.092,184.038 545.723,211.471 517.444,226.666 C 499.717,230.465 476.926,242.282 462.576,224.556 C 472.284,215.693 490.01,221.602 501.406,214.426 C 530.95,205.985 555.264,179.952 570.202,153.649 C 572.112,152.328 573.397,150.826 575.267,153.649"
   id="path2225" />
		<path
   style="fill:#ffffff;stroke:none"
   d="M 584.142,179.84 C 579.077,206.008 566.415,233.442 539.403,246.526 C 527.585,252.013 509.015,258.344 498.041,248.636 L 498.041,244.415 C 539.825,246.103 560.928,202.209 577.811,172.665 C 582.454,172.243 582.876,176.463 584.142,179.84"
   id="path2227" />
		<path
   style="fill:#ffffff;stroke:none"
   d="M 611.567,280.265 C 631.446,284.489 650.816,264.65 655.037,290.396 C 638.154,299.259 615.363,296.727 597.637,291.662 C 593.838,299.259 599.325,307.7 597.637,316.986 C 595.105,341.888 585.819,365.523 563.872,380.717 C 557.515,384.017 556.195,385.964 552.441,386.626 C 553.579,380.924 553.968,376.273 554.941,372.727 C 559.287,369.807 578.444,357.507 579.066,341.043 C 588.773,306.434 578.222,272.247 555.008,246.923 L 570.202,232.995 C 579.065,250.721 589.098,275.49 611.566,280.264"
   id="path2229" />
		<path
   style="stroke:none"
   d="M 542.769,257.054 C 567.248,304.325 544.457,359.615 538.548,408.152 C 541.08,426.301 543.613,444.871 558.807,457.533 C 557.119,461.754 559.651,472.305 552.898,469.773 C 531.373,458.377 524.198,435.586 524.62,411.951 C 523.776,370.167 546.145,336.824 540.658,294.618 L 536.86,286.6 C 519.555,305.17 500.141,328.384 501.407,357.505 L 490.011,359.615 C 477.349,319.097 521.666,295.872 527.575,259.575 C 527.575,259.575 537.282,255.789 542.769,257.054"
   id="path2231" />
		<path
   style="fill-rule:evenodd;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:0.25098039"
   d="M 488.47856,375 C 456.38563,375 469.68577,392 471.508,392 C 518.88908,392 518.88908,392 518.88908,385 C 518.88908,375 523.88908,375 506.86334,375 C 498.48597,375 498.69368,375 488.47856,375 L 488.47856,375 L 488.47856,375 z"
   id="path1928" />
	</g>
	<g
   style="opacity:1;display:inline"
   id="g2993"
   transform="matrix(5e-2,0,0,5e-2,37.08229,99.72388)">
		<rect
   style="opacity:1;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="763.96448"
   x="1506.5787"
   height="305.51559"
   width="406.72153"
   id="rect3000"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.5;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="762.71448"
   x="1505.3287"
   height="308.01559"
   width="409.22153"
   id="rect3001"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.33333333;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="761.46448"
   x="1504.0787"
   height="310.51559"
   width="411.72153"
   id="rect3002"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.25;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="760.21448"
   x="1502.8287"
   height="313.01559"
   width="414.22153"
   id="rect3003"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.2;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="758.96448"
   x="1501.5787"
   height="315.51559"
   width="416.72153"
   id="rect3004"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.16666667;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="757.71448"
   x="1500.3287"
   height="318.01559"
   width="419.22153"
   id="rect3005"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.14285715;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="756.46448"
   x="1499.0787"
   height="320.51559"
   width="421.72153"
   id="rect3006"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.125;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="755.21448"
   x="1497.8287"
   height="323.01559"
   width="424.22153"
   id="rect3007"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.11111109;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="753.96448"
   x="1496.5787"
   height="325.51559"
   width="426.72153"
   id="rect3008"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.1;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="752.71448"
   x="1495.3287"
   height="328.01559"
   width="429.22153"
   id="rect3009"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.09090911;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="751.46448"
   x="1494.0787"
   height="330.51559"
   width="431.72153"
   id="rect3010"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.08333333;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="750.21448"
   x="1492.8287"
   height="333.01559"
   width="434.22153"
   id="rect3011"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.07692309;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="748.96448"
   x="1491.5787"
   height="335.51559"
   width="436.72153"
   id="rect3012"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.07142855;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="747.71448"
   x="1490.3287"
   height="338.01559"
   width="439.22153"
   id="rect3013"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.06666667;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="746.46448"
   x="1489.0787"
   height="340.51559"
   width="441.72153"
   id="rect3014"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.0625;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="745.21448"
   x="1487.8287"
   height="343.01559"
   width="444.22153"
   id="rect3015"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.05882353;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="743.96448"
   x="1486.5787"
   height="345.51559"
   width="446.72153"
   id="rect3016"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.05555558;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="742.71448"
   x="1485.3287"
   height="348.01559"
   width="449.22153"
   id="rect3017"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.05263157;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="741.46448"
   x="1484.0787"
   height="350.51559"
   width="451.72153"
   id="rect3018"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.05;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="740.21448"
   x="1482.8287"
   height="353.01559"
   width="454.22153"
   id="rect3019"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.04761903;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="738.96448"
   x="1481.5787"
   height="355.51559"
   width="456.72153"
   id="rect3020"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.04545456;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="737.71448"
   x="1480.3287"
   height="358.01559"
   width="459.22153"
   id="rect3021"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.04347827;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="736.46448"
   x="1479.0787"
   height="360.51559"
   width="461.72153"
   id="rect3022"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.04166667;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="735.21448"
   x="1477.8287"
   height="363.01559"
   width="464.22153"
   id="rect3023"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.03999999;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="733.96448"
   x="1476.5787"
   height="365.51559"
   width="466.72153"
   id="rect3024"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.03846154;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="732.71448"
   x="1475.3287"
   height="368.01559"
   width="469.22153"
   id="rect3025"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.03703703;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="731.46448"
   x="1474.0787"
   height="370.51559"
   width="471.72153"
   id="rect3026"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.0357143;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="730.21448"
   x="1472.8287"
   height="373.01559"
   width="474.22153"
   id="rect3027"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.03448277;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="728.96448"
   x="1471.5787"
   height="375.51559"
   width="476.72153"
   id="rect3028"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.03333333;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="727.71448"
   x="1470.3287"
   height="378.01559"
   width="479.22153"
   id="rect3029"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.03225804;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="726.46448"
   x="1469.0787"
   height="380.51559"
   width="481.72153"
   id="rect3030"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.03125;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="725.21448"
   x="1467.8287"
   height="383.01559"
   width="484.22153"
   id="rect3031"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.03030306;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="723.96448"
   x="1466.5787"
   height="385.51559"
   width="486.72153"
   id="rect3032"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.02941176;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="722.71448"
   x="1465.3287"
   height="388.01559"
   width="489.22153"
   id="rect3033"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.02857145;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="721.46448"
   x="1464.0787"
   height="390.51559"
   width="491.72153"
   id="rect3034"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.02777776;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="720.21448"
   x="1462.8287"
   height="393.01559"
   width="494.22153"
   id="rect3035"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.02702703;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="718.96448"
   x="1461.5787"
   height="395.51559"
   width="496.72153"
   id="rect3036"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.02631579;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="717.71448"
   x="1460.3287"
   height="398.01559"
   width="499.22153"
   id="rect3037"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.02564105;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="716.46448"
   x="1459.0787"
   height="400.51559"
   width="501.72153"
   id="rect3038"
   rx="50"
   ry="50" />
		<rect
   style="opacity:0.025;fill:#ffff00;stroke:#ffff00;stroke-width:0.9432283;stroke-miterlimit:4;stroke-dasharray:none;stroke-opacity:1;display:inline"
   transform="matrix(0.893936,-0.448194,-0.225536,0.974235,0,0)"
   y="715.21448"
   x="1457.8287"
   height="403.01559"
   width="504.22153"
   id="rect3039"
   rx="50"
   ry="50" />
	</g>
	<g
   style="display:inline"
   transform="matrix(5e-2,0,0,5e-2,87.13799,96.33328)"
   id="g1896">
		<text
   xml:space="preserve"
   style="font-size:224px;font-style:italic;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;opacity:1;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Utopia"
   x="295.19415"
   y="247"
   id="text1949"
   sodipodi:linespacing="125%"><tspan
     sodipodi:role="line"
     id="tspan1951"
     x="295.19415"
     y="247">c</tspan></text>

		<text
   xml:space="preserve"
   style="font-size:224px;font-style:italic;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Utopia"
   x="170"
   y="247"
   id="text1888"
   sodipodi:linespacing="125%"><tspan
     sodipodi:role="line"
     id="tspan1890"
     x="170"
     y="247">µ</tspan></text>

		<text
   xml:space="preserve"
   style="font-size:224px;font-style:italic;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;font-family:Utopia"
   x="394"
   y="247"
   id="text1892"
   sodipodi:linespacing="125%"><tspan
     sodipodi:role="line"
     id="tspan1894"
     x="394"
     y="247">³</tspan></text>

	</g>
</g>
<g
   inkscape:groupmode="layer"
   id="layer2"
   inkscape:label="pesthörnchen"
EOF
	if ( $ornament eq "pesthoernchen" ) {
		$output .= <<EOF;
   style="opacity:1;display:inline"
EOF
	} else {
		$output .= <<EOF;
   style="display:none"
EOF
	};
	$output .= <<EOF;
   transform="translate(-0.116,43.599725)">
	<g
   id="g2472"
   transform="matrix(3.02942e-2,0,0,3.02942e-2,129.6048,103.2)"
   style="fill:#e3cc0b;fill-opacity:1">
		<path
   style="fill:#e3cc0b;fill-opacity:1"
   d="M -1049.1946,472.15571 C -1056.9126,468.56202 -1067.7196,457.86052 -1070.99,450.57314 C -1079.8599,430.80843 -1074.8377,406.53603 -1058.7352,391.3458 C -1045.7666,379.11186 -1029.1192,373.00832 -1010.7929,373.76839 C -999.12325,374.25238 -998.62365,372.4972 -1009.3406,368.66622 C -1013.8154,367.06663 -1016.4283,365.6121 -1016.1464,364.87761 C -1015.8948,364.22189 -1003.6735,345.88173 -988.98806,324.1217 L -962.28716,284.55801 L -916.93223,284.55801 C -886.49665,284.55801 -871.5773,284.89665 -871.5773,285.58748 C -871.5773,286.15369 -875.10427,291.89119 -879.415,298.33748 C -883.72574,304.78377 -895.27052,322.65801 -905.07007,338.05801 C -914.86962,353.45801 -925.4372,369.88301 -928.55357,374.55801 C -936.46495,386.42619 -936.1637,385.74329 -933.15452,384.98803 C -925.9197,383.17221 -917.54742,388.63967 -913.51061,397.81637 C -911.6375,402.07441 -911.20221,404.8407 -911.19092,412.55801 C -911.16902,427.52305 -915.15434,436.18382 -926.5773,445.99526 C -938.98541,456.65286 -952.42384,462.45859 -966.64324,463.30472 C -973.82181,463.73188 -975.95418,463.48489 -979.8089,461.77976 C -986.59388,458.77844 -987.80233,456.29988 -987.95159,445.079 C -988.09428,434.35187 -989.37124,431.78751 -993.99266,432.94741 C -996.42922,433.55895 -996.5773,433.95621 -996.5773,439.88128 C -996.5773,445.06204 -997.07425,446.95006 -999.40544,450.62597 C -1004.8749,459.25049 -1017.2543,467.80222 -1031.2302,472.61061 C -1038.6531,475.16447 -1042.9675,475.05522 -1049.1946,472.15571 z M -697.9899,471.14179 C -709.43701,466.31582 -719.38866,457.68974 -718.12013,453.69294 C -717.8023,452.69157 -715.75015,449.47028 -713.55978,446.53453 C -710.67786,442.67188 -709.5773,440.22194 -709.5773,437.6692 L -709.5773,434.14159 L -713.8273,438.18591 C -720.94194,444.95622 -726.72134,449.18899 -734.5773,453.38298 C -744.96339,458.92772 -754.34204,461.61366 -765.5773,462.26104 C -774.35644,462.76691 -775.78617,462.57041 -784.4193,459.67147 C -800.21715,454.36666 -808.9186,447.95013 -814.65017,437.37894 C -817.90314,431.37923 -818.0773,430.54983 -818.0773,421.05801 C -818.0773,412.23642 -817.75291,410.36547 -815.32453,405.18112 C -811.14093,396.24954 -804.28216,387.27861 -796.8125,380.96831 C -793.10814,377.83889 -789.93746,374.92183 -789.76653,374.48594 C -789.59561,374.05005 -790.40961,373.18294 -791.57542,372.55901 C -793.32495,371.62269 -794.82598,371.95382 -800.17161,374.45535 L -806.64815,377.48609 L -809.94278,372.27205 C -816.86149,361.32258 -860.6649,288.49329 -861.25204,286.96325 C -861.59212,286.07701 -861.2427,284.95975 -860.47302,284.4724 C -859.70537,283.98633 -836.74258,283.58174 -809.44458,283.57332 L -759.81186,283.55801 L -732.05945,322.05585 C -705.24638,359.25065 -704.16775,360.58879 -700.19217,361.59049 C -686.97001,364.92199 -674.65931,372.41213 -662.50659,384.51938 C -653.14824,393.84271 -648.9242,400.98647 -645.92761,412.55801 C -643.62974,421.43137 -643.6891,437.13011 -646.05156,445.34092 C -647.66979,450.96511 -648.64037,452.35324 -655.30925,458.58123 C -669.9012,472.20851 -684.95281,476.63807 -697.9899,471.14179 z M -1236.0251,464.90593 C -1252.9436,461.27998 -1269.3931,451.19547 -1283.8378,435.59379 C -1299.6293,418.53756 -1308.3634,399.51758 -1308.881,381.05801 C -1309.0522,374.95325 -1308.6617,373.21661 -1305.8273,367.47898 C -1304.0398,363.86052 -1302.5773,360.1993 -1302.5773,359.34294 C -1302.5773,356.3544 -1294.4445,345.64084 -1286.5089,338.17557 C -1282.1108,334.03816 -1274.6697,328.33192 -1269.973,325.49504 C -1260.5864,319.82521 -1257.8296,316.30912 -1260.9703,314.01256 C -1263.1201,312.44061 -1265.1714,313.07626 -1272.0727,317.45294 L -1276.9364,320.53741 L -1280.0068,318.19621 C -1284.6015,314.69285 -1290.1601,306.92287 -1292.562,300.6464 C -1296.2649,290.97019 -1297.0981,281.28537 -1295.2043,269.93608 C -1292.488,253.65775 -1284.937,241.41992 -1271.1215,230.90535 C -1262.3668,224.24234 -1253.2172,219.78254 -1238.5773,215.04215 C -1228.8307,211.88622 -1225.3239,211.24562 -1215.5773,210.84071 C -1195.6296,210.01202 -1182.4786,214.69266 -1170.0202,227.05519 C -1160.8436,236.16108 -1155.9671,245.79149 -1153.7915,259.1047 C -1152.4169,267.51558 -1152.4151,269.45958 -1153.7738,277.77555 C -1154.608,282.8809 -1155.2425,287.09398 -1155.1839,287.13794 C -1155.1253,287.18189 -1124.0273,286.62934 -1086.0773,285.91005 C -1048.1273,285.19075 -1016.5148,284.80316 -1015.8273,285.04874 C -1015.1398,285.29431 -1014.5807,286.29686 -1014.5848,287.27663 C -1014.5889,288.25639 -1029.1237,310.65801 -1046.8844,337.05801 L -1079.1766,385.05801 L -1120.7529,385.31888 L -1162.3293,385.57975 L -1171.0327,376.43398 C -1178.747,368.3276 -1179.9056,367.45772 -1181.2276,368.77971 C -1182.5496,370.1017 -1182.2601,370.98121 -1178.681,376.51878 C -1173.7351,384.17112 -1170.9644,391.37522 -1169.541,400.28397 C -1167.6112,412.36246 -1170.1644,422.05347 -1178.7574,435.26527 C -1188.9954,451.00636 -1204.7674,463.04211 -1218.4638,465.56558 C -1225.2814,466.82168 -1227.4698,466.73948 -1236.0251,464.90593 z M -519.44644,443.01701 C -527.48001,441.27386 -537.0694,436.80958 -545.11979,431.06494 C -559.78735,420.59839 -567.66221,401.95363 -566.23014,381.08344 C -565.88952,376.11946 -565.10845,370.28475 -564.49444,368.11744 C -563.52354,364.6904 -563.61142,364.00623 -565.16881,362.86744 C -566.15372,362.14725 -567.31597,361.55801 -567.75158,361.55801 C -569.15901,361.55801 -573.30964,370.8943 -574.53128,376.80801 L -575.7191,382.55801 L -606.91777,382.55801 L -638.11644,382.55801 L -672.45802,333.35016 C -691.34588,306.28584 -707.02272,283.56084 -707.29543,282.85016 C -707.69572,281.80704 -699.14621,281.53151 -662.93429,281.42048 C -638.26294,281.34484 -607.0523,281.00734 -593.5773,280.67048 L -569.0773,280.05801 L -568.35767,272.84356 C -566.74593,256.68557 -559.53589,237.1848 -550.80264,225.36305 C -544.99875,217.5066 -534.56021,208.32205 -526.80516,204.24839 C -516.57218,198.87311 -506.16115,196.39537 -491.38953,195.81979 C -480.27144,195.38657 -477.79713,195.59903 -471.38953,197.53719 C -443.73997,205.90057 -424.6235,222.92602 -419.10849,244.09956 C -413.65892,265.02189 -422.17891,296.16718 -440.02419,320.55801 C -449.63018,333.68743 -450.75025,335.46916 -450.07985,336.55389 C -449.16021,338.04189 -445.97201,336.08131 -439.2671,329.90458 C -432.72654,323.87926 -432.9058,323.87225 -425.44153,330.44487 C -419.59202,335.59564 -415.07204,342.60818 -412.01092,351.28187 C -410.04242,356.85962 -409.61575,360.03892 -409.59839,369.25879 C -409.57287,382.81172 -410.72814,388.85904 -415.10574,398.08739 C -421.78558,412.16904 -433.93755,424.84532 -447.5773,431.95999 C -455.43159,436.05688 -470.0697,440.8179 -481.43777,442.97305 C -491.62816,444.90492 -510.64434,444.92692 -519.44644,443.01701 z M -905.69069,272.10795 C -908.12914,271.4888 -912.26745,269.78435 -914.88696,268.32029 L -919.64969,265.65835 L -927.27346,267.60818 C -936.47319,269.96107 -948.06862,270.12419 -959.86725,268.06668 C -970.53446,266.20647 -984.28541,261.92424 -984.84326,260.28881 C -985.12694,259.45715 -988.24972,260.59842 -994.47266,263.80801 C -1004.6773,269.07122 -1005.5828,269.21957 -1014.1172,267.02635 C -1022.0859,264.9785 -1029.7094,261.04871 -1033.6995,256.9319 C -1035.4981,255.07626 -1037.4439,253.56238 -1038.0235,253.56772 C -1038.6031,253.57305 -1041.1023,255.19124 -1043.5773,257.16368 C -1047.4446,260.24572 -1048.6397,260.6867 -1052.0773,260.3002 C -1060.8824,259.31021 -1075.6383,251.69717 -1085.1304,243.24706 C -1089.6214,239.24903 -1090.856,237.39031 -1092.4366,232.24706 C -1093.4827,228.84308 -1094.6423,223.58301 -1095.0134,220.55801 C -1096.8533,205.56221 -1097.1183,204.97617 -1103.8912,200.92504 C -1113.9275,194.92201 -1134.3929,180.83306 -1144.0773,173.25983 C -1182.4077,143.28535 -1227.3262,96.68263 -1250.7783,62.55801 C -1271.8114,31.95318 -1291.2942,-8.71581 -1307.5466,-55.94199 C -1321.8693,-97.56047 -1325.3747,-110.52678 -1330.5266,-140.94199 C -1337.335,-181.13718 -1338.4759,-191.17025 -1339.6236,-220.94199 C -1340.1748,-235.24199 -1341.0426,-252.79184 -1341.5519,-259.94167 C -1342.0612,-267.09149 -1342.1628,-273.22148 -1341.7776,-273.56388 C -1341.3924,-273.90628 -1315.0327,-274.46744 -1283.2004,-274.8109 L -1225.3235,-275.43538 L -1225.9442,-270.18868 C -1226.2856,-267.303 -1226.8576,-256.79636 -1227.2155,-246.8406 C -1228.2995,-216.68228 -1224.8283,-187.55924 -1215.9884,-152.64588 C -1209.4598,-126.86115 -1193.5919,-80.61353 -1190.9742,-79.74095 C -1190.2869,-79.51187 -1189.2692,-84.0635 -1188.1972,-92.16067 C -1183.7997,-125.37463 -1175.2732,-153.92949 -1163.7771,-173.94199 C -1163.1452,-175.04199 -1159.951,-181.56699 -1156.6788,-188.44199 C -1148.587,-205.44346 -1135.7304,-222.43672 -1116.1505,-242.01046 C -1072.8902,-285.25722 -1019.8002,-310.58564 -957.01951,-317.92949 C -939.89136,-319.93308 -909.45897,-319.90601 -895.78095,-317.87502 C -857.74901,-312.22782 -819.04927,-295.96671 -784.80174,-271.24306 C -759.37398,-252.88649 -726.2305,-221.75563 -712.08499,-202.94199 C -686.88301,-169.42316 -668.6417,-133.96585 -659.06723,-99.88652 C -653.92677,-81.5896 -654.28118,-82.25846 -651.84385,-86.25416 C -650.6157,-88.26757 -649.54685,-92.37361 -649.11801,-96.72561 C -648.73001,-100.66321 -647.33712,-107.17939 -646.02269,-111.20602 C -642.98253,-120.5193 -639.13892,-140.21012 -636.33649,-160.82844 C -634.519,-174.20033 -634.14201,-181.79116 -634.12081,-205.44199 C -634.0932,-236.24071 -635.02088,-245.55872 -640.18783,-266.38191 C -642.51986,-275.78019 -642.62135,-276.93661 -641.20495,-277.97231 C -638.6618,-279.8319 -605.99602,-280.43654 -507.92114,-280.43936 L -416.76498,-280.44199 L -416.1365,-275.69199 C -415.40729,-270.18062 -417.03198,-229.82135 -418.60215,-214.44199 C -427.02644,-131.92883 -455.61822,-44.20214 -496.00787,23.05801 C -536.94034,91.22211 -579.47371,141.38607 -626.59172,177.06893 C -649.30046,194.26645 -667.31801,204.35559 -709.5773,223.53767 C -740.36056,237.51063 -741.38429,238.09839 -742.55583,242.4718 C -743.0842,244.44422 -744.22641,248.67528 -745.09407,251.87416 C -747.45074,260.56272 -751.32528,264.23114 -760.0773,266.06029 C -773.55935,268.87802 -786.25926,267.20694 -794.1694,261.57438 L -798.2615,258.66053 L -802.61478,263.0962 C -807.66993,268.24702 -810.18139,269.18342 -821.0773,269.97999 C -833.63587,270.89811 -842.9637,268.99329 -850.76802,263.91691 C -853.40509,262.20161 -853.51181,262.2198 -856.1211,264.82908 C -860.63466,269.34265 -868.69509,271.72044 -881.0773,272.19107 C -887.1273,272.42102 -894.14277,272.74967 -896.66723,272.92141 C -899.19169,273.09315 -903.25225,272.72709 -905.69069,272.10795 z M -872.52973,255.40323 C -862.57438,252.48334 -858.76585,233.78963 -863.97967,213.43623 C -867.46186,199.84265 -869.75302,195.16766 -874.68322,191.59624 C -881.1029,186.94585 -885.22398,186.04141 -893.65193,187.43326 C -897.57075,188.08044 -901.97067,189.22719 -903.42954,189.9816 C -909.4657,193.10302 -909.38185,192.70309 -910.4726,223.57461 C -911.02607,239.23959 -911.16355,252.36256 -910.77811,252.73675 C -910.1292,253.36672 -898.0095,255.94713 -891.0773,256.93125 C -887.00091,257.50995 -876.86574,256.67498 -872.52973,255.40323 z M -816.96837,252.07694 C -812.08035,250.0346 -811.14017,245.52739 -811.19336,224.39155 C -811.24583,203.53775 -811.60545,202.52422 -819.82441,200.06632 C -832.29733,196.33626 -842.74729,197.24473 -844.64029,202.22368 C -845.15671,203.58198 -845.84038,212.39111 -846.15955,221.79953 C -846.79703,240.59111 -846.00813,245.86519 -841.99595,249.63443 C -837.04681,254.28391 -825.05204,255.45451 -816.96837,252.07694 z M -934.45389,252.54038 C -931.26722,251.65522 -930.66455,250.96282 -929.45389,246.79596 C -927.87903,241.37562 -927.55252,212.51559 -928.90671,198.43234 C -929.8345,188.78364 -930.48778,188.03775 -938.95465,186.96012 C -942.66242,186.48821 -944.28013,187.12086 -955.02972,193.24671 C -963.65534,198.16217 -967.51013,200.96608 -968.87907,203.3205 C -971.44026,207.72546 -975.50293,228.3752 -975.54404,237.19723 C -975.58984,247.02765 -974.76279,247.81119 -961.0773,250.90297 C -949.20755,253.58454 -940.20605,254.13816 -934.45389,252.54038 z M -1001.8165,251.49154 C -1000.1338,250.90498 -997.63159,248.76748 -996.25588,246.74154 C -990.89975,238.85382 -988.60918,214.47857 -992.61501,207.997 C -996.77904,201.25944 -1009.8289,197.82011 -1019.2969,200.96488 C -1025.5764,203.0506 -1028.1323,205.84053 -1029.0014,211.55801 C -1033.3088,239.89666 -1030.8593,246.57264 -1014.5454,250.95688 C -1007.8157,252.76545 -1005.7229,252.85335 -1001.8165,251.49154 z M -761.98083,249.07577 C -756.25165,245.35189 -754.01396,219.75702 -758.42852,208.44403 C -761.63539,200.22596 -763.40231,198.94329 -769.55867,200.36435 C -772.28219,200.99301 -778.13224,202.90406 -782.55878,204.61111 C -793.32495,208.76299 -793.93185,209.93656 -793.9083,226.55801 C -793.88213,245.03522 -791.75656,248.68802 -779.97636,250.50013 C -772.90799,251.58743 -764.86567,250.95087 -761.98083,249.07577 z M -1051.2724,244.11022 C -1050.4761,243.31393 -1048.8211,238.94349 -1047.5946,234.39812 C -1044.9192,224.48282 -1044.5712,211.82 -1046.827,206.46989 C -1048.2047,203.20254 -1048.8572,202.77791 -1054.1254,201.71989 C -1060.2471,200.49048 -1074.5478,200.17542 -1078.3217,201.18682 C -1085.9344,203.22708 -1081.5963,233.3842 -1072.8673,239.10363 C -1070.1307,240.89671 -1057.3855,245.28247 -1054.3987,245.45887 C -1053.4755,245.5134 -1052.0686,244.9065 -1051.2724,244.11022 z M -916.51329,138.86406 C -915.70693,136.42075 -915.51653,132.19502 -915.94244,126.19468 C -916.53462,117.85201 -916.42182,117.02141 -914.40509,114.8747 C -910.41112,110.62332 -904.22007,112.31823 -903.16309,117.9524 C -902.80726,119.84912 -901.84206,123.67082 -901.0182,126.44506 C -899.60218,131.21332 -899.39198,131.4307 -897.17432,130.42026 C -895.26617,129.55085 -894.70642,128.31375 -894.17488,123.79113 C -893.81546,120.733 -891.32875,111.44199 -888.64887,103.14445 C -879.89573,76.04268 -879.30757,73.61197 -878.82824,62.55801 C -878.48745,54.69912 -879.02747,47.31523 -880.97511,33.20266 C -882.40632,22.83221 -883.5773,11.85634 -883.5773,8.81182 C -883.5773,5.76731 -886.05396,-10.1059 -889.081,-26.46197 C -892.10803,-42.81803 -895.19101,-62.00901 -895.93206,-69.10858 C -896.67311,-76.20815 -897.82692,-83.03989 -898.49607,-84.29021 C -902.66089,-92.07226 -905.15932,-77.41187 -906.56514,-36.94199 C -907.55725,-8.382 -909.05334,9.34702 -910.60713,10.95666 C -911.87733,12.27252 -916.47601,8.92606 -917.75423,5.75571 C -920.85373,-1.93188 -921.74157,-9.17893 -922.55636,-33.44199 C -923.10134,-49.67087 -923.90495,-60.55006 -924.76666,-63.36494 L -926.12064,-67.78789 L -927.69298,-65.36494 C -928.81286,-63.63923 -929.45451,-59.14319 -929.92276,-49.74099 C -930.4123,-39.91132 -932.13561,-28.29135 -936.67069,-4.24099 C -944.7493,38.60145 -946.61484,54.85503 -944.91158,67.55801 C -941.58317,92.3813 -933.27461,118.75712 -922.99082,137.14627 C -921.01605,140.67749 -919.02298,143.33345 -918.56177,143.04841 C -918.10056,142.76337 -917.17875,140.88041 -916.51329,138.86406 z M -1147.4069,125.47606 C -1148.0579,122.65574 -1149.4662,119.11837 -1150.5365,117.61525 C -1152.911,114.28064 -1157.1691,101.76133 -1158.1009,95.3753 C -1158.4767,92.79981 -1159.4126,90.45143 -1160.1807,90.15668 C -1161.2157,89.75952 -1161.5773,87.54149 -1161.5773,81.58939 C -1161.5773,77.17213 -1161.9754,73.55801 -1162.4621,73.55801 C -1164.3516,73.55801 -1164.5264,62.27332 -1162.9111,44.55801 C -1161.9834,34.38301 -1161.2763,20.20801 -1161.3399,13.05801 C -1161.4443,1.30106 -1161.7959,-1.10878 -1165.0163,-12.14449 C -1166.9749,-18.85587 -1168.5773,-25.5272 -1168.5773,-26.96966 C -1168.5773,-28.41213 -1170.2794,-32.596 -1172.3597,-36.26716 C -1174.44,-39.93832 -1176.8166,-44.29199 -1177.6409,-45.94199 C -1178.7658,-48.19361 -1179.9426,-49.02016 -1182.3585,-49.25535 C -1184.1288,-49.4277 -1185.5773,-49.30236 -1185.5773,-48.97683 C -1185.5773,-48.6513 -1184.2818,-45.81029 -1182.6985,-42.66347 C -1172.5963,-22.58622 -1169.4509,2.17098 -1171.2992,47.05801 C -1172.4585,75.21228 -1171.7037,84.43494 -1167.1163,98.16184 C -1163.1304,110.08912 -1158.5568,119.16257 -1152.3769,127.40351 C -1147.4198,134.01377 -1145.5991,133.30766 -1147.4069,125.47606 z M -686.02985,126.40751 C -679.48943,120.37876 -672.79079,107.90438 -670.98663,98.39362 C -670.18051,94.14408 -669.58176,88.95512 -669.65607,86.8626 C -669.73039,84.77008 -669.24761,78.55801 -668.58323,73.05801 C -667.14951,61.18925 -667.6937,47.20202 -670.60634,21.05801 C -672.0808,7.82316 -673.15611,1.72113 -674.15019,0.94777 C -675.24496,0.09607 -675.57539,-2.93133 -675.5691,-12.05223 C -675.55616,-30.79028 -674.09355,-40.77083 -670.16302,-48.94199 C -665.84169,-57.9256 -665.17309,-60.86164 -667.08697,-62.45001 C -669.23525,-64.23293 -670.7275,-62.64652 -674.38387,-54.69266 C -679.45622,-43.65856 -680.7614,-37.28277 -681.30863,-20.86514 C -681.84868,-4.66322 -681.321,0.9351 -676.41449,31.05801 C -673.52978,48.76834 -673.35793,51.24586 -673.88277,67.55801 C -674.47106,85.84256 -676.22254,97.22951 -679.69266,105.33017 C -682.62135,112.16691 -688.84114,119.96421 -694.31923,123.66647 C -696.93617,125.43508 -699.24539,127.01479 -699.45084,127.17694 C -699.65628,127.33909 -699.55791,128.16616 -699.23222,129.01488 C -698.83326,130.05456 -697.31752,130.55801 -694.58634,130.55801 C -691.22241,130.55801 -689.76641,129.85175 -686.02985,126.40751 z M -980.96512,43.08054 C -975.47085,41.44892 -968.79228,36.27706 -965.74066,31.29079 C -961.4294,24.24629 -954.36496,-10.8681 -950.50445,-44.44199 C -946.74297,-77.15468 -947.56434,-86.67242 -955.52073,-102.56879 C -960.42916,-112.37554 -973.10839,-131.08864 -976.23082,-133.13454 C -981.78879,-136.77626 -1014.2129,-131.86667 -1030.9801,-124.84452 C -1038.9129,-121.52224 -1056.306,-115.08921 -1075.0773,-108.53462 C -1083.3273,-105.65387 -1095.0517,-100.92351 -1101.1316,-98.02269 C -1110.9331,-93.34616 -1112.546,-92.20477 -1115.3638,-87.95052 C -1117.1118,-85.31164 -1119.4155,-80.81769 -1120.4832,-77.96397 C -1124.0735,-68.3679 -1125.9219,-45.82296 -1123.4908,-41.28028 C -1122.8932,-40.16366 -1122.1778,-34.02129 -1121.9012,-27.63056 C -1121.3189,-14.18223 -1120.3352,-11.60343 -1112.7927,-3.75315 C -1101.6175,7.87818 -1084.9808,15.27297 -1059.0773,20.12269 C -1051.4587,21.54908 -1048.0053,22.93143 -1036.5773,29.12924 C -1019.9331,38.15597 -1013.6475,41.05169 -1006.5773,42.94981 C -999.39572,44.87784 -987.22645,44.93995 -980.96512,43.08054 z M -814.34321,33.0962 C -806.35452,31.40325 -795.72927,26.55928 -777.47193,16.28687 C -762.37161,7.79074 -754.99039,4.49719 -745.59203,2.06183 C -734.30288,-0.86349 -719.50152,-9.5117 -711.95009,-17.59466 C -704.97065,-25.06538 -700.06256,-43.86136 -700.10881,-62.94199 C -700.14525,-77.98182 -701.4533,-83.48515 -707.91893,-95.80143 C -713.21061,-105.88147 -718.14278,-111.36231 -730.31557,-120.68956 C -749.09271,-135.07732 -754.81449,-136.87785 -785.5773,-138.07935 C -809.88572,-139.02875 -820.22397,-137.60205 -833.05074,-131.52792 C -844.64963,-126.03525 -852.96619,-120.85563 -856.70544,-116.79559 C -861.11237,-112.01059 -871.18258,-94.24873 -872.49723,-88.94199 C -874.43707,-81.11159 -874.96512,-67.52078 -873.67289,-58.68315 C -872.77944,-52.5728 -869.33818,-42.39095 -859.50942,-16.77685 C -841.33886,30.57629 -840.81362,31.71103 -836.2037,33.57257 C -832.88898,34.9111 -821.76327,34.66865 -814.34321,33.0962 z"
   id="path2484" />
		<path
   style="fill:#e3cc0b;fill-opacity:1"
   d="M -1047.2374,472.98248 C -1052.7331,470.95968 -1064.2512,461.22549 -1068.336,455.15147 C -1072.9286,448.32254 -1074.8459,440.86986 -1074.779,430.10834 C -1074.7214,420.84535 -1072.4633,411.20901 -1068.5452,403.50577 C -1063.2347,393.06502 -1048.4638,381.72253 -1034.008,376.98488 C -1026.183,374.42038 -1023.6194,374.05801 -1013.302,374.05801 C -999.26058,374.05801 -998.20893,372.7546 -1008.9559,368.67144 C -1012.7391,367.23405 -1015.7848,365.60801 -1015.724,365.05801 C -1015.6633,364.50801 -1003.574,346.17051 -988.85909,324.30801 L -962.10461,284.55801 L -917.39997,284.55801 C -892.81242,284.55801 -872.465,284.93069 -872.18349,285.38619 C -871.90198,285.84169 -874.62687,290.63358 -878.2388,296.03485 C -881.85073,301.43612 -893.09296,318.87349 -903.22152,334.78457 C -913.35009,350.69565 -924.77364,368.38875 -928.6072,374.10257 C -932.44075,379.81639 -935.5773,384.75173 -935.5773,385.06999 C -935.5773,385.38824 -934.07505,385.36681 -932.23896,385.02236 C -925.16396,383.69508 -916.84458,389.51799 -913.70832,397.99234 C -909.48938,409.39216 -910.46254,423.06451 -916.24971,433.69745 C -923.48924,446.99885 -944.34459,460.1524 -962.31897,462.7535 C -972.96869,464.29464 -978.83005,463.2692 -983.4248,459.06103 L -987.0773,455.71584 L -987.59512,445.08944 C -988.14148,433.87729 -988.72062,432.60493 -993.29212,432.57332 C -996.25428,432.55284 -997.55565,435.30053 -996.89977,440.19045 C -995.54982,450.2551 -1006.9022,462.0845 -1025.7488,470.25177 C -1035.0779,474.29459 -1041.4667,475.10646 -1047.2374,472.98248 z M -698.06106,470.90415 C -705.50205,467.70614 -711.33069,463.74185 -715.39105,459.11735 C -718.94041,455.07486 -718.83846,454.24624 -713.9592,447.47875 C -710.06856,442.08245 -708.41628,438.14118 -709.1945,436.1132 C -709.60798,435.03568 -711.77097,436.3737 -717.41644,441.19926 C -727.52789,449.84219 -736.05052,454.77974 -747.38152,458.55942 C -760.36917,462.8917 -770.52675,463.5182 -781.03223,460.63494 C -810.03249,452.67573 -824.30019,431.81537 -816.35999,408.98332 C -812.51208,397.91867 -805.28743,388.15462 -794.10609,378.90735 C -789.76279,375.31533 -789.30459,374.59153 -790.47853,373.17702 C -792.30472,370.97659 -793.79636,371.12859 -799.69131,374.11578 C -802.46744,375.52255 -805.37267,376.53505 -806.14737,376.36578 C -807.46123,376.0787 -861.5773,287.50557 -861.5773,285.64223 C -861.5773,283.82249 -855.49282,283.58491 -808.5773,283.57273 L -760.0773,283.56015 L -732.86075,321.32563 C -717.89165,342.09664 -705.08915,359.64616 -704.41075,360.32456 C -703.73235,361.00296 -702.2548,361.5735 -701.1273,361.59243 C -699.9998,361.61136 -695.86111,362.89601 -691.93022,364.44721 C -675.72549,370.84188 -657.11301,386.97035 -651.01502,399.90188 C -649.15903,403.83775 -646.95127,409.74005 -646.10889,413.01811 C -644.08356,420.89956 -644.12911,436.86273 -646.20046,445.1088 C -647.65545,450.90115 -648.4561,452.15619 -653.9283,457.22249 C -661.87332,464.57818 -669.60923,469.46644 -676.89209,471.73312 C -684.89412,474.22363 -690.88316,473.9891 -698.06106,470.90415 z M -1232.0416,465.4297 C -1250.5649,462.77959 -1271.3513,450.15732 -1286.5136,432.35225 C -1300.5657,415.85082 -1308.1882,398.21421 -1308.8551,380.65879 C -1309.0827,374.66984 -1308.2491,372.28218 -1299.7426,354.55801 C -1296.1934,347.1627 -1281.3143,332.35969 -1272.1014,327.05801 C -1262.7971,321.70373 -1259.5773,318.87026 -1259.5773,316.0365 C -1259.5773,311.36038 -1264.2955,311.868 -1272.4865,317.42538 L -1276.8957,320.41692 L -1280.2294,317.87419 C -1285.0052,314.23153 -1291.2306,304.42032 -1293.568,296.85261 C -1294.9991,292.21948 -1295.573,287.57172 -1295.5625,280.70267 C -1295.5352,262.87508 -1291.3733,251.82532 -1280.1656,239.8242 C -1269.5568,228.46446 -1260.0461,222.57724 -1242.6729,216.61591 C -1218.7089,208.39305 -1201.1847,208.55799 -1183.6827,217.17114 C -1170.2881,223.76294 -1159.0774,237.86175 -1155.1057,253.11031 C -1153.3676,259.78326 -1153.111,275.82326 -1154.6364,282.43999 C -1155.1921,284.85007 -1155.518,286.9506 -1155.3608,287.10781 C -1155.2036,287.26503 -1123.8005,286.81198 -1085.5761,286.10103 C -1047.3518,285.39008 -1015.7398,285.00362 -1015.3273,285.24222 C -1014.9148,285.48082 -1014.5773,286.31982 -1014.5773,287.10666 C -1014.5773,287.8935 -1029.2292,310.36694 -1047.137,337.04765 L -1079.6967,385.55801 L -1120.887,385.58658 L -1162.0773,385.61516 L -1170.757,376.33658 C -1178.8265,367.71042 -1179.5543,367.17311 -1181.1083,368.69495 C -1182.6671,370.22162 -1182.5038,370.7894 -1178.6836,377.12337 C -1171.3218,389.32941 -1170.1254,393.50166 -1170.0999,407.05801 C -1170.0789,418.21531 -1170.2749,419.46052 -1172.8919,424.78969 C -1182.1597,443.66294 -1198.0563,459.0796 -1213.1464,463.82906 C -1220.0186,465.992 -1225.1016,466.42259 -1232.0416,465.4297 z M -518.90215,442.93077 C -540.99646,438.19071 -558.29977,422.95847 -564.19629,403.05801 C -566.41229,395.57909 -566.65307,378.65486 -564.67067,369.71383 C -563.46183,364.26172 -563.46183,363.24246 -564.67067,362.46508 C -568.39379,360.07084 -571.40728,364.01265 -574.2979,375.05801 L -576.12983,382.05801 L -607.10356,382.27069 L -638.0773,382.48337 L -672.69485,332.77069 L -707.3124,283.05801 L -697.69485,282.42547 C -692.4052,282.07757 -669.36194,281.74007 -646.48761,281.67547 C -623.61328,281.61087 -596.72578,281.262 -586.73761,280.9002 L -568.5773,280.2424 L -568.5773,276.80729 C -568.5773,271.12416 -564.64486,253.63292 -561.60999,245.81717 C -555.00459,228.80614 -542.91412,214.00605 -528.74753,205.58983 C -515.65021,197.80886 -491.43549,193.55506 -476.72001,196.45015 C -461.19143,199.50521 -441.23254,210.51241 -431.60982,221.32813 C -425.82468,227.8305 -420.2943,238.53128 -418.67427,246.35723 C -414.43101,266.85544 -423.06986,297.21344 -439.42213,319.26774 C -449.33481,332.63698 -451.03284,335.50247 -449.78304,336.75227 C -448.56081,337.9745 -444.06823,335.0839 -437.43207,328.80546 C -432.88989,324.50813 -431.28939,324.88715 -424.26043,331.92468 C -415.25146,340.94464 -409.57083,354.32404 -409.58489,366.48951 C -409.60208,381.36779 -411.22536,389.46784 -416.21196,399.55801 C -420.17848,407.5841 -422.31645,410.45435 -429.9921,418.05801 C -440.90631,428.86987 -448.21535,433.29003 -462.96308,437.9973 C -483.14761,444.43991 -503.50082,446.23494 -518.90215,442.93077 z M -908.93477,271.00269 C -911.05637,270.22477 -914.29107,268.66196 -916.123,267.52977 C -919.39808,265.50565 -919.55927,265.50091 -925.76553,267.24606 C -930.46003,268.56612 -935.40831,268.99432 -945.0773,268.91721 C -956.23623,268.82822 -959.77675,268.36802 -970.0773,265.66767 C -977.79178,263.64527 -982.65451,261.83342 -983.69356,260.59428 C -985.28757,258.6933 -985.36329,258.695 -989.19356,260.71794 C -991.32962,261.8461 -994.4273,263.5779 -996.0773,264.5664 C -997.7273,265.5549 -1000.8555,266.84618 -1003.029,267.43591 C -1010.5137,269.46683 -1025.3103,264.40778 -1033.4844,257.02297 C -1035.5938,255.11724 -1037.7643,253.55801 -1038.3078,253.55801 C -1038.8512,253.55801 -1041.2717,255.12864 -1043.6866,257.0483 C -1046.1015,258.96797 -1049.0768,260.54297 -1050.2985,260.5483 C -1054.0763,260.56481 -1068.7705,254.71199 -1074.5672,250.88184 C -1090.7071,240.2175 -1092.5025,237.16614 -1095.6457,215.05801 C -1096.2713,210.65801 -1097.155,206.35954 -1097.6095,205.50585 C -1098.064,204.65216 -1102.4052,201.54104 -1107.2566,198.59225 C -1140.9115,178.13594 -1179.9797,144.95861 -1212.3417,109.35221 C -1264.3194,52.16374 -1288.2194,6.96379 -1319.5343,-93.37135 C -1324.4942,-109.26318 -1326.4222,-117.63848 -1330.1237,-139.37135 C -1336.7703,-178.39655 -1338.4814,-193.61816 -1339.6313,-223.94919 C -1340.2,-238.95066 -1341.0193,-256.11101 -1341.452,-262.08329 C -1341.8848,-268.05558 -1342.0925,-273.127 -1341.9136,-273.35312 C -1341.5563,-273.80477 -1226.2509,-275.42349 -1225.7949,-274.98325 C -1225.6396,-274.8333 -1226.0359,-269.36267 -1226.6756,-262.8263 C -1228.3267,-245.95499 -1227.2912,-211.67378 -1224.5949,-193.94199 C -1220.5232,-167.16495 -1214.8859,-144.58909 -1204.7433,-114.44199 C -1195.4164,-86.71938 -1191.7276,-77.94121 -1190.0987,-79.59185 C -1189.9087,-79.78443 -1189.0176,-85.34199 -1188.1186,-91.94199 C -1183.9081,-122.85168 -1176.6031,-148.27473 -1165.8028,-169.60543 C -1162.0889,-176.94054 -1157.3533,-186.54199 -1155.2794,-190.94199 C -1153.2055,-195.34199 -1148.6147,-202.99199 -1145.0776,-207.94199 C -1102.4929,-267.53739 -1040.5219,-305.23362 -966.5773,-316.52157 C -949.54749,-319.12124 -914.9659,-320.20512 -902.0773,-318.54318 C -858.335,-312.90274 -817.48935,-295.58548 -778.12473,-265.99123 C -756.86836,-250.01073 -728.7798,-223.72812 -716.62112,-208.44199 C -688.59005,-173.20076 -668.95515,-135.45396 -658.12466,-95.98642 C -656.32023,-89.41085 -654.43346,-83.89404 -653.93185,-83.72684 C -652.19646,-83.14838 -649.83263,-88.96855 -649.1738,-95.44199 C -648.80996,-99.01699 -647.18528,-106.44199 -645.5634,-111.94199 C -642.31872,-122.94509 -638.53122,-142.5787 -635.86472,-162.21789 C -634.54368,-171.94749 -634.1372,-182.11988 -634.13751,-205.44199 C -634.13795,-238.24323 -634.91076,-246.19474 -640.0892,-266.67968 C -642.42905,-275.93566 -642.49445,-276.78209 -640.95669,-277.90652 C -638.70062,-279.5562 -586.54399,-280.43863 -491.18348,-280.44051 L -416.28966,-280.44199 L -416.87559,-253.19199 C -417.68804,-215.40785 -421.64709,-182.58987 -429.74128,-146.54382 C -442.9158,-87.87341 -468.02585,-24.00507 -496.81395,24.05801 C -540.48961,96.97659 -590.0236,152.88546 -641.5773,187.452 C -659.26714,199.31296 -671.13692,205.6565 -703.41566,220.50008 C -744.94097,239.59577 -741.61117,237.41975 -744.06611,247.06493 C -747.78382,261.6714 -750.87197,264.57287 -764.92507,266.66301 C -777.12972,268.47822 -789.09199,265.96723 -795.30731,260.2855 L -797.53733,258.24694 L -802.42523,262.819 C -808.51689,268.51703 -812.14811,269.54539 -826.20157,269.55243 C -838.11938,269.55841 -843.20987,268.37282 -849.72233,264.07439 L -853.36737,261.66856 L -855.22233,263.72137 C -858.03013,266.82863 -865.46405,270.25085 -872.05117,271.46855 C -880.59091,273.0472 -904.17105,272.74938 -908.93477,271.00269 z M -871.37144,255.24536 C -869.05845,254.27893 -867.15897,252.23391 -865.06896,248.46001 C -862.16773,243.2213 -862.07871,242.66506 -862.12407,230.05801 C -862.16714,218.08476 -862.43263,216.26821 -865.48555,207.05801 C -868.24216,198.74174 -869.51108,196.37217 -873.02196,192.98468 C -878.91468,187.29905 -884.42892,185.86543 -894.4268,187.41977 C -899.23534,188.16734 -903.40167,189.49955 -905.71154,191.02815 L -909.37334,193.45141 L -909.95591,204.75471 C -910.27633,210.97153 -910.8115,224.4299 -911.14519,234.6622 L -911.7519,253.2664 L -903.4146,254.91162 C -898.82909,255.81649 -893.9523,256.74981 -892.5773,256.98566 C -888.09014,257.75534 -874.76056,256.66142 -871.37144,255.24536 z M -816.40043,251.88672 C -814.50858,250.78182 -812.87776,248.81173 -812.38951,247.04138 C -810.91465,241.69361 -810.29413,227.25222 -811.03187,215.44499 C -811.74998,203.95194 -811.77171,203.87438 -814.76967,202.10345 C -821.39875,198.18755 -835.1419,196.30138 -840.9514,198.51014 C -845.35361,200.18386 -845.91793,202.77014 -846.30765,223.05801 C -846.63031,239.85502 -846.4642,242.45558 -844.87497,245.48693 C -842.72563,249.58662 -839.05705,252.448 -834.4545,253.61457 C -829.39756,254.8963 -820.01625,253.99847 -816.40043,251.88672 z M -934.58963,252.91048 C -930.43664,252.07988 -929.01107,248.78931 -927.53115,236.6177 C -926.71599,229.91348 -926.7113,223.6329 -927.51369,213.25339 C -929.36522,189.3025 -929.2125,189.92113 -933.71838,188.11824 C -940.70719,185.32187 -942.94764,185.99463 -960.76245,196.23894 C -968.32268,200.58641 -968.48032,200.759 -970.46147,206.85812 C -972.62035,213.50443 -974.09432,220.80801 -975.56956,232.16887 C -976.53057,239.56965 -975.65065,245.42232 -973.28133,247.38868 C -972.58738,247.96461 -967.30758,249.55136 -961.54845,250.91478 C -951.13519,253.38003 -940.77288,254.14713 -934.58963,252.91048 z M -997.01221,248.19839 C -994.51378,245.30814 -993.4856,242.71811 -992.13306,235.90768 C -989.78126,224.06566 -989.85298,212.483 -992.30408,208.28613 C -996.20336,201.60963 -1009.4242,197.36107 -1017.5689,200.16716 C -1024.0623,202.4043 -1027.3807,204.35836 -1027.9789,206.29704 C -1029.704,211.88759 -1031.6756,228.73935 -1031.1477,233.38202 C -1030.5403,238.72447 -1027.609,245.80233 -1025.4516,247.13566 C -1020.9396,249.92428 -1010.5904,252.59022 -1005.6275,252.24234 C -1000.8144,251.90496 -999.80787,251.4325 -997.01221,248.19839 z M -765.08804,250.4564 C -761.35996,249.51766 -760.48807,248.79227 -759.19081,245.5501 C -753.74392,231.93698 -755.14341,209.37347 -761.938,201.25801 L -764.0773,198.70283 L -771.0773,200.59442 C -792.73303,206.44639 -794.10677,208.03138 -794.01373,227.05801 C -793.92492,245.22 -792.22984,248.41094 -781.5773,250.46934 C -775.10822,251.71936 -770.08809,251.71542 -765.08804,250.4564 z M -1050.7556,244.27289 C -1048.2841,241.29489 -1045.226,226.94599 -1045.1685,218.05801 C -1045.0688,202.6315 -1047.4409,200.79241 -1067.6362,200.63849 C -1081.8427,200.53021 -1082.1078,200.74454 -1081.9762,212.23343 C -1081.8563,222.70376 -1079.4318,232.11925 -1075.7185,236.53522 C -1073.8644,238.74023 -1070.6933,240.52857 -1065.0773,242.53642 C -1056.1691,245.7213 -1052.3427,246.18523 -1050.7556,244.27289 z M -916.0773,128.62225 C -916.0773,118.37087 -915.82001,116.48568 -914.17231,114.66407 C -913.12457,113.50574 -911.26192,112.55801 -910.0331,112.55801 C -906.16933,112.55801 -903.88219,115.64875 -902.07152,123.31692 C -900.20724,131.21215 -899.54205,132.14469 -896.81544,130.68546 C -895.56894,130.01835 -894.65001,127.61146 -893.83892,122.88922 C -893.19359,119.13205 -890.14032,108.18757 -887.05388,98.56814 C -883.96744,88.94871 -880.80423,78.37371 -880.02452,75.06814 C -877.93279,66.2003 -878.28592,51.34156 -881.07044,31.05801 C -882.42951,21.15801 -883.54954,10.63213 -883.55939,7.66717 C -883.56924,4.70222 -886.03427,-11.04778 -889.03724,-27.33283 C -892.0402,-43.61787 -894.98526,-61.89199 -895.58181,-67.94199 C -896.98269,-82.14914 -898.16286,-86.66845 -900.36146,-86.24504 C -903.84067,-85.57501 -905.67086,-69.55384 -907.59293,-22.94199 C -908.54209,0.07605 -909.47327,9.78731 -910.86463,11.17867 C -911.89577,12.20981 -915.56335,9.48567 -917.07216,6.56795 C -920.47848,-0.01914 -921.78117,-9.81694 -922.59122,-34.94199 C -923.10637,-50.92033 -923.88582,-61.52838 -924.75115,-64.33804 L -926.10506,-68.73408 L -927.76091,-65.33804 C -928.87083,-63.06168 -929.74269,-57.16128 -930.40529,-47.44199 C -931.08731,-37.4379 -933.27879,-22.86495 -937.47315,-0.44199 C -945.58001,42.89715 -946.93146,55.3832 -944.97449,68.86286 C -941.14659,95.22948 -930.91564,125.90246 -920.79898,141.34243 C -919.39595,143.48372 -919.13597,143.54475 -917.67299,142.07617 C -916.39192,140.7902 -916.0773,138.13748 -916.0773,128.62225 z M -1146.8285,128.0221 C -1147.1096,125.52735 -1148.9787,120.23985 -1150.9819,116.2721 C -1152.9851,112.30435 -1155.6589,104.80958 -1156.9236,99.61706 C -1158.1883,94.42454 -1159.7527,89.99954 -1160.4001,89.78373 C -1161.1698,89.52716 -1161.5773,86.67157 -1161.5773,81.53369 C -1161.5773,77.21199 -1161.9682,73.43446 -1162.4459,73.13919 C -1164.2903,71.99934 -1164.4338,64.36507 -1162.9458,46.55801 C -1159.6918,7.61845 -1159.8639,3.61875 -1165.5954,-15.00074 C -1167.2354,-20.32872 -1168.5773,-26.02566 -1168.5773,-27.66061 C -1168.5773,-29.29556 -1169.4875,-31.91154 -1170.6,-33.4739 C -1171.7125,-35.03625 -1173.9957,-39.24842 -1175.6737,-42.83426 C -1178.7005,-49.30242 -1180.7791,-51.06925 -1183.9364,-49.85768 C -1186.1839,-48.99525 -1186.0627,-48.35654 -1182.1928,-40.66703 C -1177.7077,-31.75509 -1175.137,-23.15346 -1172.9927,-9.88368 C -1171.1697,1.39819 -1170.8566,21.35203 -1171.8716,61.55801 C -1172.2924,78.22433 -1172.1779,79.60244 -1169.469,90.48642 C -1166.3758,102.91428 -1159.4004,118.40418 -1152.9008,127.27855 C -1148.0075,133.95975 -1146.1333,134.18924 -1146.8285,128.0221 z M -688.94706,129.03455 C -684.5348,126.4488 -681.49306,122.58899 -675.56862,112.05801 C -672.0269,105.76243 -668.12035,88.91541 -669.63423,86.4659 C -670.05605,85.78338 -669.96941,84.08934 -669.4417,82.70136 C -667.20398,76.8157 -667.26853,51.67818 -669.57817,29.55801 C -670.81286,17.73301 -671.7634,6.85702 -671.69048,5.38914 C -671.61756,3.92126 -672.20888,2.06929 -673.00452,1.27365 C -675.17216,-0.89399 -675.94502,-15.12246 -674.64575,-28.94199 C -673.69812,-39.02148 -672.97147,-42.14231 -670.10542,-48.44199 C -665.36629,-58.85878 -665.0773,-60.23202 -667.14373,-62.51539 C -668.8531,-64.40423 -668.94123,-64.37069 -671.26852,-60.94577 C -679.52515,-48.79505 -683.30985,-28.78931 -681.60951,-6.28385 C -681.09666,0.50417 -678.994,16.5825 -676.93694,29.44576 L -673.19683,52.8335 L -674.35339,71.94576 C -675.56415,91.95361 -677.02487,99.56093 -681.26118,107.92089 C -684.11119,113.5451 -692.66027,123.03244 -696.81367,125.18024 C -699.91593,126.78448 -700.51838,130.16543 -697.8273,130.86868 C -694.38244,131.76892 -693.19409,131.52348 -688.94706,129.03455 z M -977.03235,41.843 C -970.12797,38.23046 -965.00908,31.72346 -962.53423,23.41339 C -957.04741,4.98968 -951.83432,-26.51847 -948.98156,-58.4996 L -947.24727,-77.94199 L -949.41836,-86.40638 C -952.37694,-97.94098 -956.17527,-105.69371 -966.20045,-120.66003 C -976.27029,-135.69302 -975.39761,-135.29293 -994.4918,-133.63063 C -1008.5204,-132.40933 -1022.7222,-128.754 -1036.5773,-122.79842 C -1041.2523,-120.78888 -1053.8523,-116.1059 -1064.5773,-112.39179 C -1100.8845,-99.81849 -1109.7922,-95.65989 -1114.9853,-88.85873 C -1121.6573,-80.12057 -1125.2138,-65.13127 -1124.2263,-49.91096 C -1121.7106,-11.13707 -1122.1972,-13.02486 -1112.1214,-2.94909 C -1101.124,8.04834 -1085.613,14.95502 -1060.3517,20.10265 C -1049.6761,22.27809 -1047.5071,23.12568 -1036.1282,29.56837 C -1013.1971,42.55182 -1006.7975,44.66015 -991.5773,44.24548 C -983.20895,44.01749 -980.25612,43.52975 -977.03235,41.843 z M -805.48901,30.62559 C -800.76545,28.89875 -791.31545,24.31384 -784.48901,20.43689 C -765.12456,9.43922 -757.95737,6.08251 -745.5773,2.21282 C -731.64128,-2.14322 -723.37619,-6.83931 -714.50496,-15.44199 C -708.46925,-21.29499 -707.54179,-22.73934 -705.18732,-29.95247 C -696.93539,-55.23306 -697.68987,-75.77688 -707.59367,-95.47456 C -712.57242,-105.3768 -718.75187,-112.18732 -731.62558,-121.96072 C -749.79493,-135.75445 -754.56105,-137.15625 -786.5773,-138.12303 C -811.03548,-138.86158 -819.22533,-137.85243 -831.30967,-132.61117 C -841.41422,-128.22859 -852.92309,-121.13428 -856.94694,-116.80782 C -862.42886,-110.91365 -871.59256,-93.86463 -873.09828,-86.75835 C -874.82168,-78.62476 -875.00152,-64.10494 -873.4808,-55.87565 C -872.45024,-50.29887 -849.60179,10.90831 -843.61922,24.11851 C -842.10967,27.45179 -839.57019,31.21594 -837.97594,32.48329 C -835.25443,34.64676 -834.43567,34.75633 -824.5773,34.27643 C -816.14728,33.86606 -812.38419,33.14633 -805.48901,30.62559 z"
   id="path2482" />
		<path
   style="fill:#e3cc0b;fill-opacity:1"
   d="M -1045.8182,473.13508 C -1052.8293,470.63278 -1063.0915,462.55903 -1067.6294,455.97509 C -1072.8734,448.3666 -1074.8277,440.40765 -1074.3615,428.55801 C -1073.4813,406.18802 -1063.6254,391.17012 -1042.9973,380.7671 C -1033.227,375.83979 -1025.5926,374.21206 -1012.3273,374.22794 C -1005.8648,374.23568 -1000.5842,373.97561 -1000.5926,373.65001 C -1000.6318,372.13533 -1002.4364,370.82308 -1006.5773,369.29822 C -1009.0523,368.38681 -1012.2896,367.19311 -1013.7714,366.64556 L -1016.4655,365.65002 L -990.39204,326.85401 C -976.05164,305.51621 -963.79357,287.49086 -963.1519,286.79768 C -962.23964,285.8122 -952.14348,285.59412 -916.85622,285.79768 L -871.72723,286.05801 L -879.74482,298.05801 C -884.1545,304.65801 -894.32019,320.40801 -902.33524,333.05801 C -910.3503,345.70801 -920.90606,362.04211 -925.79249,369.35602 C -936.73122,385.72886 -936.88238,386.06903 -932.86193,385.26494 C -924.76832,383.64621 -916.29398,389.97066 -913.14594,399.97908 C -910.68525,407.80227 -911.35023,421.66485 -914.58846,430.05064 C -919.44935,442.6385 -938.98215,457.32185 -956.5773,461.6148 C -964.26762,463.49113 -976.32305,463.361 -980.07966,461.36112 C -986.14224,458.13362 -987.0099,456.26235 -987.56598,445.21553 C -987.84721,439.62889 -988.44136,434.49551 -988.88632,433.80801 C -989.99786,432.09058 -995.06265,432.23296 -996.5486,434.02342 C -997.33546,434.97153 -997.52817,436.88935 -997.0945,439.45618 C -995.58962,448.36349 -1004.3805,459.16735 -1019.4368,466.91463 C -1027.7433,471.1888 -1037.2191,474.60618 -1040.5088,474.51412 C -1041.3715,474.48998 -1043.7607,473.86941 -1045.8182,473.13508 z M -694.60615,472.17993 C -706.21617,467.69201 -717.5773,459.26229 -717.5773,455.13581 C -717.5773,453.89709 -715.80386,450.40702 -713.63633,447.3801 C -709.2899,441.31037 -708.06498,437.81577 -709.50638,435.59764 C -710.27303,434.41786 -711.57189,435.19656 -716.26633,439.65041 C -736.71825,459.05414 -764.66137,466.91451 -785.5773,459.14753 C -803.17882,452.61132 -813.12658,443.54958 -816.993,430.52992 C -819.00187,423.76531 -818.99872,418.35576 -816.98192,411.48951 C -813.95787,401.19407 -809.62563,394.53024 -799.28027,384.26089 C -791.13089,376.1714 -789.62079,374.21053 -790.61641,373.01089 C -792.35796,370.91245 -794.81401,371.20539 -801.0272,374.25262 C -804.04902,375.73466 -806.71005,376.74716 -806.94062,376.50262 C -807.17118,376.25809 -819.56936,355.80972 -834.49212,331.06182 C -859.00797,290.40474 -861.45906,285.94472 -859.90973,284.81182 C -858.5889,283.84601 -846.92626,283.5654 -809.13617,283.5902 L -760.0773,283.62238 L -732.22991,322.37668 L -704.38253,361.13098 L -699.28322,362.34228 C -686.5979,365.35559 -673.5065,373.69445 -661.00931,386.72172 C -654.5172,393.4892 -652.33368,396.59153 -649.83044,402.60458 C -645.64795,412.65139 -644.18054,421.79597 -644.87361,433.49453 C -645.72393,447.84723 -647.33764,451.44116 -656.40615,459.17884 C -670.11336,470.87447 -684.93427,475.91866 -694.60615,472.17993 z M -1238.2447,464.0896 C -1253.5485,459.80024 -1267.9899,451.04784 -1280.433,438.52086 C -1297.9357,420.90016 -1306.8865,403.04444 -1308.2781,382.97323 C -1308.8125,375.26519 -1308.6674,374.49631 -1305.1653,366.47323 C -1299.61,353.74611 -1298.7913,352.29349 -1293.4606,345.70544 C -1287.7377,338.63259 -1279.0421,331.33854 -1270.0956,326.10643 C -1260.076,320.24674 -1256.6583,315.38948 -1261.1235,313.35501 C -1263.7592,312.15412 -1264.6673,312.4763 -1273.7945,317.85015 L -1277.5118,320.03875 L -1282.1243,315.54838 C -1288.0461,309.78348 -1291.4576,303.95835 -1293.7468,295.70249 C -1297.4123,282.48357 -1295.3171,263.36846 -1288.8724,251.23349 C -1285.0917,244.11465 -1271.5767,230.77109 -1263.055,225.74353 C -1254.9,220.93234 -1237.2394,214.39535 -1226.2813,212.1319 C -1203.0013,207.32328 -1179.6213,214.76375 -1166.2794,231.22692 C -1161.2325,237.45453 -1156.0148,248.59101 -1154.5214,256.32268 C -1153.3325,262.47742 -1153.7084,278.7021 -1155.1849,284.96389 L -1155.87,287.86978 L -1132.4737,287.22118 C -1119.6057,286.86444 -1087.7438,286.27336 -1061.6694,285.90766 L -1014.2616,285.24275 L -1014.7997,287.30058 C -1015.0957,288.43239 -1029.8762,311.00332 -1047.6453,337.45821 L -1079.9526,385.55801 L -1120.8891,385.55801 L -1161.8255,385.55801 L -1170.4514,376.48472 C -1176.9893,369.6077 -1179.5009,367.5761 -1180.8273,368.09171 C -1183.2184,369.0212 -1183.0231,371.09723 -1180.1892,374.87473 C -1169.3319,389.347 -1166.4957,410.23875 -1173.3887,424.96877 C -1180.5687,440.3119 -1193.932,454.65869 -1207.1098,461.17153 C -1214.0787,464.61576 -1215.671,465.00221 -1223.9421,465.25677 C -1229.7062,465.43418 -1234.9842,465.00347 -1238.2447,464.0896 z M -514.74644,443.60271 C -523.1561,442.06137 -529.96272,439.64322 -537.0773,435.66934 C -554.51617,425.9288 -563.30782,412.86682 -565.58616,393.31298 C -566.55546,384.99402 -565.34752,369.8657 -563.42755,366.27819 C -562.53253,364.60583 -562.67492,363.9598 -564.18135,362.85827 C -565.20284,362.11133 -566.71014,361.62953 -567.5309,361.78759 C -569.75614,362.21613 -573.39126,369.30084 -574.66837,375.69823 L -575.79432,381.33846 L -600.93581,382.03462 C -614.76363,382.4175 -628.74788,382.5794 -632.01191,382.39439 L -637.94653,382.05801 L -672.37831,332.75774 C -691.31579,305.64259 -706.57847,283.22585 -706.29539,282.94277 C -706.01231,282.65968 -676.82243,282.21248 -641.429,281.94898 C -606.03556,281.68547 -575.1648,281.23714 -572.8273,280.95267 C -569.232,280.51514 -568.5773,280.08693 -568.5773,278.17295 C -568.5773,276.92857 -567.84927,271.66864 -566.95946,266.48423 C -562.8944,242.79957 -551.81435,222.71577 -536.36369,211.02608 C -517.3979,196.6769 -489.20122,191.73071 -468.0773,199.04745 C -440.93961,208.4472 -424.10146,224.51172 -419.08494,245.78885 C -414.05232,267.13429 -422.34714,295.12971 -441.67473,322.03054 C -446.57115,328.84554 -450.5773,335.12718 -450.5773,335.98973 C -450.5773,339.46384 -446.15342,337.10698 -437.85317,329.21084 C -433.90397,325.45392 -433.46586,325.27969 -431.12201,326.53408 C -423.09932,330.8277 -413.11446,345.6464 -410.55495,357.05801 C -409.05572,363.74232 -410.27293,383.27205 -412.67402,391.05801 C -417.29135,406.03048 -432.37668,423.62846 -447.0773,431.1916 C -456.02476,435.79487 -467.34783,439.72174 -478.5773,442.11589 C -487.34191,443.98452 -508.02447,444.83473 -514.74644,443.60271 z M -909.15747,270.72633 C -911.95156,269.68152 -915.42339,268.04973 -916.87265,267.10014 C -919.3721,265.46244 -919.8567,265.4657 -926.29248,267.16358 C -934.98433,269.45665 -952.10608,269.43763 -962.90476,267.12292 C -974.78058,264.57732 -983.41066,261.6782 -984.40577,259.90004 C -985.18007,258.51643 -986.43868,258.92281 -993.79009,262.93006 C -1000.2957,266.47625 -1003.3243,267.55801 -1006.7472,267.55801 C -1015.7048,267.55801 -1026.8625,262.90887 -1034.5303,255.98151 L -1038.2341,252.63537 L -1043.5061,256.59669 C -1046.4057,258.77542 -1049.5224,260.55801 -1050.432,260.55801 C -1053.0256,260.55801 -1065.0346,255.96453 -1071.6267,252.45098 C -1074.9191,250.69618 -1080.4969,246.61772 -1084.0218,243.38773 C -1091.1305,236.87395 -1092.5971,233.6951 -1094.5548,220.55801 C -1096.8997,204.82249 -1097.1127,204.32422 -1102.8724,201.09557 C -1111.8847,196.04374 -1133.6414,181.01393 -1145.0773,171.9399 C -1187.0027,138.67344 -1229.4648,93.99381 -1253.307,58.05801 C -1278.5101,20.07093 -1297.5003,-23.33517 -1318.9415,-91.96367 C -1324.7367,-110.51285 -1326.0935,-116.51131 -1330.4772,-142.96367 C -1337.0366,-182.54446 -1338.3946,-195.02299 -1339.5567,-226.3939 C -1340.0928,-240.86702 -1340.8296,-257.32045 -1341.194,-262.95708 L -1341.8566,-273.2055 L -1311.4669,-273.84539 C -1294.7526,-274.19732 -1268.5549,-274.58803 -1253.2497,-274.71363 L -1225.4221,-274.94199 L -1226.043,-271.94199 C -1226.3845,-270.29199 -1226.9181,-257.69199 -1227.2288,-243.94199 C -1227.6757,-224.16085 -1227.445,-215.91505 -1226.1237,-204.44199 C -1222.3053,-171.28577 -1213.2594,-135.75079 -1198.3761,-95.44199 C -1193.6984,-82.77311 -1191.3649,-78.32105 -1190.0773,-79.60865 C -1189.7761,-79.90983 -1188.4087,-87.8774 -1187.0386,-97.31435 C -1184.4353,-115.24503 -1179.6355,-135.68711 -1175.034,-148.44199 C -1173.5458,-152.56699 -1167.4733,-165.84199 -1161.5395,-177.94199 C -1152.9541,-195.44927 -1148.9309,-202.39257 -1141.8389,-211.94199 C -1102.5132,-264.89408 -1049.0556,-299.09656 -983.37785,-313.32618 C -960.15334,-318.35796 -924.38186,-320.73238 -904.60408,-318.55499 C -857.37724,-313.35563 -812.29124,-293.52529 -769.56957,-259.16226 C -754.63512,-247.14978 -731.79734,-225.77409 -722.49149,-215.09815 C -692.78441,-181.01732 -666.37955,-131.03787 -657.03008,-91.19199 C -654.22982,-79.25773 -650.7836,-81.61708 -648.67658,-96.91097 C -647.99697,-101.84391 -646.5661,-108.36891 -645.49686,-111.41097 C -643.00836,-118.49093 -638.17324,-143.33147 -636.1478,-159.44199 C -631.01037,-200.30551 -632.65136,-241.46618 -640.51335,-268.94199 C -642.47091,-275.78322 -642.47378,-275.97794 -640.63954,-277.52721 C -638.99814,-278.91359 -631.88377,-279.19568 -583.92001,-279.77621 C -553.75652,-280.14129 -503.69803,-280.44044 -472.67891,-280.44099 L -416.28053,-280.44199 L -416.87361,-255.19199 C -417.69349,-220.28643 -420.81112,-191.34094 -427.15595,-159.72597 C -439.9189,-96.13083 -465.93523,-27.6864 -497.01383,24.05801 C -548.32178,109.4833 -605.1392,169.19669 -667.0773,202.78953 C -677.75816,208.58242 -680.29144,209.79819 -705.0773,221.02657 C -713.8773,225.0131 -725.84018,230.62103 -731.66148,233.48862 L -742.24566,238.70244 L -744.0149,246.38022 C -747.85899,263.06202 -753.14233,266.76631 -773.02177,266.71768 C -782.99506,266.69328 -788.86125,265.10428 -794.30402,260.95288 L -797.66809,258.38698 L -801.97841,262.36009 C -808.36328,268.24546 -809.94294,268.79426 -822.02444,269.32438 C -835.17908,269.9016 -842.79008,268.5562 -848.65578,264.61674 L -852.86428,261.79028 L -857.26309,265.14797 C -864.06265,270.33819 -869.89951,271.6699 -888.0773,272.17841 C -902.05354,272.56938 -904.71986,272.38571 -909.15747,270.72633 z M -871.10911,255.01101 C -866.29209,252.64025 -863.06017,246.86979 -861.45982,237.7826 C -860.05216,229.78961 -861.55511,218.61768 -865.74897,205.89982 C -869.08477,195.784 -872.35265,191.50044 -879.0773,188.42894 C -888.90012,183.94235 -907.68278,188.33504 -909.60822,195.56919 C -909.97582,196.95033 -910.6047,210.52425 -911.00572,225.73345 L -911.73485,253.38654 L -904.40607,254.94235 C -892.98702,257.36648 -892.58682,257.40948 -883.5773,257.18026 C -877.51291,257.02597 -873.94024,256.40439 -871.10911,255.01101 z M -932.63647,252.18537 C -927.71801,249.91366 -925.60043,232.5644 -927.49459,210.05801 C -929.19868,189.80999 -929.25507,189.59059 -933.17632,187.95219 C -939.62031,185.25972 -943.10472,186.08031 -955.91822,193.30801 C -969.79058,201.13298 -970.17062,201.6705 -973.41741,218.05801 C -976.64419,234.3445 -977.05164,240.75615 -975.11871,244.8295 C -973.52508,248.18782 -973.03216,248.43765 -963.76503,250.58393 C -946.78472,254.51659 -938.5959,254.93787 -932.63647,252.18537 z M -817.08641,252.49759 C -811.6452,249.84548 -811.0773,247.22321 -811.0773,224.75075 L -811.0773,204.44348 L -813.56779,202.56504 C -819.15168,198.35342 -834.3599,196.19186 -841.32494,198.61988 C -845.56975,200.09963 -846.46314,204.47641 -846.73431,225.12084 C -847.02012,246.88076 -845.62897,250.37648 -835.45768,253.45708 C -830.92377,254.83027 -820.78597,254.30079 -817.08641,252.49759 z M -997.63554,248.80801 C -994.49475,245.63033 -993.64258,243.76074 -992.05189,236.55801 C -989.89505,226.79175 -989.53404,212.13296 -991.36947,208.84866 C -993.50778,205.02238 -999.03827,201.61172 -1005.8169,199.93893 C -1012.1379,198.37906 -1012.5858,198.39778 -1018.8538,200.48365 C -1022.4239,201.6717 -1026.0202,203.41195 -1026.8456,204.35087 C -1028.5354,206.27302 -1031.5773,222.80469 -1031.5773,230.06586 C -1031.5773,236.09804 -1029.9514,241.55606 -1027.0826,245.15382 C -1024.2576,248.69668 -1014.0331,252.37341 -1006.7096,252.47993 C -1001.7866,252.55154 -1001.035,252.24738 -997.63554,248.80801 z M -763.5773,250.25157 C -760.56638,249.22479 -759.81505,248.28946 -758.20053,243.55801 C -757.08168,240.27918 -756.12182,233.95762 -755.82375,227.90473 C -755.40546,219.4109 -755.67433,216.59721 -757.46883,210.68921 C -758.64863,206.80497 -760.61818,202.46559 -761.84561,201.04615 L -764.0773,198.46534 L -772.5773,200.93733 C -793.32798,206.97211 -794.07993,207.84949 -794.07062,226.01616 C -794.06331,240.29387 -792.85829,245.67257 -789.11781,248.12343 C -784.34546,251.25039 -770.00919,252.44495 -763.5773,250.25157 z M -1050.6564,244.15335 C -1048.6792,241.77092 -1045.5552,229.44715 -1044.9186,221.51805 C -1044.4755,215.99825 -1044.7516,212.47019 -1045.9494,208.35004 C -1047.5822,202.73315 -1047.5955,202.71983 -1052.6306,201.63999 C -1059.8013,200.10216 -1079.0561,200.21886 -1080.3509,201.80801 C -1082.8437,204.86748 -1083.3415,210.30101 -1081.9341,219.08976 C -1079.4009,234.90899 -1076.2253,239.25609 -1064.4634,243.00534 C -1055.7561,245.78088 -1052.2492,246.07248 -1050.6564,244.15335 z M -915.19898,135.59358 C -914.84,133.34865 -915.01356,128.5869 -915.58466,125.01193 C -916.71103,117.96114 -916.04122,115.41185 -912.5749,113.55673 C -910.11927,112.24251 -905.79349,113.2655 -904.68307,115.42304 C -904.22026,116.32227 -903.26888,119.53301 -902.5689,122.55801 C -901.86892,125.58301 -900.91521,129.08466 -900.44955,130.33945 C -899.65529,132.47969 -899.45806,132.52598 -897.26258,131.08745 C -895.47698,129.91748 -894.62868,127.96063 -893.68361,122.83157 C -893.00234,119.13422 -890.03729,108.67261 -887.09459,99.58356 C -884.15189,90.49451 -881.00879,80.20474 -880.10991,76.71741 C -877.86673,68.01463 -878.0128,51.31356 -880.48461,33.8779 C -881.59026,26.07885 -882.77909,15.50385 -883.12645,10.3779 C -883.4738,5.25196 -886.16301,-12.21699 -889.10247,-28.44199 C -892.04193,-44.66699 -894.93121,-62.89199 -895.52311,-68.94199 C -896.90274,-83.04378 -897.6736,-85.86261 -900.25444,-86.24317 C -902.01066,-86.50214 -902.45265,-85.73123 -903.40776,-80.74317 C -905.4731,-69.95695 -906.45871,-58.02357 -907.06672,-36.44199 C -907.68586,-14.46564 -909.19848,6.35975 -910.41429,9.64638 C -911.0034,11.23891 -911.42556,11.32055 -913.58558,10.25971 C -919.23091,7.48714 -922.50029,-11.28925 -922.55362,-41.24458 C -922.56889,-49.82279 -923.15211,-57.07442 -924.19581,-61.66321 C -925.80261,-68.72781 -925.8268,-68.76269 -927.54153,-66.48941 C -928.85838,-64.74362 -929.52807,-60.60521 -930.36026,-49.07079 C -931.11102,-38.66494 -933.35177,-23.79605 -937.53794,-1.44199 C -940.88533,16.43301 -944.31741,37.39059 -945.16479,45.13041 C -946.64518,58.65212 -946.62374,59.70872 -944.61701,72.13041 C -940.33881,98.61263 -931.70694,124.15573 -921.50471,140.52346 L -919.34465,143.98892 L -917.59816,141.83209 C -916.63759,140.64584 -915.55796,137.83851 -915.19898,135.59358 z M -1146.8644,127.06484 C -1147.1856,123.95291 -1148.3076,120.34119 -1149.4526,118.73314 C -1152.2992,114.73548 -1155.0548,107.34282 -1157.0483,98.35601 C -1157.9879,94.11991 -1159.3913,90.12731 -1160.167,89.48356 C -1161.1456,88.67136 -1161.5773,86.07311 -1161.5773,80.99458 C -1161.5773,76.80326 -1162.0418,73.38895 -1162.6644,73.00417 C -1163.2623,72.63464 -1163.5462,71.54699 -1163.2952,70.58718 C -1163.0442,69.62737 -1163.1861,68.21566 -1163.6105,67.45004 C -1164.4604,65.91709 -1162.0994,31.14476 -1160.7661,25.55801 C -1160.3067,23.63301 -1160.2645,16.65801 -1160.6722,10.05801 C -1161.2504,0.69867 -1162.2017,-4.57884 -1164.9954,-13.92466 C -1166.9654,-20.51513 -1168.5773,-27.04817 -1168.5773,-28.44253 C -1168.5773,-29.83688 -1169.743,-32.69317 -1171.1677,-34.78984 C -1172.5924,-36.88651 -1174.8318,-41.02972 -1176.144,-43.99698 C -1177.9167,-48.00531 -1179.1975,-49.55954 -1181.1268,-50.04378 C -1185.91,-51.24428 -1186.1824,-49.15884 -1182.343,-40.73374 C -1172.6554,-19.47535 -1171.2421,-8.39692 -1171.8597,41.4406 C -1172.3374,79.97908 -1172.3333,80.07825 -1169.8607,89.95914 C -1166.5659,103.12546 -1161.9764,113.73245 -1155.1072,124.05627 C -1148.2896,134.30243 -1146.0324,135.12629 -1146.8644,127.06484 z M -687.85875,128.64693 C -683.29835,125.34339 -681.51043,123.00578 -675.82054,112.90755 C -670.16007,102.86153 -669.22294,97.06174 -668.00827,64.55801 C -667.52452,51.6133 -667.76309,43.28363 -668.92477,32.55801 C -669.78853,24.58301 -670.8001,14.30783 -671.1727,9.72427 C -671.6289,4.11236 -672.29551,1.21964 -673.21373,0.86728 C -674.28755,0.45522 -674.5773,-3.1003 -674.5773,-15.86532 C -674.5773,-35.17129 -673.63576,-41.0056 -668.91642,-50.94318 C -666.51309,-56.00391 -665.55358,-59.21136 -665.95936,-60.82808 C -668.69477,-71.72684 -679.2902,-49.83262 -681.75032,-28.19792 C -683.18107,-15.6156 -681.95813,-0.48977 -677.08321,29.5267 L -673.59651,50.99538 L -674.55101,70.5267 C -675.541,90.78417 -676.81771,97.99852 -681.05448,107.27608 C -683.68379,113.03366 -691.013,121.4281 -696.22082,124.64671 C -699.5843,126.72546 -700.67124,129.94993 -698.3273,130.89573 C -695.26356,132.13198 -691.57628,131.3399 -687.85875,128.64693 z M -980.5773,43.3811 C -975.81103,41.89578 -969.99713,37.5229 -966.54185,32.82445 C -963.49521,28.68166 -959.47473,14.50124 -955.69242,-5.44199 C -952.30201,-23.3188 -947.5773,-63.46039 -947.5773,-74.38884 C -947.5773,-87.73452 -954.77232,-105.06306 -968.14868,-123.93311 C -971.83798,-129.1376 -975.80574,-133.69711 -976.96593,-134.06534 C -979.89317,-134.99441 -994.71422,-134.62161 -1002.0173,-133.43521 C -1011.0788,-131.96315 -1026.8968,-127.16272 -1037.589,-122.63997 C -1042.8076,-120.43255 -1055.1133,-115.86103 -1064.9352,-112.48104 C -1106.0156,-98.34401 -1112.9752,-94.48389 -1119.0707,-82.45492 C -1124.5381,-71.66564 -1125.2251,-61.79872 -1122.8315,-28.44199 C -1121.8058,-14.1466 -1120.8864,-11.76382 -1113.3026,-3.74511 C -1102.076,8.12542 -1087.1444,14.82212 -1059.1027,20.56306 C -1050.6072,22.30232 -1047.2706,23.63312 -1036.6027,29.53718 C -1020.5671,38.41189 -1012.4419,42.05073 -1005.5773,43.4318 C -1002.5523,44.04039 -999.1773,44.73818 -998.0773,44.98245 C -995.19911,45.6216 -984.6773,44.65879 -980.5773,43.3811 z M -812.22164,32.96909 C -804.3238,30.92673 -794.86527,26.53626 -778.9493,17.52469 C -763.17266,8.59202 -756.00258,5.34469 -745.99192,2.5983 C -735.74498,-0.2129 -724.73304,-6.07727 -716.0773,-13.33262 C -709.84508,-18.55654 -708.76277,-20.00858 -706.20967,-26.57105 C -699.57152,-43.63368 -697.67587,-65.68754 -701.54652,-80.82163 C -704.0816,-90.73369 -711.45622,-104.22567 -717.81428,-110.58373 C -724.93262,-117.70207 -739.88319,-128.635 -748.0773,-132.71422 C -754.07585,-135.70044 -756.73011,-136.35943 -766.63025,-137.32049 C -781.09225,-138.72438 -809.00967,-138.76237 -817.46972,-137.38966 C -824.842,-136.19345 -841.17211,-128.82893 -850.50328,-122.49226 C -854.83923,-119.54777 -857.8592,-116.47693 -860.40909,-112.41958 C -862.42661,-109.20934 -865.78615,-103.86137 -867.87475,-100.5352 C -870.2559,-96.74315 -872.20748,-91.96161 -873.10739,-87.71481 C -874.79751,-79.73889 -875.01294,-63.16588 -873.53071,-55.14779 C -872.95509,-52.03395 -866.64576,-34.28881 -859.50999,-15.71413 C -842.83315,27.69627 -842.92747,27.47705 -839.27962,31.30801 C -836.24027,34.49993 -836.02574,34.55801 -827.27548,34.55801 C -822.37526,34.55801 -815.60103,33.843 -812.22164,32.96909 z"
   id="path2480" />
		<path
   style="fill:#e3cc0b;fill-opacity:1"
   d="M -1049.2406,471.67751 C -1055.2729,468.86069 -1065.5819,459.12896 -1069.2089,452.82735 C -1073.4579,445.44493 -1075.0044,437.49833 -1074.2806,426.76694 C -1073.3413,412.83977 -1068.9719,402.2781 -1060.6538,393.82774 C -1047.213,380.17325 -1033.0689,374.50729 -1012.3273,374.46874 C -1005.8648,374.45673 -1000.5842,374.1344 -1000.5926,373.75245 C -1000.6325,371.94484 -1002.5709,370.64515 -1008.358,368.54592 C -1011.8124,367.29286 -1014.8711,365.89167 -1015.1551,365.43217 C -1015.4391,364.97267 -1003.6674,346.81301 -988.99591,325.07736 L -962.3204,285.55801 L -916.92649,285.55801 L -871.53257,285.55801 L -878.40642,295.80801 C -882.18703,301.44551 -893.74215,319.33301 -904.08446,335.55801 C -914.42677,351.78301 -925.53607,369.00423 -928.7718,373.82738 C -932.00752,378.65053 -934.88912,383.20702 -935.17534,383.95291 C -935.56688,384.97325 -934.24107,385.41428 -929.82113,385.73399 C -922.14984,386.28888 -918.13628,389.13765 -914.69897,396.46749 C -912.36545,401.44355 -912.0773,403.27274 -912.0773,413.10987 C -912.0773,423.90266 -912.16691,424.34305 -915.8999,431.89624 C -919.07498,438.32058 -920.9383,440.63978 -926.8999,445.58753 C -934.86691,452.19964 -946.22542,458.5242 -954.5088,460.9605 C -957.74682,461.91287 -963.6438,462.55801 -969.11092,462.55801 C -977.00102,462.55801 -978.75395,462.23965 -981.66485,460.27799 C -986.52559,457.00234 -987.54583,454.23971 -987.56256,444.30801 C -987.57503,436.90344 -987.88483,435.25048 -989.5773,433.55801 C -991.99982,431.13549 -992.48645,431.10565 -995.47172,433.19661 C -997.5326,434.64011 -997.73713,435.3753 -997.18945,439.37102 C -995.86791,449.01275 -1005.5009,460.0666 -1022.3967,468.29613 C -1034.0492,473.97182 -1042.1437,474.99144 -1049.2406,471.67751 z M -697.65722,470.69601 C -708.92626,465.88711 -717.5773,458.85328 -717.5773,454.49975 C -717.5773,453.51605 -715.97396,450.61072 -714.01433,448.04346 C -709.25955,441.81436 -708.19031,439.23602 -709.00906,435.97386 L -709.69466,433.24223 L -714.88598,438.23145 C -729.08835,451.88093 -743.8722,459.19202 -762.20339,461.63144 C -773.01705,463.07047 -782.07593,461.20903 -794.48128,454.99889 C -808.51507,447.97355 -816.62265,437.53196 -818.15279,424.5128 C -819.78261,410.64563 -810.56999,392.93536 -795.16997,380.33078 C -791.54551,377.36424 -789.02027,374.56722 -789.30248,373.83181 C -790.3487,371.10538 -794.66682,371.23328 -800.84264,374.17362 C -804.21649,375.77993 -807.0675,376.61491 -807.27684,376.05801 C -807.48359,375.50801 -819.76964,355.03301 -834.57917,330.55801 C -858.69176,290.70831 -861.33129,285.92641 -859.8376,284.79871 C -858.53821,283.8177 -847.33743,283.59671 -809.15319,283.79871 L -760.13679,284.05801 L -732.37122,322.52039 L -704.60565,360.98276 L -698.84147,362.58542 C -686.08271,366.13284 -676.22456,372.0525 -664.63285,383.12715 C -655.05809,392.27482 -651.19929,398.0453 -647.79001,408.31407 C -645.6022,414.90377 -645.20907,417.92114 -645.15248,428.55801 C -645.05486,446.90417 -646.36655,450.46946 -656.3235,458.92183 C -665.4995,466.71127 -671.12126,469.94371 -679.11226,472.0251 C -687.22917,474.13929 -690.06454,473.93608 -697.65722,470.69601 z M -1239.1967,463.58127 C -1254.0662,459.68272 -1268.6918,450.41203 -1282.1824,436.33406 C -1298.6557,419.14359 -1306.8329,402.41222 -1308.2205,383.05801 C -1308.7717,375.3686 -1308.6539,374.76793 -1305.1856,367.58622 C -1303.2011,363.47674 -1301.5773,359.36374 -1301.5773,358.44623 C -1301.5773,353.8575 -1285.391,336.18963 -1275.0773,329.52063 C -1263.6102,322.10582 -1261.6777,320.64085 -1260.0139,318.10158 C -1258.6646,316.04228 -1258.5809,315.25862 -1259.5815,314.053 C -1261.5318,311.70299 -1264.7269,312.27574 -1270.6236,316.03241 C -1273.6232,317.94334 -1276.5782,319.51834 -1277.1905,319.53241 C -1279.0803,319.57587 -1287.2689,310.10019 -1290.0015,304.7076 C -1295.5774,293.70415 -1297.0143,280.05474 -1294.0702,266.05801 C -1290.3551,248.39565 -1276.9519,232.72177 -1257.0773,222.79788 C -1249.012,218.77066 -1230.4419,212.86546 -1221.4611,211.47202 C -1202.1209,208.47129 -1183.317,214.50015 -1170.075,227.94726 C -1156.1759,242.06175 -1150.4346,262.56856 -1154.9771,281.87439 L -1156.3456,287.69076 L -1109.2115,286.87439 C -1045.2101,285.76587 -1015.322,285.82407 -1014.9168,287.05801 C -1014.7362,287.60801 -1029.0999,309.65801 -1046.8361,336.05801 L -1079.0838,384.05801 L -1120.7975,384.31896 L -1162.5112,384.5799 L -1170.6821,376.06896 C -1175.1761,371.38794 -1179.4108,367.55801 -1180.0927,367.55801 C -1180.7745,367.55801 -1181.84,368.16966 -1182.4605,368.91723 C -1183.3355,369.97155 -1182.6073,371.73962 -1179.2146,376.79909 C -1168.8939,392.18992 -1166.7515,411.8432 -1173.8449,426.05801 C -1177.5923,433.56763 -1185.8276,444.56282 -1192.0987,450.42911 C -1206.7859,464.16835 -1221.3963,468.24829 -1239.1967,463.58127 z M -514.34181,443.48225 C -539.33828,439.62056 -558.32992,423.59277 -564.1134,401.47805 C -566.0919,393.91273 -565.80454,370.68529 -563.68369,366.74409 C -562.151,363.89587 -563.82109,361.29922 -566.88947,361.75975 C -569.95903,362.22047 -572.42115,366.3692 -574.33221,374.30095 L -576.0773,381.5439 L -607.11739,381.55095 L -638.15747,381.55801 L -672.42779,332.45175 C -691.27646,305.4433 -706.54068,283.18806 -706.34827,282.99565 C -706.15586,282.80324 -675.19814,282.28856 -637.55334,281.85191 L -569.10823,281.05801 L -567.43487,270.29057 C -565.21639,256.01553 -562.38409,246.9468 -556.74351,236.05801 C -552.99847,228.82843 -550.21219,225.18443 -542.57933,217.53361 C -536.30083,211.24033 -530.95827,206.89572 -526.83103,204.72696 C -514.40579,198.19781 -490.60003,194.10236 -478.40237,196.39548 C -470.78374,197.82776 -456.06373,203.43895 -448.90121,207.64115 C -445.69806,209.52042 -439.36006,214.71739 -434.81677,219.18997 C -428.26704,225.63775 -425.83955,228.87311 -423.09573,234.81174 C -417.05501,247.8861 -416.28105,261.47655 -420.60445,278.55801 C -424.56985,294.22503 -430.7322,306.7167 -442.75733,323.46403 C -451.48369,335.61716 -452.57172,338.64318 -447.65394,337.08233 C -446.48536,336.71144 -442.89242,333.96674 -439.66962,330.983 C -436.44682,327.99925 -433.3563,325.55801 -432.8018,325.55801 C -430.8946,325.55801 -421.23547,335.05358 -418.05774,340.05241 C -411.45905,350.43269 -410.18764,355.53783 -410.39132,370.83579 C -410.53646,381.73662 -411.00677,385.91283 -412.64366,390.83579 C -418.21133,407.5806 -432.7295,424.09375 -449.16195,432.37216 C -454.8893,435.25751 -470.21276,440.19524 -479.20163,442.05194 C -488.78926,444.03232 -506.19532,444.7408 -514.34181,443.48225 z M -907.29126,271.1828 C -909.60894,270.41692 -913.48719,268.62878 -915.9096,267.20916 C -918.33201,265.78953 -920.55168,264.86572 -920.8422,265.15624 C -922.60645,266.92049 -933.43388,268.61705 -943.0773,268.64027 C -958.45519,268.6773 -981.06171,263.85926 -984.2445,259.86647 C -985.24176,258.61541 -986.69775,259.08348 -994.2445,263.08127 C -1002.633,267.52497 -1003.3911,267.73592 -1009.3168,267.27516 C -1017.0648,266.67271 -1028.6648,261.40386 -1034.0089,256.05973 L -1037.7552,252.31343 L -1040.9163,254.62055 C -1042.6548,255.88947 -1045.3224,257.83477 -1046.8443,258.94344 L -1049.6112,260.9592 L -1057.8443,258.27533 C -1067.4737,255.13625 -1076.8945,249.83035 -1083.7757,243.67058 C -1091.2917,236.94246 -1092.3548,234.18861 -1095.6035,213.03195 C -1096.197,209.16762 -1096.9963,205.51334 -1097.3799,204.91132 C -1097.7635,204.3093 -1101.2268,201.89484 -1105.0761,199.54585 C -1139.6029,178.47663 -1175.8256,148.27212 -1207.29,114.31417 C -1241.9834,76.87138 -1257.3681,55.28709 -1276.6117,17.05801 C -1291.9658,-13.44417 -1305.1292,-47.87754 -1320.5748,-97.94199 C -1328.3912,-123.27773 -1336.8425,-176.14314 -1338.5596,-210.44199 C -1339.1241,-221.71699 -1340.0592,-240.32927 -1340.6376,-251.80261 C -1341.2161,-263.27595 -1341.5278,-272.82478 -1341.3304,-273.02222 C -1341.133,-273.21966 -1314.9541,-273.69347 -1283.1551,-274.07512 C -1226.5049,-274.75504 -1225.3506,-274.73044 -1225.9275,-272.85551 C -1226.2514,-271.80308 -1227.0101,-263.96699 -1227.6137,-255.44199 C -1230.4286,-215.68049 -1223.2431,-168.95267 -1206.5548,-118.49541 C -1199.9083,-98.39982 -1193.5213,-81.64041 -1192.0412,-80.41206 C -1190.0201,-78.73463 -1188.5788,-80.11969 -1188.5667,-83.75101 C -1188.5494,-88.96685 -1184.7374,-112.15555 -1182.0419,-123.44199 C -1177.8469,-141.0072 -1170.4958,-161.72097 -1166.326,-167.72589 C -1165.2627,-169.25703 -1161.9257,-176.00703 -1158.9102,-182.72589 C -1150.021,-202.53239 -1136.1398,-221.6368 -1116.0381,-241.72993 C -1095.0115,-262.74758 -1074.4392,-277.44381 -1047.0773,-290.99335 C -1011.2546,-308.73266 -974.64866,-317.59932 -931.0773,-319.09077 C -863.53459,-321.40276 -797.28862,-290.40957 -734.0773,-226.92429 C -699.11685,-191.81233 -670.44716,-141.83861 -657.92938,-94.19199 C -656.37604,-88.27949 -654.58812,-83.44199 -653.95622,-83.44199 C -651.68492,-83.44199 -649.83172,-88.10678 -648.59149,-96.94584 C -647.89724,-101.89372 -646.50296,-108.19199 -645.49309,-110.94199 C -643.13253,-117.3701 -639.01178,-137.87752 -636.58136,-155.29231 C -630.87982,-196.14582 -631.92038,-235.63346 -639.49306,-265.78709 L -642.21666,-276.63218 L -640.14698,-277.9722 C -638.46628,-279.06037 -617.2629,-279.44722 -527.3273,-280.03059 L -416.5773,-280.74898 L -416.5773,-265.82842 C -416.5773,-186.70923 -435.04341,-105.51927 -471.18399,-25.7392 C -481.69487,-2.53651 -484.41895,2.69714 -496.32234,22.55801 C -549.54155,111.35454 -607.22179,171.47022 -671.0773,204.69168 C -677.1273,207.83926 -692.8773,215.33226 -706.0773,221.34281 C -719.2773,227.35336 -732.83409,233.66399 -736.20351,235.36645 L -742.32971,238.46182 L -744.61286,247.75991 C -746.5212,255.53161 -747.48744,257.65387 -750.49872,260.68772 C -755.10524,265.32877 -762.20931,266.93918 -775.51058,266.35763 C -785.09947,265.93839 -790.98547,264.04128 -795.78809,259.822 C -797.34009,258.4585 -797.94338,258.71161 -802.28809,262.54903 C -808.61414,268.13645 -810.22803,268.67243 -822.5773,269.28719 C -834.71127,269.89122 -843.8965,268.07739 -849.20404,264.02914 C -850.98594,262.67002 -852.7335,261.55801 -853.0875,261.55801 C -853.44151,261.55801 -855.07045,262.89732 -856.70739,264.53425 C -861.58948,269.41635 -870.56438,271.58635 -888.0773,272.11904 C -899.24344,272.45868 -904.15435,272.21939 -907.29126,271.1828 z M -871.11463,255.51525 C -867.57412,253.77379 -864.03278,248.78552 -862.34107,243.15697 C -860.22793,236.12625 -861.00588,221.28088 -864.02317,211.05801 C -868.86675,194.64753 -871.68339,190.90743 -881.76998,187.49278 C -889.85241,184.75661 -903.87248,187.72633 -908.72132,193.2016 C -910.12803,194.79005 -910.46944,199.26037 -911.08659,224.17204 L -911.80784,253.28607 L -904.94257,254.88361 C -901.16667,255.76226 -897.1773,256.69506 -896.0773,256.9565 C -891.78395,257.9769 -874.03606,256.95221 -871.11463,255.51525 z M -932.87615,252.91817 C -927.78313,251.6399 -925.47055,232.58284 -927.47349,208.39697 C -928.12661,200.51054 -928.87246,193.0585 -929.13094,191.83687 C -929.69847,189.15469 -932.06854,187.77947 -938.04905,186.66219 C -942.37142,185.85468 -943.0344,186.08618 -954.81335,192.51589 C -965.94096,198.59006 -967.28979,199.63134 -969.37058,203.75385 C -971.84963,208.66541 -975.21108,223.76035 -976.20024,234.4232 C -976.8929,241.88986 -975.08828,247.98709 -971.91859,248.8895 C -969.71047,249.51815 -952.11519,253.33685 -948.5773,253.95525 C -945.82247,254.43678 -936.46389,253.81863 -932.87615,252.91817 z M -816.93551,252.63339 C -812.90178,250.80176 -812.76156,250.57273 -811.56097,243.85459 C -810.77673,239.46626 -810.47932,231.01847 -810.74356,220.63585 C -811.14148,204.99997 -811.25659,204.23613 -813.48712,202.42995 C -820.99994,196.34644 -842.76671,195.63713 -845.10718,201.39957 C -845.47766,202.31171 -846.19131,210.48301 -846.69308,219.55801 C -848.02159,243.58555 -846.23309,249.81587 -837.0773,253.05507 C -831.32057,255.09173 -821.91582,254.89484 -816.93551,252.63339 z M -997.72868,249.07581 C -994.36667,246.03844 -993.66431,244.6013 -992.23048,237.82581 C -988.55015,220.43449 -988.86092,211.75126 -993.35483,206.41056 C -998.71336,200.04231 -1009.7864,197.27745 -1018.5078,200.13007 C -1027.049,202.92376 -1028.3985,204.6641 -1030.0834,215.05801 C -1032.7216,231.33258 -1031.7601,240.17443 -1026.7656,245.56733 C -1023.4414,249.15663 -1013.9207,252.47925 -1006.8302,252.52452 C -1002.2199,252.55394 -1001.1153,252.13538 -997.72868,249.07581 z M -763.17506,250.1633 C -758.49409,248.20747 -756.48871,242.13841 -755.84338,227.97482 C -755.28282,215.67174 -756.67087,208.64264 -760.87491,202.49518 C -762.88229,199.55984 -763.72353,199.09973 -766.63675,199.34373 C -771.2869,199.73323 -787.63579,205.3905 -789.96532,207.41622 C -793.43747,210.43555 -794.61744,215.1169 -794.60495,225.82327 C -794.58532,242.64625 -792.3017,248.15246 -784.48361,250.22753 C -778.33192,251.86032 -767.15596,251.82663 -763.17506,250.1633 z M -1050.1425,243.29789 C -1047.7883,239.70485 -1044.5848,224.66181 -1044.6612,217.55801 C -1044.6996,213.98301 -1045.2686,209.275 -1045.9256,207.09578 C -1046.9773,203.6074 -1047.6558,202.97376 -1051.5987,201.79745 C -1054.0619,201.0626 -1061.3808,200.3706 -1067.8629,200.25968 C -1080.8213,200.03794 -1080.7293,199.99824 -1082.5617,206.60587 C -1083.2679,209.15243 -1083.1223,212.77066 -1082.0458,219.42632 C -1079.6022,234.53443 -1076.1412,239.30796 -1064.8769,243.10627 C -1055.8494,246.15032 -1052.0439,246.19981 -1050.1425,243.29789 z M -916.45228,140.30801 C -914.94047,136.71544 -914.68687,129.59642 -915.81048,122.29119 C -916.42955,118.26621 -916.23501,117.21572 -914.56048,115.54119 C -912.00857,112.98928 -906.01263,112.84677 -904.74968,115.30801 C -904.25578,116.27051 -903.06549,120.32452 -902.10459,124.31692 C -901.14369,128.30931 -900.05687,131.76162 -899.68944,131.9887 C -899.32201,132.21579 -898.04187,131.64928 -896.8447,130.7298 C -895.2765,129.52536 -894.211,126.82519 -893.03321,121.07085 C -892.13407,116.67792 -889.90021,108.57792 -888.06907,103.07085 C -876.65224,68.73527 -876.11447,63.62702 -880.59318,32.05801 C -881.60755,24.90801 -882.73231,14.78301 -883.09265,9.55801 C -883.45299,4.33301 -886.14667,-13.21699 -889.07861,-29.44199 C -892.01055,-45.66699 -894.91264,-64.01583 -895.52769,-70.2172 C -896.83073,-83.35532 -897.77092,-86.44199 -900.46969,-86.44199 C -901.98468,-86.44199 -902.64228,-85.36621 -903.46105,-81.54844 C -905.49198,-72.07856 -906.57229,-58.6584 -907.61535,-29.94199 C -908.1947,-13.99199 -909.07132,1.30801 -909.56339,4.05801 C -910.05547,6.80801 -910.4849,9.61086 -910.51769,10.28657 C -910.61871,12.36866 -915.20227,9.66498 -916.60187,6.69774 C -920.20702,-0.94543 -920.81259,-5.37562 -921.61023,-29.94199 C -922.34594,-52.6009 -923.49476,-63.51084 -925.54417,-67.30126 C -926.07747,-68.2876 -926.83516,-67.73887 -928.30577,-65.30126 C -929.98797,-62.51296 -930.43023,-59.56244 -930.9078,-47.94199 C -931.37171,-36.65406 -932.65938,-27.74297 -937.55493,-1.94199 C -940.8944,15.65801 -944.35165,36.35801 -945.23771,44.05801 C -946.74825,57.18485 -946.73854,58.80623 -945.08203,70.05466 C -942.87571,85.03647 -938.77044,101.43315 -934.02395,114.22122 C -929.58892,126.17016 -920.70484,143.55801 -919.03473,143.55801 C -918.3666,143.55801 -917.2045,142.09551 -916.45228,140.30801 z M -1146.5773,128.373 C -1146.5773,125.52566 -1147.7239,121.97235 -1150.1645,117.25612 C -1152.1375,113.44359 -1154.8444,106.01723 -1156.1797,100.75311 C -1157.5151,95.48898 -1159.239,90.47908 -1160.0106,89.61999 C -1161.2086,88.28613 -1162.1877,80.62613 -1162.5366,69.85757 C -1162.5758,68.64733 -1162.9534,67.44362 -1163.3756,67.18267 C -1164.307,66.60703 -1162.0589,31.67846 -1160.7287,26.05801 C -1160.1618,23.66287 -1160.1091,17.04281 -1160.5972,9.55801 C -1161.2479,-0.41819 -1162.1351,-5.26388 -1164.9918,-14.44199 C -1166.9605,-20.76699 -1168.6104,-27.06699 -1168.6584,-28.44199 C -1168.7064,-29.81699 -1171.0714,-35.21699 -1173.914,-40.44199 C -1179.1543,-50.07446 -1181.2577,-51.83951 -1185.0001,-49.74513 C -1186.2365,-49.05323 -1185.8119,-47.52843 -1182.4239,-40.49258 C -1177.704,-30.69083 -1174.2448,-17.91841 -1172.6177,-4.28449 C -1171.877,1.9215 -1171.5649,19.61233 -1171.7444,45.21551 L -1172.0237,85.05801 L -1169.2537,94.05801 C -1165.8733,105.04159 -1159.1639,119.08318 -1153.605,126.80801 C -1148.5736,133.79977 -1146.5773,134.24433 -1146.5773,128.373 z M -689.62801,130.08423 C -685.66618,128.03549 -680.82185,122.10532 -675.87183,113.24465 C -672.58882,107.36797 -671.35677,103.78005 -670.2549,96.88738 C -669.47859,92.03123 -668.81464,86.93301 -668.77945,85.55801 C -668.74425,84.18301 -668.39669,75.15516 -668.00707,65.49612 C -667.41942,50.92745 -667.68083,44.0247 -669.54083,24.99612 C -671.13022,8.73593 -672.18972,1.73479 -673.18014,0.94777 C -674.26474,0.0859 -674.57561,-3.49345 -674.56975,-15.05223 C -674.56032,-33.62147 -673.48169,-40.39188 -669.06417,-49.60968 C -665.24561,-57.57769 -664.71844,-61.48431 -667.18551,-63.5318 C -669.13108,-65.14648 -670.21197,-63.9358 -674.72632,-55.08552 C -678.96424,-46.77715 -681.55764,-35.68515 -682.24172,-22.94199 C -682.91994,-10.30799 -681.85821,0.91021 -677.20703,30.25424 C -674.02416,50.33484 -673.93436,51.7011 -674.62377,69.55801 C -675.39534,89.54268 -676.90197,98.1405 -681.23884,107.30789 C -683.8674,112.86422 -690.87692,120.78483 -697.46461,125.64268 C -700.65947,127.99861 -700.75484,128.23761 -699.14318,129.84927 C -697.04425,131.9482 -693.40624,132.03803 -689.62801,130.08423 z M -979.04159,43.10753 C -974.08787,41.03774 -968.11836,36.16952 -965.66356,32.19758 C -961.91567,26.13337 -955.48325,-1.82171 -952.17069,-26.44199 C -949.6874,-44.89882 -947.5773,-66.83931 -947.5773,-74.20345 C -947.5773,-87.89542 -952.8436,-101.43311 -965.37006,-119.94199 C -972.57982,-130.595 -974.79189,-133.15923 -977.62276,-134.14526 C -986.61553,-137.27759 -1018.437,-131.49844 -1035.6215,-123.612 C -1039.2208,-121.96017 -1052.0458,-117.16898 -1064.1215,-112.96489 C -1105.7173,-98.48355 -1113.3931,-94.28213 -1118.9361,-82.96193 C -1124.7489,-71.0907 -1125.2823,-63.43896 -1122.8188,-27.26874 C -1121.8248,-12.67433 -1120.8544,-10.61727 -1110.3957,-0.93431 C -1099.5209,9.13382 -1085.2961,15.28604 -1061.5773,20.17958 C -1049.9016,22.58846 -1048.1541,23.27396 -1035.0773,30.57531 C -1019.6518,39.18799 -1013.0839,42.06267 -1004.0773,44.14351 C -996.88497,45.80518 -984.24628,45.2822 -979.04159,43.10753 z M -810.0773,32.4086 C -803.21518,30.44145 -787.50849,23.06475 -779.73912,18.16016 C -770.93381,12.60161 -755.40169,5.56163 -744.47218,2.1753 C -731.62743,-1.80443 -721.38566,-7.71901 -712.76383,-16.13614 C -708.4854,-20.31299 -707.43954,-22.18537 -704.77294,-30.44199 C -700.45665,-43.80654 -699.29222,-50.46681 -699.26573,-61.94199 C -699.23593,-74.85297 -700.76718,-81.86026 -706.03992,-92.94199 C -711.88552,-105.2277 -716.30282,-110.44428 -729.65305,-120.8278 C -744.60546,-132.45745 -752.01907,-135.83555 -766.21112,-137.48593 C -779.6071,-139.04374 -808.82074,-139.10852 -817.55121,-137.59978 C -825.08173,-136.29841 -845.31287,-126.6825 -853.0495,-120.72736 C -859.85159,-115.49157 -870.81178,-97.65713 -873.01186,-88.24458 C -874.94973,-79.95382 -875.04277,-61.19825 -873.18698,-52.94199 C -871.39671,-44.97722 -844.20536,25.01055 -841.04691,29.7833 C -838.70761,33.31822 -837.56705,33.9347 -831.5773,34.90171 C -827.15207,35.61613 -817.26831,34.47003 -810.0773,32.4086 z"
   id="path2478" />
		<path
   style="fill:#e3cc0b;fill-opacity:1"
   d="M -1049.5773,471.35365 C -1052.0523,470.14212 -1057.5121,465.75498 -1061.7101,461.60444 C -1067.7857,455.59764 -1069.7962,452.83388 -1071.5645,448.05801 C -1076.077,435.87062 -1075.0529,419.05281 -1068.9735,405.50598 C -1066.9521,401.00183 -1064.3014,397.62475 -1058.5136,392.18008 C -1045.0241,379.49008 -1031.1724,374.29919 -1011.6917,374.63366 C -1002.0005,374.80005 -1001.0773,374.65649 -1001.0773,372.9831 C -1001.0773,371.63406 -1002.9249,370.44789 -1008.0773,368.489 C -1011.9273,367.02528 -1015.0773,365.42951 -1015.0773,364.94285 C -1015.0773,364.45619 -1003.1829,346.39551 -988.64536,324.80801 L -962.21341,285.55801 L -917.39536,285.55801 C -892.74543,285.55801 -872.5773,285.83378 -872.5773,286.17084 C -872.5773,286.50789 -876.77918,293.14539 -881.91481,300.92084 C -887.05045,308.69628 -897.25036,324.50801 -904.58129,336.05801 C -911.91222,347.60801 -921.88534,363.00863 -926.74378,370.2816 C -931.60221,377.55457 -935.5773,383.96707 -935.5773,384.5316 C -935.5773,385.09613 -933.50107,385.55801 -930.96345,385.55801 C -919.18667,385.55801 -911.5773,396.36649 -911.5773,413.09444 C -911.5773,428.55237 -918.46758,440.30726 -933.50467,450.50277 C -946.1827,459.09877 -956.38828,462.55801 -969.07052,462.55801 C -983.50719,462.55801 -986.82216,459.25851 -987.5773,444.13755 C -988.05629,434.5463 -988.18999,434.06252 -990.75896,432.62496 C -993.21967,431.24799 -993.61945,431.28618 -995.61099,433.0885 C -997.38836,434.697 -997.6807,435.787 -997.22547,439.10823 C -995.7059,450.19474 -1008.9364,463.51322 -1028.9541,471.04787 C -1037.2526,474.1714 -1043.6279,474.26592 -1049.5773,471.35365 z M -696.35401,471.07578 C -707.10756,466.88463 -717.5773,458.76156 -717.5773,454.60944 C -717.5773,453.98254 -715.5523,450.51218 -713.0773,446.89755 C -708.67171,440.46336 -707.96243,438.32391 -709.18161,435.14678 C -709.65245,433.91978 -711.24473,434.90872 -716.39141,439.62472 C -730.00006,452.09458 -745.66748,459.45436 -763.0773,461.55545 C -771.55146,462.57815 -772.60157,462.48958 -781.05041,460.03953 C -805.21446,453.0323 -817.93232,439.56632 -817.86627,421.05801 C -817.81124,405.63863 -808.87914,391.11206 -790.60973,376.72979 C -788.48957,375.06073 -788.33083,374.55992 -789.48218,373.17263 C -791.39278,370.8705 -794.87888,371.1704 -800.74158,374.14126 C -804.95618,376.27695 -806.05225,376.49352 -807.0681,375.39126 C -809.41719,372.84233 -860.5773,287.40538 -860.5773,286.03134 C -860.5773,285.25743 -859.14635,284.39236 -857.3273,284.06657 C -855.5398,283.74644 -832.9775,283.61355 -807.18885,283.77126 L -760.30041,284.05801 L -732.6759,322.3314 L -705.0514,360.6048 L -695.56435,363.86815 C -683.48437,368.02341 -673.27273,374.63212 -662.84971,385.04023 C -656.5463,391.33462 -653.79411,394.9996 -651.08163,400.71132 C -646.4666,410.42926 -644.15438,422.55185 -644.91195,433.05801 C -645.83097,445.80318 -647.6491,450.3729 -654.31828,456.69996 C -665.12635,466.9536 -673.99428,471.63428 -685.0773,472.9352 C -688.99272,473.39479 -691.43881,472.99146 -696.35401,471.07578 z M -1238.3981,463.67706 C -1259.1183,458.40636 -1281.2575,441.39053 -1295.175,420.03922 C -1301.3364,410.5868 -1304.7026,402.40073 -1306.9981,391.28779 C -1309.3988,379.66506 -1309.0865,375.78346 -1305.0773,367.41771 C -1303.1523,363.40091 -1301.5773,359.48388 -1301.5773,358.71321 C -1301.5773,356.14326 -1292.7865,344.95065 -1285.2796,337.96268 C -1281.2,334.16511 -1274.25,328.92079 -1269.8351,326.30863 C -1261.1569,321.17396 -1257.6386,317.27847 -1259.2921,314.63551 C -1261.1607,311.64871 -1265.4922,312.16698 -1271.1336,316.05237 C -1277.2276,320.24945 -1278.054,320.09345 -1283.8785,313.64637 C -1293.9821,302.46287 -1297.7491,284.98976 -1293.9854,266.76585 C -1289.2953,244.05603 -1272.4752,227.6498 -1243.3731,217.39885 C -1229.4028,212.47792 -1216.3124,210.15045 -1207.601,211.03855 C -1191.4563,212.68446 -1180.6239,217.49908 -1170.4576,227.54759 C -1156.5689,241.2752 -1150.7565,261.39778 -1154.9287,281.30801 L -1156.2384,287.55801 L -1145.1578,287.56578 C -1139.0635,287.57006 -1107.6051,287.06472 -1075.2503,286.44281 C -1034.5805,285.66107 -1016.1027,285.63258 -1015.3848,286.3505 C -1014.6669,287.06843 -1024.3685,302.30762 -1046.8167,335.72348 L -1079.287,384.05801 L -1120.8081,384.31888 L -1162.3293,384.57975 L -1170.8774,375.59715 C -1179.4081,366.63288 -1179.4301,366.61825 -1181.67,368.43198 L -1183.9144,370.24943 L -1181.3561,373.65372 C -1174.6395,382.59129 -1169.6221,396.85538 -1169.5921,407.09791 C -1169.5543,419.98375 -1176.8905,434.66046 -1190.0773,448.0802 C -1196.4395,454.55476 -1199.8356,457.09198 -1206.6659,460.47327 C -1214.0978,464.15242 -1216.3199,464.77983 -1223.1659,465.13214 C -1228.7457,465.41928 -1233.2349,464.99044 -1238.3981,463.67706 z M -512.66723,443.51279 C -533.36524,440.65274 -552.02474,428.63969 -559.45818,413.38861 C -564.56022,402.92082 -565.89686,395.77762 -565.32077,382.05801 C -565.04363,375.45801 -564.30331,368.76577 -563.6756,367.18637 C -562.30047,363.72637 -563.62371,361.55801 -567.1103,361.55801 C -569.9761,361.55801 -574.24463,369.56951 -575.19469,376.73139 L -575.83496,381.55801 L -606.95613,381.5453 L -638.0773,381.5326 L -672.40248,332.2953 L -706.72766,283.05801 L -688.40248,282.77845 C -678.32363,282.62469 -647.3523,282.17469 -619.5773,281.77845 L -569.0773,281.05801 L -568.26739,275.55801 C -565.59675,257.42209 -560.94814,242.76838 -554.4101,231.876 C -549.48896,223.67737 -539.44634,213.28394 -530.96324,207.6101 C -522.30903,201.82181 -514.27751,199.07261 -499.5773,196.86668 C -486.26837,194.86951 -476.90435,195.95245 -463.65166,201.02142 C -430.88351,213.55478 -414.84302,237.00701 -418.56311,266.94379 C -420.86298,285.45163 -429.35845,305.12003 -443.01678,323.55801 C -447.70216,329.88301 -451.39728,335.50801 -451.22815,336.05801 C -450.35966,338.88233 -446.52479,337.32766 -440.18261,331.58013 L -433.47763,325.50381 L -430.41891,327.28091 C -423.62863,331.22602 -415.84376,342.02943 -411.89543,352.98676 C -409.83198,358.7132 -410.02201,381.32449 -412.19511,388.64459 C -417.1716,405.40797 -430.27754,421.468 -446.71155,430.94106 C -452.67682,434.37963 -469.81806,440.14871 -479.51524,441.98152 C -489.80579,443.92649 -504.69597,444.61425 -512.66723,443.51279 z M -908.41311,270.64998 C -911.3478,269.63648 -915.02969,267.86033 -916.59508,266.70298 C -919.32451,264.68503 -919.61835,264.66449 -923.75927,266.20228 C -929.65326,268.39108 -948.63485,269.1447 -958.38423,267.57697 C -969.30666,265.82062 -982.69867,261.76682 -984.20094,259.76218 C -985.39972,258.16252 -985.6804,258.17271 -988.77767,259.92824 C -1003.1262,268.06095 -1006.1972,268.74898 -1015.6458,265.9477 C -1023.2813,263.68395 -1028.0817,261.05602 -1033.2008,256.33737 L -1037.6256,252.25881 L -1042.8514,255.77381 C -1045.7257,257.70706 -1048.6404,259.60132 -1049.3287,259.98327 C -1051.2186,261.03213 -1065.1757,255.9312 -1073.0015,251.33151 C -1076.8098,249.09313 -1082.2835,244.96589 -1085.1654,242.15987 C -1090.959,236.51866 -1092.6856,232.19505 -1094.5904,218.55801 C -1096.3003,206.31671 -1097.2597,203.7723 -1100.864,201.92048 C -1112.3748,196.00655 -1138.9285,177.04142 -1158.5773,160.70064 C -1172.8865,148.80052 -1211.9284,109.93516 -1225.0204,94.55801 C -1266.3435,46.02222 -1290.159,-1.28254 -1317.9069,-89.94199 C -1324.647,-111.47784 -1325.886,-116.7655 -1329.975,-141.44199 C -1336.4301,-180.39842 -1337.4513,-189.06828 -1338.5735,-214.44199 C -1339.1208,-226.81699 -1340.0377,-244.98739 -1340.611,-254.82066 C -1341.1842,-264.65393 -1341.5237,-272.82138 -1341.3653,-272.97056 C -1341.2069,-273.11973 -1315.1653,-273.57186 -1283.4951,-273.97529 L -1225.9129,-274.70881 L -1226.6909,-268.3254 C -1230.8495,-234.20364 -1226.8827,-190.10171 -1215.9978,-149.44199 C -1209.2048,-124.0675 -1194.5433,-81.7993 -1191.8003,-79.68207 C -1189.5234,-77.92469 -1189.1218,-79.01959 -1187.6701,-90.94199 C -1185.7045,-107.08532 -1180.9274,-129.317 -1176.578,-142.5624 C -1173.2208,-152.78619 -1164.927,-171.07052 -1152.2373,-196.22343 C -1148.1155,-204.39338 -1131.3638,-225.60427 -1118.7551,-238.61825 C -1068.2826,-290.713 -1001.8689,-318.3497 -926.0773,-318.7971 C -904.02758,-318.92726 -893.42369,-317.65705 -872.17853,-312.34076 C -838.36477,-303.87935 -802.10091,-284.86935 -768.76118,-258.128 C -752.57584,-245.14596 -725.56707,-218.81502 -715.37698,-206.08356 C -688.67676,-172.72441 -666.15916,-128.1279 -657.11365,-90.69199 C -654.26018,-78.88257 -650.58298,-82.00441 -648.14559,-98.30563 C -647.31992,-103.82767 -645.93774,-110.03691 -645.07408,-112.10394 C -644.21042,-114.17096 -642.37515,-121.43634 -640.9957,-128.24922 C -630.60858,-179.54943 -630.11517,-229.62661 -639.6307,-266.78465 C -640.73531,-271.09811 -641.73767,-275.11807 -641.85819,-275.7179 C -642.53483,-279.08573 -638.37212,-279.23962 -526.8273,-279.9706 L -416.5773,-280.69308 L -416.58624,-267.81754 C -416.62207,-216.21562 -424.84942,-160.70011 -440.1652,-108.71423 C -460.73046,-38.9102 -493.13054,25.14701 -538.3843,85.47174 C -564.49254,120.27487 -596.83753,153.73798 -625.0773,175.16161 C -648.07878,192.61129 -665.88215,202.83406 -702.0773,219.37535 C -716.3773,225.91049 -731.25791,232.86447 -735.14532,234.82864 C -742.65343,238.62223 -743.00932,239.14808 -745.11381,249.55801 C -746.033,254.1048 -748.82577,259.57082 -751.43564,261.9311 C -756.15163,266.19608 -775.41312,267.98381 -785.23215,265.06787 C -787.99197,264.24829 -792.06854,262.26038 -794.2912,260.6503 L -798.33239,257.72288 L -802.20485,261.72286 C -808.6703,268.40125 -810.39437,268.93817 -825.5773,269.00161 C -838.31944,269.05484 -839.38606,268.90507 -844.5773,266.33361 C -847.6023,264.8352 -850.84993,263.04688 -851.79425,262.35958 C -853.23716,261.30939 -853.86087,261.48527 -855.70205,263.46154 C -859.61272,267.65915 -867.54467,270.50974 -878.1963,271.54554 C -893.27306,273.01167 -902.35396,272.74253 -908.41311,270.64998 z M -874.0773,256.45658 C -868.87021,255.03729 -866.22639,252.49435 -863.59258,246.37189 C -859.35896,236.53058 -859.86866,223.23561 -865.11645,206.62341 C -868.34653,196.39841 -871.00783,192.66548 -877.60545,189.1054 C -882.05897,186.70228 -884.16405,186.18214 -888.91684,186.31047 C -896.98122,186.52823 -904.6155,188.94045 -907.78196,192.27134 L -910.43106,195.05801 L -911.14826,224.23067 L -911.86546,253.40333 L -907.97138,254.41151 C -895.46773,257.64871 -881.53518,258.48936 -874.0773,256.45658 z M -934.61462,253.22753 C -930.51175,252.15231 -930.04275,251.69518 -928.79776,247.55801 C -926.66797,240.48064 -926.16013,223.67414 -927.55548,206.44611 C -929.00743,188.51917 -929.19087,188.14038 -937.15355,186.62627 C -941.94526,185.71512 -942.35787,185.83797 -952.53977,191.20721 C -966.16063,198.38992 -968.30533,199.99154 -970.19439,204.39134 C -972.23505,209.14422 -976.51006,231.66213 -976.54795,237.85767 C -976.58086,243.23864 -974.49178,248.15275 -971.83827,248.93619 C -970.38964,249.36389 -958.75902,252.01314 -950.0773,253.89296 C -946.31101,254.70845 -939.07776,254.39718 -934.61462,253.22753 z M -816.91665,252.62494 C -813.04296,250.8661 -812.67478,250.34457 -811.57838,245.06323 C -810.30141,238.91207 -810.15274,212.23577 -811.3638,206.55801 C -811.96068,203.75963 -812.9677,202.62361 -816.38723,200.89104 C -823.05306,197.51366 -833.3712,196.10153 -839.25586,197.76126 C -843.48781,198.95486 -844.2272,199.57644 -845.30336,202.84528 C -846.03956,205.08149 -846.63887,213.85874 -846.80336,224.81372 C -847.0553,241.59298 -846.91486,243.33906 -845.05442,246.55801 C -840.74811,254.00883 -826.65631,257.04723 -816.91665,252.62494 z M -997.23042,248.8774 C -993.01082,244.53311 -990.67972,236.18289 -989.83866,222.39949 C -989.37824,214.85403 -989.59361,213.15576 -991.51405,209.18867 C -995.47161,201.01345 -1008.2866,196.78806 -1018.9392,200.14599 C -1026.8903,202.65238 -1028.5756,204.84198 -1030.1885,214.7621 C -1032.8728,231.2722 -1031.4501,241.86846 -1025.885,246.81231 C -1022.6711,249.66753 -1013.5241,252.40656 -1006.9413,252.48494 C -1001.1449,252.55397 -1000.6076,252.35438 -997.23042,248.8774 z M -763.1903,250.60097 C -753.68556,246.98728 -752.58068,210.63448 -761.68116,200.94745 C -762.91578,199.63326 -764.56669,198.55801 -765.34985,198.55801 C -766.13301,198.55801 -771.63287,200.17215 -777.57178,202.14499 C -791.96447,206.92608 -793.46849,208.49129 -794.49531,219.75699 C -795.27524,228.31404 -794.4945,239.02625 -792.76018,243.56374 C -791.39296,247.14081 -788.5584,249.37 -784.02718,250.43166 C -778.69354,251.68132 -766.29678,251.78205 -763.1903,250.60097 z M -1050.7271,244.67177 C -1048.4108,243.20393 -1044.5693,226.143 -1044.6534,217.69745 C -1044.7578,207.2118 -1046.2624,203.38461 -1050.8873,201.84098 C -1055.6496,200.25147 -1074.248,199.19785 -1078.0121,200.30434 C -1080.2811,200.9713 -1081.2692,202.1338 -1082.3672,205.42764 C -1083.6138,209.16757 -1083.5875,210.87153 -1082.1514,219.37121 C -1080.2844,230.42221 -1077.6733,236.60037 -1073.7782,239.18348 C -1070.1774,241.57142 -1058.8264,245.38306 -1055.0773,245.46323 C -1053.4273,245.49852 -1051.4697,245.14236 -1050.7271,244.67177 z M -916.73297,141.43566 C -914.8632,138.44169 -914.19911,129.99883 -915.34395,123.77658 C -916.19319,119.16097 -916.0709,118.18394 -914.37392,116.02658 C -912.44163,113.57007 -908.37726,112.76196 -905.89473,114.34067 C -905.24431,114.75428 -903.72656,119.02239 -902.52194,123.82535 C -901.31732,128.62831 -899.91653,132.55801 -899.40906,132.55801 C -896.95296,132.55801 -893.87435,127.71397 -893.31183,122.9643 C -892.98529,120.20724 -890.249,110.32544 -887.23118,101.00474 C -878.47792,73.96982 -878.17108,72.52508 -878.21628,58.55801 C -878.23922,51.46917 -879.15429,39.78106 -880.33013,31.55801 C -881.4705,23.58301 -882.69997,13.00801 -883.0623,8.05801 C -883.42462,3.10801 -885.96894,-13.09199 -888.71634,-27.94199 C -891.46374,-42.79199 -894.31964,-60.79199 -895.06279,-67.94199 C -896.60085,-82.74019 -897.67558,-86.44199 -900.43383,-86.44199 C -904.26395,-86.44199 -906.1983,-71.8171 -907.58259,-32.39296 C -908.13204,-16.74493 -909.02158,-1.01699 -909.55934,2.55801 C -910.0971,6.13301 -910.54613,9.61086 -910.55719,10.28657 C -910.57267,11.23202 -911.15013,11.25414 -913.06308,10.38253 C -918.55323,7.88106 -921.55862,-6.37483 -921.56975,-29.96822 C -921.57777,-46.98552 -922.86294,-60.70535 -924.92157,-65.75048 L -926.17329,-68.81811 L -928.24048,-65.88005 C -930.00059,-63.37844 -930.38694,-60.93654 -930.84126,-49.44199 C -931.26704,-38.66937 -932.68933,-28.871 -937.88131,-0.94199 C -946.38265,44.78886 -947.47388,55.52525 -945.15546,70.62687 C -942.90678,85.27425 -938.30248,103.48616 -933.99306,114.77877 C -929.60863,126.26793 -920.73629,143.55801 -919.22511,143.55801 C -918.58342,143.55801 -917.46195,142.60295 -916.73297,141.43566 z M -1146.5773,128.38421 C -1146.5773,125.52597 -1147.839,121.66484 -1150.5803,116.13421 C -1152.8703,111.51402 -1155.412,104.23816 -1156.5199,99.13156 C -1157.6992,93.69563 -1159.0667,89.86364 -1160.0169,89.33187 C -1161.1435,88.70138 -1161.5773,86.88843 -1161.5773,82.81022 C -1161.5773,79.70359 -1162.0752,73.53845 -1162.6838,69.10991 C -1163.5735,62.63551 -1163.4584,57.53152 -1162.0962,43.05801 C -1161.1645,33.15801 -1160.4869,19.43301 -1160.5905,12.55801 C -1160.7595,1.33297 -1161.1752,-1.31895 -1164.6666,-13.44199 C -1166.805,-20.86699 -1168.5597,-27.69421 -1168.566,-28.6136 C -1168.577,-30.23751 -1176.7577,-46.6815 -1178.8036,-49.19199 C -1180.0017,-50.66225 -1185.1948,-50.86982 -1186.0527,-49.48173 C -1186.3791,-48.95359 -1185.2185,-45.69311 -1183.4734,-42.23622 C -1173.204,-21.89271 -1171.3412,-7.78916 -1171.7706,46.36741 L -1172.0773,85.05801 L -1169.3167,94.05801 C -1164.4865,109.80553 -1151.9288,132.55801 -1148.0676,132.55801 C -1146.9852,132.55801 -1146.5773,131.41549 -1146.5773,128.38421 z M -689.70249,130.12275 C -681.87369,126.07432 -672.19251,109.84663 -670.08706,97.24316 C -669.33501,92.74133 -668.76925,87.70801 -668.82982,86.05801 C -668.89039,84.40801 -668.38603,77.65801 -667.70901,71.05801 C -666.40994,58.39377 -666.49592,56.32854 -669.70739,23.05801 C -671.15868,8.02278 -672.13817,1.74266 -673.15587,0.94777 C -674.26557,0.08101 -674.5773,-3.27623 -674.5773,-14.36068 C -674.5773,-32.49179 -673.25445,-40.86603 -668.9821,-49.78093 C -665.4181,-57.21776 -664.76155,-61.22624 -666.7773,-63.24199 C -668.65516,-65.11985 -669.36966,-64.73116 -672.15722,-60.31538 C -678.67362,-49.99275 -682.49027,-34.40782 -682.53421,-17.94199 C -682.56677,-5.73723 -681.47449,4.33795 -677.43878,29.05801 C -674.49773,47.07287 -674.36399,49.095 -674.85939,68.05801 C -675.26926,83.74731 -675.82072,89.71097 -677.41798,95.72709 C -680.96687,109.09412 -686.37984,117.45983 -695.47147,123.62863 C -698.25131,125.51479 -700.53733,127.53051 -700.55151,128.10801 C -700.63512,131.5124 -694.56844,132.63903 -689.70249,130.12275 z M -983.72491,44.49625 C -973.38642,42.27904 -965.13929,34.44289 -962.08429,23.93405 C -955.4029,0.9509 -947.60873,-51.40878 -947.58606,-73.46209 C -947.56882,-90.23105 -953.62509,-104.6065 -970.18032,-127.09292 C -976.48119,-135.65119 -977.62447,-136.0065 -994.0773,-134.51984 C -1006.7053,-133.37879 -1022.8345,-129.15744 -1036.0773,-123.5276 C -1041.0273,-121.42323 -1053.8523,-116.6687 -1064.5773,-112.96197 C -1101.3256,-100.26118 -1110.793,-95.68158 -1116.027,-88.07441 C -1122.6133,-78.5018 -1123.9925,-72.91839 -1123.9641,-55.94199 C -1123.9503,-47.69199 -1123.5089,-35.08405 -1122.9833,-27.92434 C -1121.8612,-12.64024 -1121.1246,-11.0296 -1110.8055,-1.29796 C -1099.6336,9.23801 -1084.441,15.85665 -1060.6178,20.56629 C -1049.9256,22.68005 -1048.1576,23.38967 -1034.2105,31.16514 C -1011.1339,44.03034 -997.87615,47.53114 -983.72491,44.49625 z M -816.41527,34.15396 C -806.43201,32.24375 -797.7858,28.62341 -783.30707,20.29089 C -766.82846,10.80743 -754.68372,5.18057 -745.12237,2.59929 C -728.73979,-1.82353 -712.3568,-13.23665 -707.24549,-23.78741 C -702.12028,-34.3669 -699.37176,-47.37068 -699.28671,-61.44199 C -699.19707,-76.27254 -700.67125,-82.70862 -707.05236,-95.34589 C -712.62745,-106.38689 -716.36077,-110.61936 -729.61969,-120.93051 C -744.75619,-132.70181 -751.51024,-135.90907 -764.0773,-137.29318 C -782.28514,-139.29856 -797.72681,-139.69515 -809.96045,-138.4716 C -820.04478,-137.46301 -823.20875,-136.691 -830.86192,-133.37164 C -842.10158,-128.49674 -853.4526,-121.48698 -857.41522,-116.97381 C -859.07621,-115.08204 -862.33003,-110.25098 -864.64593,-106.23811 C -866.96183,-102.22524 -869.45347,-98.24849 -870.18292,-97.40088 C -874.89193,-91.92906 -876.47341,-63.99029 -872.81274,-50.94199 C -870.64953,-43.23134 -846.02479,20.80037 -842.76664,27.18687 C -841.6429,29.38958 -840.04436,31.75542 -839.21432,32.44429 C -835.32824,35.66945 -827.43077,36.26167 -816.41527,34.15396 z"
   id="path2476" />
		<path
   style="fill:#e3cc0b;fill-opacity:1"
   d="M -1049.1574,471.22882 C -1056.2574,467.84471 -1066.6128,457.8727 -1069.773,451.37653 C -1075.2264,440.16619 -1075.8159,427.03583 -1071.4956,413.00989 C -1068.5356,403.40026 -1065.4487,398.53371 -1057.9621,391.67353 C -1045.1097,379.8967 -1029.7706,374.28481 -1011.5773,374.70344 C -1001.8293,374.92774 -1001.0567,374.80515 -1000.7892,372.99189 C -1000.5535,371.39346 -1001.8788,370.52644 -1008.0865,368.21791 L -1015.6718,365.39708 L -1013.8745,362.60161 C -1012.8861,361.0641 -1000.8273,343.11068 -987.0773,322.70512 L -962.0773,285.60411 L -917.3273,285.58106 C -892.7148,285.56838 -872.5773,285.79801 -872.5773,286.09135 C -872.5773,286.38468 -875.66001,291.22218 -879.42777,296.84135 C -883.19553,302.46051 -895.03621,320.78301 -905.7404,337.55801 C -916.44459,354.33301 -927.74082,371.84755 -930.84313,376.47922 C -933.94545,381.11088 -936.27152,385.24375 -936.01218,385.66337 C -935.75284,386.08299 -933.99833,386.17604 -932.11326,385.87013 C -927.17121,385.06815 -924.05089,386.13536 -919.61169,390.1459 C -914.10325,395.12245 -912.05875,401.53491 -912.14715,413.55801 C -912.24611,427.01743 -914.65216,432.82751 -923.98242,442.13746 C -936.78771,454.9149 -950.55048,461.40503 -966.71305,462.288 C -975.45713,462.76569 -976.72618,462.60231 -980.42683,460.52242 C -985.95549,457.41514 -987.63976,453.52148 -987.40528,444.38977 C -987.30174,440.3573 -987.55308,436.04656 -987.96381,434.81033 C -988.86453,432.09937 -992.6017,430.96552 -995.50863,432.52126 C -997.33699,433.49977 -997.59513,434.44228 -997.39849,439.42156 C -996.96785,450.32598 -1004.8115,459.20875 -1022.5085,467.85829 C -1035.4599,474.18834 -1041.3778,474.93683 -1049.1574,471.22882 z M -694.26426,471.59029 C -702.29602,468.74294 -708.95402,464.76879 -713.56698,460.06853 C -718.46388,455.07895 -718.41171,454.37788 -712.55978,446.53453 C -708.85768,441.57259 -707.34833,436.12031 -709.17198,434.29666 C -709.49906,433.96958 -713.66156,437.05987 -718.42198,441.16396 C -738.85788,458.7823 -764.41476,465.68504 -784.40098,458.98444 C -799.95873,453.76854 -808.77005,446.99367 -814.14773,436.11268 C -817.34213,429.64926 -817.77057,427.89575 -817.74505,421.38967 C -817.68704,406.59997 -809.42796,392.3558 -793.10609,378.89564 C -788.76258,375.31368 -788.30454,374.5916 -789.47853,373.17702 C -791.40469,370.85614 -795.89409,371.17811 -801.5467,374.04251 L -806.44962,376.527 L -824.12464,347.29251 C -833.8459,331.21353 -846.07449,311.00821 -851.29927,302.39179 C -856.52406,293.77536 -860.49747,286.23786 -860.12908,285.64179 C -859.66242,284.88672 -844.38813,284.56116 -809.76828,284.56839 L -760.0773,284.57878 L -732.57712,322.73864 L -705.07694,360.89851 L -697.92628,363.08198 C -683.93587,367.354 -668.40475,377.84486 -658.56317,389.67071 C -652.51793,396.9348 -650.49855,400.7421 -647.47819,410.57011 C -644.76671,419.39309 -644.2915,434.44326 -646.42083,444.05801 C -647.62175,449.48062 -648.41302,450.70238 -654.64336,456.75408 C -668.4175,470.13325 -682.9861,475.58853 -694.26426,471.59029 z M -1236.2133,464.06456 C -1251.4934,460.74149 -1266.2882,451.98079 -1280.0773,438.09062 C -1294.9434,423.11554 -1303.2357,408.77259 -1306.6907,392.05801 C -1309.7394,377.30912 -1309.4217,375.70966 -1299.2428,354.55801 C -1295.9013,347.61418 -1280.5699,332.82876 -1270.3441,326.68825 C -1265.5408,323.80395 -1260.9283,320.46957 -1260.0941,319.27853 C -1257.163,315.09378 -1258.6075,312.55801 -1263.9224,312.55801 C -1265.1223,312.55801 -1268.474,314.15405 -1271.3706,316.10476 L -1276.6372,319.65151 L -1279.5336,317.58916 C -1287.6398,311.81699 -1294.1905,297.84495 -1295.1547,284.27069 C -1296.2288,269.14953 -1292.0651,255.03929 -1283.3071,244.12005 C -1271.4461,229.33229 -1254.9002,219.82453 -1230.0713,213.52934 C -1194.4581,204.49987 -1162.0473,222.88093 -1155.0817,256.05801 C -1153.0212,265.87212 -1153.4318,277.22284 -1156.1581,285.81258 L -1156.8122,287.87363 L -1111.4448,287.20602 C -1086.4927,286.83884 -1054.6487,286.24649 -1040.6804,285.88968 L -1015.2835,285.24095 L -1015.7659,287.64948 C -1016.0312,288.97417 -1030.5581,311.32051 -1048.0478,337.30801 L -1079.8473,384.55801 L -1121.1238,384.55801 L -1162.4003,384.55801 L -1170.947,375.30801 L -1179.4938,366.05801 L -1181.6095,368.15978 L -1183.7253,370.26156 L -1179.6842,376.51396 C -1168.9179,393.1715 -1166.9011,411.37867 -1174.2195,425.84876 C -1183.6026,444.40114 -1198.9318,458.80732 -1214.3605,463.57277 C -1221.7054,465.84137 -1227.4489,465.97063 -1236.2133,464.06456 z M -510.5773,443.53627 C -526.18903,442.02806 -539.25397,435.94197 -550.15683,425.09879 C -561.92146,413.39856 -566.1868,401.23411 -565.24864,382.05801 C -564.95266,376.00801 -564.14488,369.33749 -563.45359,367.23464 C -562.04903,362.96207 -562.9926,361.60248 -567.38262,361.57332 C -569.20696,361.5612 -570.20626,362.69015 -572.17219,366.9843 C -573.53852,369.96876 -574.98843,374.35626 -575.39422,376.7343 L -576.13202,381.05801 L -607.10466,381.26553 L -638.0773,381.47305 L -672.29302,332.26553 L -706.50873,283.05801 L -637.79302,282.22142 C -599.99937,281.7613 -568.95666,281.26566 -568.80922,281.12001 C -568.66177,280.97435 -568.05169,276.85082 -567.45348,271.9566 C -564.4141,247.09015 -553.46053,225.58188 -537.04331,212.24361 C -524.25654,201.85492 -508.00806,196.46537 -489.0773,196.33348 C -479.6433,196.26775 -476.86721,196.65092 -469.5773,199.02492 C -447.64096,206.16863 -432.4358,217.67318 -424.36078,233.23673 C -419.78881,242.04863 -418.19146,249.01965 -418.31469,259.62259 C -418.53359,278.4567 -426.66422,300.66463 -440.0748,319.05801 C -451.17994,334.28934 -451.9392,335.62468 -450.38065,337.18323 C -448.76175,338.80213 -446.76836,337.64116 -437.70242,329.7993 L -432.77893,325.54059 L -427.91026,329.38906 C -421.73756,334.2683 -416.10338,342.42479 -413.0001,350.97425 C -410.9317,356.67264 -410.5773,359.44005 -410.5773,369.8934 C -410.5773,391.33568 -415.10166,402.14684 -430.5425,417.60111 C -437.92878,424.99382 -441.87998,428.06907 -448.0773,431.2486 C -466.16204,440.52694 -491.05946,445.42185 -510.5773,443.53627 z M -907.72766,270.63299 C -910.83535,269.6447 -914.75216,267.85762 -916.43168,266.6617 C -919.45475,264.50909 -919.53839,264.50519 -924.78132,266.27266 C -928.93666,267.67348 -933.20028,268.04699 -944.5773,268.00686 C -957.0308,267.96293 -960.55925,267.57055 -969.5773,265.22673 C -975.3523,263.7258 -981.37197,261.55557 -982.95435,260.40402 L -985.83139,258.31028 L -994.75681,262.93414 C -999.6658,265.47727 -1004.8961,267.55267 -1006.3798,267.54614 C -1014.2163,267.51166 -1028.2645,261.53946 -1033.6995,255.9319 C -1035.4981,254.07626 -1037.4538,252.55801 -1038.0456,252.55801 C -1038.6374,252.55801 -1040.7589,253.90764 -1042.7601,255.5572 C -1048.5127,260.29893 -1050.1935,260.56941 -1057.8096,257.97901 C -1072.7872,252.8848 -1087.3267,242.64125 -1090.6785,234.82188 C -1091.7416,232.34189 -1093.508,224.63048 -1094.604,217.68541 C -1096.0514,208.51365 -1097.073,204.70328 -1098.337,203.76177 C -1099.2942,203.04884 -1106.3407,198.40188 -1113.996,193.43519 C -1156.2278,166.0355 -1199.9984,125.65151 -1236.2464,80.64342 C -1265.2124,44.67711 -1287.7389,0.15801 -1309.4058,-63.94199 C -1321.9664,-101.10175 -1324.6575,-111.29602 -1329.6002,-140.44199 C -1336.5383,-181.35448 -1337.4889,-190.06952 -1339.0906,-227.44199 C -1339.8802,-245.86699 -1340.8079,-263.68667 -1341.1521,-267.04128 L -1341.778,-273.14056 L -1284.5917,-273.87196 C -1253.1392,-274.27423 -1227.1752,-274.37318 -1226.8938,-274.09186 C -1226.6125,-273.81053 -1226.9422,-266.91173 -1227.6265,-258.76117 C -1231.5827,-211.63835 -1221.9095,-157.71083 -1197.8863,-92.9628 C -1193.277,-80.53964 -1191.9892,-78.13801 -1190.2482,-78.71835 C -1189.6823,-78.90698 -1188.1965,-86.23446 -1186.9465,-95.00165 C -1182.1344,-128.74992 -1176.6873,-146.15183 -1160.9848,-177.94199 C -1146.9207,-206.41533 -1137.468,-219.65692 -1115.6272,-241.48026 C -1079.089,-277.98925 -1035.8307,-301.43637 -984.0773,-312.78366 C -962.00946,-317.62219 -930.62439,-320.00005 -909.71685,-318.41752 C -857.3518,-314.45392 -806.1085,-290.92645 -757.5773,-248.5653 C -743.28181,-236.08728 -724.75687,-217.44456 -716.7138,-207.44199 C -690.42833,-174.7527 -669.48397,-134.78488 -659.45521,-98.17622 C -657.76256,-91.99739 -655.94719,-85.8526 -655.42107,-84.52113 L -654.46448,-82.10027 L -652.03151,-84.53324 C -650.08647,-86.47828 -649.38196,-88.66846 -648.51867,-95.4541 C -647.92474,-100.12244 -646.36494,-107.31699 -645.05244,-111.44199 C -642.02342,-120.96181 -638.1396,-141.15407 -635.36101,-161.82844 C -633.60342,-174.90599 -633.18872,-183.02915 -633.15997,-204.94199 C -633.12175,-234.07976 -634.20835,-245.15268 -639.07864,-265.25569 C -640.4529,-270.92823 -641.5773,-275.94671 -641.5773,-276.40787 C -641.5773,-279.06599 -631.86703,-279.32364 -528.40916,-279.41067 C -469.43912,-279.46028 -420.15285,-279.7614 -418.88411,-280.07984 C -416.58028,-280.65806 -416.57732,-280.64479 -416.59649,-269.8004 C -416.63631,-247.26857 -418.90249,-215.49309 -422.14923,-191.94199 C -432.1402,-119.46987 -459.986,-39.15796 -496.31408,21.96174 C -540.45076,96.21892 -590.72627,152.90878 -643.5773,188.01337 C -659.12231,198.33864 -672.11364,205.39322 -694.5773,215.70748 C -743.89766,238.35309 -742.20943,237.41702 -743.61718,242.89841 C -749.01257,263.9066 -751.70282,266.05801 -772.5773,266.05801 C -784.26327,266.05801 -788.55219,264.94881 -794.18979,260.46862 L -797.93881,257.48927 L -802.50806,261.90805 C -808.66078,267.85816 -809.6208,268.23764 -820.5773,269.0504 C -833.74188,270.02697 -842.60768,268.22216 -850.79885,262.89821 C -853.46961,261.16231 -853.57223,261.17782 -856.29885,263.7295 C -862.43701,269.47384 -869.26928,271.20909 -888.5773,271.92755 C -899.78657,272.34464 -903.03607,272.12498 -907.72766,270.63299 z M -873.20459,256.47155 C -867.92137,255.00459 -864.93008,251.44001 -862.56992,243.79869 C -860.04479,235.62326 -860.03154,226.36767 -862.53021,216.05801 C -867.22221,196.69855 -870.70042,191.15224 -880.43269,187.51093 C -885.38161,185.6593 -886.59949,185.57608 -893.48171,186.61931 C -901.64364,187.85652 -907.93977,190.49826 -909.44942,193.31907 C -909.96587,194.28406 -910.67053,205.87009 -911.01534,219.0658 C -911.36016,232.26152 -911.87985,245.379 -912.17022,248.21577 L -912.69816,253.37353 L -904.38773,255.38927 C -895.07722,257.64758 -879.39969,258.1917 -873.20459,256.47155 z M -815.66672,252.60587 C -812.51163,250.91731 -811.67129,248.50043 -810.50193,237.75143 C -809.09052,224.77761 -810.54837,205.35245 -813.14912,202.47865 C -816.65845,198.60089 -832.31157,195.60155 -839.2663,197.47427 C -841.50921,198.07822 -843.92417,199.27104 -844.63288,200.12497 C -846.5937,202.48762 -848.15932,235.37942 -846.63514,242.19016 C -845.10047,249.04778 -840.69328,253.14884 -833.8695,254.06906 C -831.23379,254.4245 -828.64763,254.82315 -828.12247,254.95494 C -826.45013,255.37463 -817.78761,253.74093 -815.66672,252.60587 z M -931.83151,252.69406 C -927.26092,250.24796 -925.51046,230.71061 -927.57605,205.1979 L -928.86014,189.33778 L -931.96872,188.03956 C -940.31769,184.55281 -941.53323,184.78871 -955.54196,192.6143 C -968.45274,199.82655 -968.57096,199.92514 -970.50411,205.09193 C -971.5758,207.9563 -973.42254,215.42045 -974.60796,221.67894 C -977.09828,234.82676 -976.96084,244.60078 -974.24739,247.32048 C -971.33307,250.24152 -950.4022,254.5999 -941.45454,254.14884 C -937.26203,253.93749 -932.93166,253.28284 -931.83151,252.69406 z M -998.64592,250.65973 C -995.23523,248.25383 -992.96163,243.31211 -991.14216,234.35017 C -989.06819,224.13464 -989.10688,213.35161 -991.23359,208.8699 C -994.72043,201.52193 -1007.0501,197.04195 -1016.9389,199.52988 C -1024.2637,201.37274 -1027.1401,203.06432 -1028.3845,206.26085 C -1030.3608,211.33756 -1031.8464,224.34814 -1031.3766,232.46446 C -1030.7353,243.54145 -1028.242,247.27167 -1019.4685,250.27973 C -1009.0347,253.85704 -1003.3262,253.96121 -998.64592,250.65973 z M -762.79537,250.48419 C -759.1261,249.20507 -757.29331,244.70644 -755.53092,232.65341 C -753.76361,220.56669 -756.45936,207.03981 -762.01367,200.12395 C -763.53177,198.23371 -763.73134,198.23013 -770.82213,199.96622 C -774.81247,200.9432 -781.0023,202.93852 -784.5773,204.40028 C -793.48394,208.04204 -794.73008,210.65065 -794.80789,225.81659 C -794.91856,247.38855 -791.73941,251.2097 -773.47652,251.45565 C -769.2961,251.51195 -764.48958,251.07479 -762.79537,250.48419 z M -1052.2041,245.60622 C -1048.7301,244.28542 -1045.5929,233.97272 -1044.8884,221.55801 C -1044.1613,208.74619 -1045.4817,203.91373 -1050.2543,201.91962 C -1054.6131,200.0984 -1072.7799,198.98589 -1077.5773,200.24641 C -1080.5431,201.02567 -1081.2898,201.82971 -1082.47,205.51471 C -1083.6813,209.29694 -1083.6525,211.14388 -1082.2491,219.69353 C -1080.4494,230.65734 -1077.9818,236.43084 -1073.8499,239.34529 C -1072.325,240.42093 -1067.4773,242.45395 -1063.0773,243.86311 C -1058.6773,245.27228 -1054.9941,246.4551 -1054.8924,246.49162 C -1054.7907,246.52813 -1053.581,246.12971 -1052.2041,245.60622 z M -915.49725,138.81544 C -914.71094,136.43293 -914.54143,132.23189 -914.99119,126.27401 C -915.74915,116.23352 -914.62286,113.54411 -909.67231,113.57332 C -905.55854,113.5976 -904.87444,114.56087 -902.57598,123.56562 C -901.38376,128.23643 -900.27948,132.18736 -900.12203,132.34545 C -899.23157,133.23954 -894.468,129.88861 -894.13883,128.13657 C -892.2122,117.88198 -890.56318,111.71169 -885.45065,95.62713 C -882.20441,85.41411 -879.04824,73.90801 -878.43693,70.05801 C -877.11397,61.72606 -877.76631,49.26469 -880.53088,30.05801 C -881.63921,22.35801 -882.55306,13.40713 -882.56166,10.16717 C -882.57026,6.92722 -885.08926,-9.27278 -888.15944,-25.83283 C -891.22961,-42.39287 -894.34407,-61.92924 -895.08046,-69.24698 C -895.94091,-77.79766 -896.9918,-83.42565 -898.02137,-84.99698 C -901.04291,-89.60843 -902.69473,-87.64984 -904.39302,-77.44199 C -906.42423,-65.23312 -906.65631,-62.0742 -907.5831,-34.02163 C -908.40995,-8.99365 -909.89149,9.19363 -911.21168,10.52264 C -912.1866,11.50407 -915.15185,8.72222 -916.81048,5.27013 C -920.01079,-1.39065 -920.69805,-6.82104 -921.58325,-32.44199 C -922.37261,-55.28892 -923.7419,-66.93993 -925.89011,-69.08813 C -926.1317,-69.32972 -927.21125,-68.0327 -928.28911,-66.20586 C -929.85991,-63.54355 -930.37433,-60.2107 -930.88101,-49.41316 C -931.3653,-39.09267 -933.01458,-27.87301 -937.93271,-1.44199 C -947.6922,51.00754 -948.12568,58.18412 -943.04986,83.27731 C -938.9416,103.58726 -929.89755,128.07216 -921.58187,141.39749 C -919.1264,145.33221 -917.4072,144.60266 -915.49725,138.81544 z M -1146.1796,126.60659 C -1146.765,123.24151 -1147.2958,121.98927 -1151.7343,113.50255 C -1152.757,111.54705 -1154.7261,105.48357 -1156.11,100.02816 C -1157.4938,94.57274 -1159.0651,89.6702 -1159.6017,89.13361 C -1160.1383,88.59703 -1160.5773,84.89957 -1160.5773,80.91703 C -1160.5773,76.93449 -1160.9754,73.43002 -1161.4619,73.12932 C -1163.3021,71.992 -1163.6998,62.74595 -1162.5994,46.68079 C -1161.9732,37.53826 -1161.0204,28.25801 -1160.4821,26.05801 C -1158.664,18.62787 -1160.9522,-2.35492 -1165.0076,-15.44199 C -1166.9676,-21.76699 -1168.5726,-27.96343 -1168.5742,-29.21186 C -1168.5759,-30.46029 -1169.7718,-33.37393 -1171.2317,-35.68662 C -1172.6917,-37.9993 -1174.936,-42.26536 -1176.2191,-45.16675 C -1178.3854,-50.06508 -1178.7988,-50.44199 -1182.0057,-50.44199 C -1183.9052,-50.44199 -1185.7057,-50.04329 -1186.0068,-49.556 C -1186.308,-49.0687 -1184.7286,-44.77382 -1182.497,-40.01181 C -1173.2697,-20.32124 -1171.4072,-4.99054 -1171.7976,48.05801 L -1172.0773,86.05801 L -1169.2633,95.05801 C -1165.5757,106.85241 -1158.7624,120.60087 -1152.9521,127.97211 C -1148.6042,133.48818 -1148.1986,133.76066 -1146.9263,132.02069 C -1146.0425,130.81199 -1145.7796,128.90577 -1146.1796,126.60659 z M -687.46138,128.97768 C -683.53872,126.25927 -681.10136,123.03766 -675.22958,112.81012 C -671.6301,106.5405 -668.31236,93.43287 -668.69092,86.97733 C -668.78507,85.3717 -668.30118,78.65801 -667.61559,72.05801 C -666.27087,59.11263 -666.48021,54.14493 -669.72263,22.05801 C -671.22681,7.1726 -672.24252,0.82516 -673.211,0.25832 C -674.26228,-0.35699 -674.57273,-3.70012 -674.55749,-14.24168 C -674.53112,-32.48119 -673.29979,-40.32792 -669.0567,-49.29578 C -665.43249,-56.95564 -664.73829,-61.20298 -666.7773,-63.24199 C -669.10189,-65.56658 -670.40543,-64.3628 -674.41148,-56.19199 C -680.05804,-44.67519 -681.61194,-37.99662 -682.26975,-22.41745 C -682.90157,-7.45418 -681.99569,2.46512 -677.49821,29.8307 C -673.20718,55.9401 -673.62686,83.12311 -678.5766,99.67805 C -681.32646,108.87524 -687.49381,117.725 -694.6902,122.80003 C -697.9281,125.08346 -700.5773,127.44814 -700.5773,128.05487 C -700.5773,132.21009 -692.90472,132.74991 -687.46138,128.97768 z M -977.37291,42.60831 C -972.22365,40.16997 -965.12776,33.12238 -963.47032,28.80034 C -956.469,10.54327 -945.59018,-63.95606 -947.57416,-80.0583 C -949.11929,-92.59876 -953.7586,-103.02062 -965.89305,-121.21024 C -975.93258,-136.25956 -975.78891,-136.19051 -993.71594,-134.58428 C -1007.8564,-133.31733 -1022.7259,-129.34283 -1040.0773,-122.19226 C -1046.1273,-119.69904 -1059.8523,-114.64169 -1070.5773,-110.9537 C -1095.6041,-102.34776 -1110.7311,-95.30664 -1114.5081,-90.50524 C -1121.1345,-82.08173 -1124.053,-72.57384 -1125.1176,-55.94199 C -1125.6051,-48.32635 -1125.3785,-44.52089 -1124.1675,-39.98189 C -1123.2929,-36.70384 -1122.5773,-30.27688 -1122.5773,-25.69977 C -1122.5773,-16.17649 -1121.3223,-12.40809 -1115.9789,-5.88727 C -1105.682,6.67882 -1088.0013,15.18725 -1061.0773,20.53292 C -1051.415,22.45135 -1048.5572,23.54517 -1037.5773,29.52763 C -1018.7526,39.78436 -1014.993,41.53185 -1007.2153,43.63992 C -997.55724,46.25763 -984.09687,45.79232 -977.37291,42.60831 z M -809.0773,32.50519 C -801.45078,30.12983 -791.81212,25.39686 -772.71405,14.64935 C -764.35481,9.94516 -756.58207,6.49211 -748.71405,3.9873 C -735.18316,-0.32029 -729.36121,-3.04932 -721.0773,-8.96741 C -711.25025,-15.98792 -708.09794,-19.95444 -704.80556,-29.44199 C -700.53903,-41.73672 -699.08444,-50.42108 -699.11074,-63.44199 C -699.13808,-76.97682 -701.31301,-85.39547 -707.88753,-97.41491 C -713.02993,-106.81616 -718.21449,-112.41735 -730.45676,-121.79779 C -744.35183,-132.44466 -751.87719,-135.96391 -764.11982,-137.54038 C -776.91631,-139.18817 -811.1637,-139.25551 -819.03866,-137.64836 C -827.28663,-135.96509 -848.23119,-125.45778 -854.4074,-119.90484 C -860.63744,-114.30349 -871.10903,-97.17616 -873.33797,-88.94199 C -875.49343,-80.97925 -875.50973,-60.22907 -873.36703,-51.94199 C -872.51378,-48.64199 -867.69158,-35.36699 -862.65102,-22.44199 C -857.61046,-9.51699 -851.21571,6.90801 -848.44045,14.05801 C -843.14592,27.69853 -839.50447,33.51561 -835.48611,34.75212 C -831.27436,36.04813 -816.38527,34.78133 -809.0773,32.50519 z"
   id="path2474" />
	</g>
</g>
<g
   inkscape:groupmode="layer"
   id="layer3"
   inkscape:label="pentagon"
EOF
	if ( $ornament eq "pentagon" ) {
		$output .= <<EOF;
   style="opacity:1;display:inline"
EOF
	} else {
		$output .= <<EOF;
   style="display:none"
EOF
	};
	$output .= <<EOF;
   transform="translate(-0.116,43.599725)">
	<path
   style="fill:#000000;fill-opacity:1;stroke:#fdf81a;stroke-width:3.08457875;stroke-opacity:1"
   d="M 85.627234,106.16526 L 99.156324,123.39862 L 120.51914,117.16125 L 120.2248,95.948534 L 98.595414,88.943204 L 85.627234,106.16526 z"
   id="path2338" />
</g>
<g
   inkscape:groupmode="layer"
   id="layer4"
   inkscape:label="chaoslet"
EOF
	if ( $ornament eq "chaoslet" ) {
		$output .= <<EOF;
   style="opacity:1;display:inline"
EOF
	} else {
		$output .= <<EOF;
   style="display:none"
EOF
	};
	$output .= <<EOF;
   transform="translate(-0.116,43.599725)">
	<g
   id="g3496"
   transform="matrix(7.661446e-4,-3.560363e-2,3.560363e-2,7.661446e-4,97.23967,103.3811)"
   style="fill:#e3cc0b;fill-opacity:1">
		<path
   id="path3498"
   d="M 294.407,7.95792 C 300.62,8.98492 313.524,28.3799 311.961,63.9999 C 307.661,66.2869 302.672,64.9449 299.414,64.8939 C 289.23,62.2119 298.736,35.3389 284.461,25.3479 C 263.79,10.8809 119.447,14.4069 45.5808,21.1209 C 13.592,24.0289 17.478,87.0639 16.8569,120.43 C 16.34,148.198 17.3017,178.549 28.2758,209.36 C 37.7226,235.884 72.5747,226.769 104.247,227.931 C 161.225,227.931 265.228,229.814 277.777,224.806 C 286.869,221.177 290.573,207.834 292.486,199.231 C 295.837,184.162 292.318,173.624 304.308,173.907 C 310.621,174.056 311.863,179.764 310.9,190.679 C 309.899,202.025 306.507,217.12 301.772,234.684 C 298.351,247.372 274.76,244.813 259.144,244.813 C 180.218,242.704 100.45,245.236 24.0554,243.125 C 1.9155,242.514 1.46946,137.911 0.285625,118.923 C -1.10525,96.6069 2.51438,7.01993 21.3615,6.01993 C 35.3674,5.27692 113.628,0.0309143 159.959,0.0189209 C 205.016,0.00692749 252.988,1.11093 294.407,7.95792"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none" />
		<path
   id="path3500"
   d="M 223.69,24.0759 C 229.177,39.6919 215.671,64.1719 235.93,72.6129 C 309.368,85.2749 395.047,57.8409 457.512,96.2479 C 474.394,112.708 487.056,131.701 495.075,151.96 L 495.075,142.675 C 485.79,116.929 466.797,94.9819 448.648,72.6129 C 453.713,65.8599 459.622,73.8789 464.686,75.9889 C 483.257,99.2019 502.249,122.838 509.425,150.694 C 510.69,152.382 513.223,155.759 515.333,152.804 L 518.288,149.85 C 511.957,119.884 492.964,95.4039 476.926,69.6579 C 484.101,65.0149 491.276,73.0349 497.185,77.6769 C 509.425,97.9359 522.931,118.195 527.573,141.83 C 530.949,144.362 535.17,139.72 536.858,136.765 C 534.326,118.194 527.994,101.734 520.397,86.1179 C 521.663,84.0079 521.663,81.0529 524.618,81.0529 C 542.767,90.7599 542.345,111.864 548.675,128.324 C 554.584,127.902 557.538,109.331 565.135,120.305 C 567.667,127.058 555.006,137.61 568.09,138.454 C 561.759,168.842 528.416,192.478 499.294,199.231 C 484.1,202.607 463.841,207.249 452.445,195.433 C 454.555,189.946 462.152,189.102 467.639,188.258 C 501.404,186.992 533.481,174.752 553.74,147.74 L 552.896,146.896 C 520.819,168.421 481.146,189.102 441.472,173.064 C 438.096,172.22 436.407,167.577 438.518,165.045 C 439.362,162.513 436.83,161.247 435.563,160.824 C 368.455,163.778 297.967,154.5 232.97,165.051 C 225.84,166.209 225.036,172.797 223.686,178.133 C 220.272,191.644 228.896,210.78 220.862,217.979 C 220.862,217.979 214.926,219.72 210.606,217.802 C 209.595,212.193 206.379,180.658 213.554,163.776 C 222.631,142.419 303.508,149.623 326.888,149.15 C 369.61,148.287 419.526,146.896 459.622,149.851 C 448.226,138.455 430.5,138.033 413.195,138.455 C 358.327,137.611 272.591,137.896 237.819,135.989 C 186.388,133.167 167.977,184.882 135.478,218.647 L 120.284,218.647 C 140.543,190.37 162.381,158.125 190.346,133.391 C 194.855,129.403 197.991,128.776 205.54,126.639 C 226.565,120.686 430.499,127.483 430.499,127.483 C 439.784,129.593 449.914,130.859 458.777,134.657 C 453.712,121.573 437.252,118.197 424.168,116.51 C 351.151,114.4 277.291,116.088 205.54,111.445 C 186.125,105.536 175.996,81.4789 160.801,66.7059 L 128.302,25.3439 L 144.762,26.1879 C 165.865,50.6669 180.337,80.6939 207.649,100.048 C 213.669,104.314 342.251,103.075 410.233,103.002 C 421.193,102.99 444.003,110.177 458.775,118.197 C 461.307,114.821 457.087,111.866 454.554,109.334 C 423.743,79.7899 360.192,88.9909 337.226,89.0699 C 296.941,89.2099 248.993,97.5919 215.667,76.8349 C 207.526,71.7639 208.915,40.9599 212.714,24.0769 L 223.687,24.0769"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none" />
		<path
   id="path3502"
   d="M 575.267,153.649 C 568.092,184.038 545.723,211.471 517.444,226.666 C 499.717,230.465 476.926,242.282 462.576,224.556 C 472.284,215.693 490.01,221.602 501.406,214.426 C 530.95,205.985 555.264,179.952 570.202,153.649 C 572.112,152.328 573.397,150.826 575.267,153.649"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none" />
		<path
   id="path3504"
   d="M 584.142,179.84 C 579.077,206.008 566.415,233.442 539.403,246.526 C 527.585,252.013 509.015,258.344 498.041,248.636 L 498.041,244.415 C 539.825,246.103 560.928,202.209 577.811,172.665 C 582.454,172.243 582.876,176.463 584.142,179.84"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none" />
		<path
   id="path3506"
   d="M 611.567,280.265 C 631.446,284.489 650.816,264.65 655.037,290.396 C 638.154,299.259 615.363,296.727 597.637,291.662 C 593.838,299.259 599.325,307.7 597.637,316.986 C 595.105,341.888 660.19484,324.95439 638.24784,340.14839 C 629.774,355.95981 571.59396,336.08595 579.88887,316.83817 C 589.59587,282.22917 578.222,272.247 555.008,246.923 L 570.202,232.995 C 579.065,250.721 589.098,275.49 611.566,280.264"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none"
   sodipodi:nodetypes="ccccccccc" />
		<path
   id="path3508"
   d="M 609.30046,39.28197 C 633.77946,86.55297 610.98846,141.84297 605.07946,190.37997 C 607.61146,208.52897 610.14446,227.09897 625.33846,239.76097 C 623.65046,243.98197 626.18246,254.53297 619.42946,252.00097 C 597.90446,240.60497 590.72946,217.81397 591.15146,194.17897 C 591.41217,113.56588 613.60887,86.27896 607.18946,76.84597 L 603.39146,68.82797 C 586.08646,87.39797 566.67246,110.61197 567.93846,139.73297 L 556.54246,141.84297 C 543.88046,101.32497 588.19746,78.09997 594.10646,41.80297 C 594.10646,41.80297 603.81346,38.01697 609.30046,39.28197"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none"
   sodipodi:nodetypes="ccccccccccc" />
	</g>
</g>
<g
   inkscape:groupmode="layer"
   id="layer5"
   inkscape:label="hackeroid"
EOF
	if ( $ornament eq "hackeroid" ) {
		$output .= <<EOF;
   style="opacity:1;display:inline"
EOF
	} else {
		$output .= <<EOF;
   style="display:none"
EOF
	};
	$output .= <<EOF;
   transform="translate(-0.116,43.599725)">
	<g
   id="g2303"
   transform="matrix(0.600406,0,0,0.542865,138.0728,140.4154)">
		<path
   style="fill:#fefe00"
   d="M -90.257896,-55.998137 L -90.257896,-72.770215 L -81.987008,-80.998137 L -73.716121,-89.226059 L -57.214931,-89.226059 L -40.71374,-89.226059 L -32.485818,-80.955171 L -24.257896,-72.684284 L -24.257896,-55.955171 L -24.257896,-39.226059 L -29.257896,-39.226059 L -34.257896,-39.226059 L -34.257896,-47.226059 L -34.257896,-55.226059 L -39.031356,-55.226059 C -43.668758,-55.226059 -44.031504,-54.998034 -51.757896,-47.226059 L -59.710976,-39.226059 L -66.210976,-39.226059 L -72.710976,-39.226059 L -64.757896,-47.226059 L -56.804816,-55.226059 L -68.531356,-55.226059 L -80.257896,-55.226059 L -80.257896,-47.226059 L -80.257896,-39.226059 L -85.257896,-39.226059 L -90.257896,-39.226059 L -90.257896,-55.998137 z M -34.257896,-67.44171 C -34.257896,-68.738951 -36.211237,-71.640522 -38.970304,-74.44171 L -43.682712,-79.226059 L -57.185955,-79.226059 L -70.689198,-79.226059 L -75.473547,-74.513651 C -78.418398,-71.61308 -80.257896,-68.921704 -80.257896,-67.513651 L -80.257896,-65.226059 L -57.257896,-65.226059 L -34.257896,-65.226059 L -34.257896,-67.44171 z"
   id="path2315" />
		<path
   style="fill:#00fefe"
   d="M -90.257896,-55.998137 L -90.257896,-72.770215 L -81.987008,-80.998137 L -73.716121,-89.226059 L -57.214931,-89.226059 L -40.71374,-89.226059 L -32.485818,-80.955171 L -24.257896,-72.684284 L -24.257896,-55.955171 L -24.257896,-39.226059 L -29.257896,-39.226059 L -34.257896,-39.226059 L -34.257896,-47.226059 L -34.257896,-55.226059 L -39.031356,-55.226059 C -43.668758,-55.226059 -44.031504,-54.998034 -51.757896,-47.226059 L -59.710976,-39.226059 L -66.210976,-39.226059 L -72.710976,-39.226059 L -64.757896,-47.226059 L -56.804816,-55.226059 L -68.531356,-55.226059 L -80.257896,-55.226059 L -80.257896,-47.226059 L -80.257896,-39.226059 L -85.257896,-39.226059 L -90.257896,-39.226059 L -90.257896,-55.998137 z M -32.653729,-56.955226 C -32.986021,-57.287517 -33.22237,-56.696892 -33.178949,-55.642726 C -33.130965,-54.477783 -32.894008,-54.240826 -32.574782,-55.038559 C -32.285911,-55.760434 -32.321438,-56.622934 -32.653729,-56.955226 z M -85.452226,-75.726059 L -82.757896,-78.726059 L -86.007896,-75.788968 C -89.051386,-73.038504 -89.245881,-72.46663 -89.068811,-66.788968 L -88.879727,-60.726059 L -88.513142,-66.726059 C -88.220003,-71.523953 -87.606745,-73.327112 -85.452226,-75.726059 z M -32.417933,-66.976059 C -32.574426,-70.643001 -32.586874,-70.654466 -32.979976,-67.493697 L -33.381982,-64.261335 L -57.569939,-63.975068 L -81.757896,-63.688801 L -57.007896,-63.45743 L -32.257896,-63.226059 L -32.417933,-66.976059 z M -34.257896,-67.44171 C -34.257896,-68.738951 -36.211237,-71.640522 -38.970304,-74.44171 L -43.682712,-79.226059 L -57.185955,-79.226059 L -70.689198,-79.226059 L -75.473547,-74.513651 C -78.418398,-71.61308 -80.257896,-68.921704 -80.257896,-67.513651 L -80.257896,-65.226059 L -57.257896,-65.226059 L -34.257896,-65.226059 L -34.257896,-67.44171 z M -26.257896,-73.551745 C -26.257896,-73.730872 -27.495396,-74.968372 -29.007896,-76.301745 L -31.757896,-78.726059 L -29.333582,-75.976059 C -27.067695,-73.40577 -26.257896,-72.767471 -26.257896,-73.551745 z"
   id="path2313" />
		<path
   style="fill:#fe0000"
   d="M -90.257896,-55.998137 L -90.257896,-72.770215 L -81.987008,-80.998137 L -73.716121,-89.226059 L -57.214931,-89.226059 L -40.71374,-89.226059 L -32.485818,-80.955171 L -24.257896,-72.684284 L -24.257896,-55.955171 L -24.257896,-39.226059 L -29.257896,-39.226059 L -34.257896,-39.226059 L -34.257896,-47.226059 L -34.257896,-55.226059 L -39.031356,-55.226059 C -43.668758,-55.226059 -44.031504,-54.998034 -51.757896,-47.226059 L -59.710976,-39.226059 L -66.210976,-39.226059 L -72.710976,-39.226059 L -64.757896,-47.226059 L -56.804816,-55.226059 L -68.531356,-55.226059 L -80.257896,-55.226059 L -80.257896,-47.226059 L -80.257896,-39.226059 L -85.257896,-39.226059 L -90.257896,-39.226059 L -90.257896,-55.998137 z M -32.653729,-56.955226 C -32.986021,-57.287517 -33.22237,-56.696892 -33.178949,-55.642726 C -33.130965,-54.477783 -32.894008,-54.240826 -32.574782,-55.038559 C -32.285911,-55.760434 -32.321438,-56.622934 -32.653729,-56.955226 z M -80.986952,-79.976059 L -73.807951,-87.226059 L -57.30644,-87.226059 L -40.804928,-87.226059 L -33.281412,-79.976059 L -25.757896,-72.726059 L -33.232868,-80.476059 L -40.707841,-88.226059 L -57.210745,-88.226059 L -73.713649,-88.226059 L -81.485772,-80.499519 L -89.257896,-72.772979 L -89.068811,-66.749519 L -88.879727,-60.726059 L -88.52284,-66.726059 C -88.169142,-72.672451 -88.101812,-72.790835 -80.986952,-79.976059 z M -32.417933,-66.976059 C -32.574426,-70.643001 -32.586874,-70.654466 -32.979976,-67.493697 L -33.381982,-64.261335 L -57.569939,-63.975068 L -81.757896,-63.688801 L -57.007896,-63.45743 L -32.257896,-63.226059 L -32.417933,-66.976059 z M -34.257896,-67.44171 C -34.257896,-68.738951 -36.211237,-71.640522 -38.970304,-74.44171 L -43.682712,-79.226059 L -57.185955,-79.226059 L -70.689198,-79.226059 L -75.473547,-74.513651 C -78.418398,-71.61308 -80.257896,-68.921704 -80.257896,-67.513651 L -80.257896,-65.226059 L -57.257896,-65.226059 L -34.257896,-65.226059 L -34.257896,-67.44171 z"
   id="path2311" />
		<path
   style="fill:#00fe00"
   d="M -90.257896,-55.998137 L -90.257896,-72.770215 L -81.987008,-80.998137 L -73.716121,-89.226059 L -57.214931,-89.226059 L -40.71374,-89.226059 L -32.485818,-80.955171 L -24.257896,-72.684284 L -24.257896,-55.955171 L -24.257896,-39.226059 L -29.257896,-39.226059 L -34.257896,-39.226059 L -34.257896,-47.226059 L -34.257896,-55.226059 L -39.031356,-55.226059 C -43.668758,-55.226059 -44.031504,-54.998034 -51.757896,-47.226059 L -59.710976,-39.226059 L -66.210976,-39.226059 L -72.710976,-39.226059 L -64.757896,-47.226059 L -56.804816,-55.226059 L -68.531356,-55.226059 L -80.257896,-55.226059 L -80.257896,-47.226059 L -80.257896,-39.226059 L -85.257896,-39.226059 L -90.257896,-39.226059 L -90.257896,-55.998137 z M -82.257896,-48.038968 C -82.257896,-54.303493 -82.499372,-55.083225 -85.257896,-57.726059 L -88.257896,-60.600241 L -88.257896,-50.91315 L -88.257896,-41.226059 L -85.257896,-41.226059 L -82.257896,-41.226059 L -82.257896,-48.038968 z M -54.535962,-46.476059 L -49.382347,-51.726059 L -51.378804,-54.159312 L -53.37526,-56.592566 L -61.058514,-48.909312 L -68.741767,-41.226059 L -64.215671,-41.226059 C -60.076713,-41.226059 -59.248764,-41.675115 -54.535962,-46.476059 z M -26.257896,-50.91315 L -26.257896,-60.600241 L -29.147465,-57.831858 C -31.288121,-55.78098 -32.198119,-55.408517 -32.658554,-56.394767 C -33.000389,-57.126978 -33.056227,-56.601059 -32.782639,-55.226059 C -32.50905,-53.851059 -32.279061,-50.138559 -32.271551,-46.976059 C -32.257969,-41.256871 -32.24182,-41.226059 -29.257896,-41.226059 L -26.257896,-41.226059 L -26.257896,-50.91315 z M -80.986952,-79.976059 L -73.807951,-87.226059 L -57.30644,-87.226059 L -40.804928,-87.226059 L -33.281412,-79.976059 L -25.757896,-72.726059 L -33.232868,-80.476059 L -40.707841,-88.226059 L -57.210745,-88.226059 L -73.713649,-88.226059 L -81.485772,-80.499519 L -89.257896,-72.772979 L -89.068811,-66.749519 L -88.879727,-60.726059 L -88.52284,-66.726059 C -88.169142,-72.672451 -88.101812,-72.790835 -80.986952,-79.976059 z M -32.417933,-66.976059 C -32.574426,-70.643001 -32.586874,-70.654466 -32.979976,-67.493697 L -33.381982,-64.261335 L -57.569939,-63.975068 L -81.757896,-63.688801 L -57.007896,-63.45743 L -32.257896,-63.226059 L -32.417933,-66.976059 z M -34.257896,-67.44171 C -34.257896,-68.738951 -36.211237,-71.640522 -38.970304,-74.44171 L -43.682712,-79.226059 L -57.185955,-79.226059 L -70.689198,-79.226059 L -75.473547,-74.513651 C -78.418398,-71.61308 -80.257896,-68.921704 -80.257896,-67.513651 L -80.257896,-65.226059 L -57.257896,-65.226059 L -34.257896,-65.226059 L -34.257896,-67.44171 z"
   id="path2309" />
		<path
   style="fill:#0000fe"
   d="M -90.257896,-55.998137 L -90.257896,-72.770215 L -81.987008,-80.998137 L -73.716121,-89.226059 L -57.214931,-89.226059 L -40.71374,-89.226059 L -32.485818,-80.955171 L -24.257896,-72.684284 L -24.257896,-55.955171 L -24.257896,-39.226059 L -29.257896,-39.226059 L -34.257896,-39.226059 L -34.257896,-47.226059 L -34.257896,-55.226059 L -39.031356,-55.226059 C -43.668758,-55.226059 -44.031504,-54.998034 -51.757896,-47.226059 L -59.710976,-39.226059 L -66.210976,-39.226059 L -72.710976,-39.226059 L -64.757896,-47.226059 L -56.804816,-55.226059 L -68.531356,-55.226059 L -80.257896,-55.226059 L -80.257896,-47.226059 L -80.257896,-39.226059 L -85.257896,-39.226059 L -90.257896,-39.226059 L -90.257896,-55.998137 z M -82.257896,-49.226059 L -82.257896,-57.226059 L -68.257896,-57.226059 C -60.557896,-57.226059 -54.257896,-56.899141 -54.257896,-56.499575 C -54.257896,-56.100009 -57.509134,-52.500009 -61.482868,-48.499575 L -68.707841,-41.226059 L -64.209408,-41.226059 C -59.915791,-41.226059 -59.348869,-41.590302 -51.757896,-49.226059 C -43.866839,-57.16367 -43.7646,-57.226059 -38.647988,-57.226059 C -32.682149,-57.226059 -32.294412,-56.602778 -32.271551,-46.976059 C -32.257969,-41.256871 -32.24182,-41.226059 -29.257896,-41.226059 L -26.257896,-41.226059 L -26.257896,-57.452543 L -26.257896,-73.679027 L -33.482868,-80.952543 L -40.707841,-88.226059 L -57.256329,-88.226059 L -73.804816,-88.226059 L -81.553275,-80.431888 L -89.301733,-72.637716 L -88.624528,-56.931888 L -87.947322,-41.226059 L -85.102609,-41.226059 L -82.257896,-41.226059 L -82.257896,-49.226059 z M -82.258664,-66.647318 C -82.258242,-68.254011 -81.508884,-70.396226 -80.593426,-71.407797 C -79.033497,-73.131498 -79.064078,-73.390847 -81.08032,-75.537038 L -83.231684,-77.82706 L -78.460441,-82.52656 L -73.689198,-87.226059 L -57.257896,-87.226059 L -40.826594,-87.226059 L -36.055351,-82.52656 L -31.284108,-77.82706 L -33.457758,-75.513316 C -35.134898,-73.728082 -35.360327,-72.92849 -34.444652,-72.012815 C -33.791936,-71.360099 -33.257896,-69.356377 -33.257896,-67.560099 L -33.257896,-64.294138 L -57.758664,-64.010099 L -82.259433,-63.726059 L -82.258664,-66.647318 z M -34.257896,-67.44171 C -34.257896,-68.738951 -36.211237,-71.640522 -38.970304,-74.44171 L -43.682712,-79.226059 L -57.185955,-79.226059 L -70.689198,-79.226059 L -75.473547,-74.513651 C -78.418398,-71.61308 -80.257896,-68.921704 -80.257896,-67.513651 L -80.257896,-65.226059 L -57.257896,-65.226059 L -34.257896,-65.226059 L -34.257896,-67.44171 z"
   id="path2307" />
		<path
   style="fill:#0f1009"
   d="M -90.257896,-55.998137 L -90.257896,-72.770215 L -81.987008,-80.998137 L -73.716121,-89.226059 L -57.214931,-89.226059 L -40.71374,-89.226059 L -32.485818,-80.955171 L -24.257896,-72.684284 L -24.257896,-55.955171 L -24.257896,-39.226059 L -29.257896,-39.226059 L -34.257896,-39.226059 L -34.257896,-47.226059 L -34.257896,-55.226059 L -39.031356,-55.226059 C -43.668758,-55.226059 -44.031504,-54.998034 -51.757896,-47.226059 L -59.710976,-39.226059 L -66.210976,-39.226059 L -72.710976,-39.226059 L -64.757896,-47.226059 L -56.804816,-55.226059 L -68.531356,-55.226059 L -80.257896,-55.226059 L -80.257896,-47.226059 L -80.257896,-39.226059 L -85.257896,-39.226059 L -90.257896,-39.226059 L -90.257896,-55.998137 z M -82.257896,-49.335465 L -82.257896,-57.226059 L -68.029974,-57.226059 L -53.802052,-57.226059 L -62.012036,-48.976059 L -70.22202,-40.726059 L -64.882719,-41.060332 C -59.690853,-41.385374 -59.326123,-41.613182 -51.674117,-49.310332 C -43.8283,-57.202437 -43.78908,-57.226059 -38.531356,-57.226059 L -33.257896,-57.226059 L -33.257896,-48.92686 L -33.257896,-40.62766 L -29.757896,-41.036266 L -26.257896,-41.444871 L -26.257896,-57.561949 L -26.257896,-73.679027 L -33.482868,-80.952543 L -40.707841,-88.226059 L -57.210745,-88.226059 L -73.713649,-88.226059 L -81.485772,-80.499519 L -89.257896,-72.772979 L -89.257896,-56.70032 L -89.257896,-40.62766 L -85.757896,-41.036266 L -82.257896,-41.444871 L -82.257896,-49.335465 z M -82.258664,-66.757362 C -82.258065,-69.122522 -80.987933,-71.045377 -76.478899,-75.507362 L -70.699901,-81.226059 L -57.194738,-81.226059 L -43.689576,-81.226059 L -38.473736,-75.944614 C -34.383518,-71.802948 -33.257896,-69.975923 -33.257896,-67.478653 L -33.257896,-64.294138 L -57.758664,-64.010099 L -82.259433,-63.726059 L -82.258664,-66.757362 z M -34.257896,-67.44171 C -34.257896,-68.738951 -36.211237,-71.640522 -38.970304,-74.44171 L -43.682712,-79.226059 L -57.185955,-79.226059 L -70.689198,-79.226059 L -75.473547,-74.513651 C -78.418398,-71.61308 -80.257896,-68.921704 -80.257896,-67.513651 L -80.257896,-65.226059 L -57.257896,-65.226059 L -34.257896,-65.226059 L -34.257896,-67.44171 z"
   id="path2305" />
	</g>
</g>
<g
   inkscape:groupmode="layer"
   id="layer6"
   inkscape:label="chaosknoten"
EOF
	if ( $ornament eq "chaosknoten" ) {
		$output .= <<EOF;
   style="opacity:1;display:inline"
EOF
	} else {
		$output .= <<EOF;
   style="display:none"
EOF
	};
	$output .= <<EOF;
   transform="translate(-0.116,43.599725)">
	<g
   id="g4504"
   transform="matrix(7.088891e-2,0,0,7.088891e-2,81.09832,93.28892)"
   style="fill:#e3cc0b;fill-opacity:1">
		<path
   id="path4506"
   d="M 294.407,7.95792 C 300.62,8.98492 313.524,28.3799 311.961,63.9999 C 307.661,66.2869 302.672,64.9449 299.414,64.8939 C 289.23,62.2119 298.736,35.3389 284.461,25.3479 C 263.79,10.8809 119.447,14.4069 45.5808,21.1209 C 13.592,24.0289 17.478,87.0639 16.8569,120.43 C 16.34,148.198 17.3017,178.549 28.2758,209.36 C 37.7226,235.884 72.5747,226.769 104.247,227.931 C 161.225,227.931 265.228,229.814 277.777,224.806 C 286.869,221.177 290.573,207.834 292.486,199.231 C 295.837,184.162 292.318,173.624 304.308,173.907 C 310.621,174.056 311.863,179.764 310.9,190.679 C 309.899,202.025 306.507,217.12 301.772,234.684 C 298.351,247.372 274.76,244.813 259.144,244.813 C 180.218,242.704 100.45,245.236 24.0554,243.125 C 1.9155,242.514 1.46946,137.911 0.285625,118.923 C -1.10525,96.6069 2.51438,7.01993 21.3615,6.01993 C 35.3674,5.27692 113.628,0.0309143 159.959,0.0189209 C 205.016,0.00692749 252.988,1.11093 294.407,7.95792"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none" />
		<path
   id="path4508"
   d="M 223.69,24.0759 C 229.177,39.6919 215.671,64.1719 235.93,72.6129 C 309.368,85.2749 395.047,57.8409 457.512,96.2479 C 474.394,112.708 487.056,131.701 495.075,151.96 L 495.075,142.675 C 485.79,116.929 466.797,94.9819 448.648,72.6129 C 453.713,65.8599 459.622,73.8789 464.686,75.9889 C 483.257,99.2019 502.249,122.838 509.425,150.694 C 510.69,152.382 513.223,155.759 515.333,152.804 L 518.288,149.85 C 511.957,119.884 492.964,95.4039 476.926,69.6579 C 484.101,65.0149 491.276,73.0349 497.185,77.6769 C 509.425,97.9359 522.931,118.195 527.573,141.83 C 530.949,144.362 535.17,139.72 536.858,136.765 C 534.326,118.194 527.994,101.734 520.397,86.1179 C 521.663,84.0079 521.663,81.0529 524.618,81.0529 C 542.767,90.7599 542.345,111.864 548.675,128.324 C 554.584,127.902 557.538,109.331 565.135,120.305 C 567.667,127.058 555.006,137.61 568.09,138.454 C 561.759,168.842 528.416,192.478 499.294,199.231 C 484.1,202.607 463.841,207.249 452.445,195.433 C 454.555,189.946 462.152,189.102 467.639,188.258 C 501.404,186.992 533.481,174.752 553.74,147.74 L 552.896,146.896 C 520.819,168.421 481.146,189.102 441.472,173.064 C 438.096,172.22 436.407,167.577 438.518,165.045 C 439.362,162.513 436.83,161.247 435.563,160.824 C 368.455,163.778 297.967,154.5 232.97,165.051 C 225.84,166.209 225.036,172.797 223.686,178.133 C 220.272,191.644 228.896,210.78 220.862,217.979 C 220.862,217.979 214.926,219.72 210.606,217.802 C 209.595,212.193 206.379,180.658 213.554,163.776 C 222.631,142.419 303.508,149.623 326.888,149.15 C 369.61,148.287 419.526,146.896 459.622,149.851 C 448.226,138.455 430.5,138.033 413.195,138.455 C 358.327,137.611 272.591,137.896 237.819,135.989 C 186.388,133.167 167.977,184.882 135.478,218.647 L 120.284,218.647 C 140.543,190.37 162.381,158.125 190.346,133.391 C 194.855,129.403 197.991,128.776 205.54,126.639 C 226.565,120.686 430.499,127.483 430.499,127.483 C 439.784,129.593 449.914,130.859 458.777,134.657 C 453.712,121.573 437.252,118.197 424.168,116.51 C 351.151,114.4 277.291,116.088 205.54,111.445 C 186.125,105.536 175.996,81.4789 160.801,66.7059 L 128.302,25.3439 L 144.762,26.1879 C 165.865,50.6669 180.337,80.6939 207.649,100.048 C 213.669,104.314 342.251,103.075 410.233,103.002 C 421.193,102.99 444.003,110.177 458.775,118.197 C 461.307,114.821 457.087,111.866 454.554,109.334 C 423.743,79.7899 360.192,88.9909 337.226,89.0699 C 296.941,89.2099 248.993,97.5919 215.667,76.8349 C 207.526,71.7639 208.915,40.9599 212.714,24.0769 L 223.687,24.0769"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none" />
		<path
   id="path4510"
   d="M 575.267,153.649 C 568.092,184.038 545.723,211.471 517.444,226.666 C 499.717,230.465 476.926,242.282 462.576,224.556 C 472.284,215.693 490.01,221.602 501.406,214.426 C 530.95,205.985 555.264,179.952 570.202,153.649 C 572.112,152.328 573.397,150.826 575.267,153.649"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none" />
		<path
   id="path4512"
   d="M 584.142,179.84 C 579.077,206.008 566.415,233.442 539.403,246.526 C 527.585,252.013 509.015,258.344 498.041,248.636 L 498.041,244.415 C 539.825,246.103 560.928,202.209 577.811,172.665 C 582.454,172.243 582.876,176.463 584.142,179.84"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none" />
		<path
   id="path4514"
   d="M 611.567,280.265 C 631.446,284.489 650.816,264.65 655.037,290.396 C 638.154,299.259 615.363,296.727 597.637,291.662 C 593.838,299.259 599.325,307.7 597.637,316.986 C 595.105,341.888 660.19484,324.95439 638.24784,340.14839 C 629.774,355.95981 571.59396,336.08595 579.88887,316.83817 C 589.59587,282.22917 578.222,272.247 555.008,246.923 L 570.202,232.995 C 579.065,250.721 589.098,275.49 611.566,280.264"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none"
   sodipodi:nodetypes="ccccccccc" />
		<path
   id="path4516"
   d="M 609.30046,39.28197 C 633.77946,86.55297 610.98846,141.84297 605.07946,190.37997 C 607.61146,208.52897 610.14446,227.09897 625.33846,239.76097 C 623.65046,243.98197 626.18246,254.53297 619.42946,252.00097 C 597.90446,240.60497 590.72946,217.81397 591.15146,194.17897 C 591.41217,113.56588 613.60887,86.27896 607.18946,76.84597 L 603.39146,68.82797 C 586.08646,87.39797 566.67246,110.61197 567.93846,139.73297 L 556.54246,141.84297 C 543.88046,101.32497 588.19746,78.09997 594.10646,41.80297 C 594.10646,41.80297 603.81346,38.01697 609.30046,39.28197"
   style="fill:#e3cc0b;fill-opacity:1;stroke:none"
   sodipodi:nodetypes="ccccccccccc" />
	</g>
</g>
<g
   inkscape:groupmode="layer"
   id="layer7"
   inkscape:label="µKocmoc"
EOF
	if ( $text ) {
		$output .= <<EOF;
   style="opacity:1;display:inline"
EOF
	} else {
		$output .= <<EOF;
   style="display:none"
EOF
	};
	$output .= <<EOF;
   transform="translate(-5.116,43.599725)">
	<text
   xml:space="preserve"
   style="font-size:44px;font-style:italic;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;display:inline;font-family:Utopia"
   x="6.702704"
   y="-12.271553"
   id="text1872"
   sodipodi:linespacing="125%"><tspan
     sodipodi:role="line"
     id="tspan1874"
     x="6.702704"
     y="-12.271553">µK</tspan></text>

	<text
   xml:space="preserve"
   style="font-size:33px;font-style:italic;font-variant:normal;font-weight:bold;font-stretch:normal;text-align:start;line-height:100%;writing-mode:lr-tb;text-anchor:start;fill:#000000;fill-opacity:1;stroke:none;stroke-width:1px;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;display:inline;font-family:Utopia"
   x="64.000336"
   y="-12.271553"
   id="text1878"
   sodipodi:linespacing="100%"><tspan
     sodipodi:role="line"
     id="tspan1880"
     x="64.000336"
     y="-12.271553">OCMOC</tspan></text>

</g>
</svg>
EOF
	return($output);
};

