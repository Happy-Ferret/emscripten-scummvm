#!/usr/bin/perl
#
# This tools is kind of a hack to be able to maintain the credits list of
# ScummVM in a single central location. We then generate the various versions
# of the credits in other places from this source. In particular:
# - The AUTHORS file
# - The gui/credits.h header file
# - The credits.xml file, part of the DocBook manual
# - Finally, credits.inc, from the website
# And maybe in the future, also "doc/10.tex", the LaTeX version of the README.
# Although that might soon be obsolete, if the manual evolves enough.
#
# Initial version written by Fingolfin in December 2004.
#


use strict;
use Text::Wrap;

if ($Text::Wrap::VERSION < 2001.0929) {
	die "Text::Wrap version >= 2001.0929 is required. You have $Text::Wrap::VERSION\n";
}

my $mode = "";
my $max_name_width;
my $indent;
my $tab;

if ($#ARGV >= 0) {
	$mode = "TEXT" if ($ARGV[0] eq "--text");	# AUTHORS file
	$mode = "HTML" if ($ARGV[0] eq "--html");	# credits.inc (for use on the website)
	$mode = "CPP" if ($ARGV[0] eq "--cpp");		# credits.h (for use by about.cpp)
	$mode = "XML" if ($ARGV[0] eq "--xml");		# credits.xml (DocBook)
	$mode = "RTF" if ($ARGV[0] eq "--rtf");		# Credits.rtf (Mac OS X About box)
	$mode = "TEX" if ($ARGV[0] eq "--tex");		# 10.tex (LaTeX)
}

if ($mode eq "") {
	print STDERR "Usage: credits.pl [--text | --html | --cpp | --xml | --rtf]\n";
	print STDERR " Just pass --text / --html / --cpp / --xml / --rtf as parameter, and credits.pl\n";
	print STDERR " will print out the corresponding version of the credits to stdout.\n";
	exit 1;
}

$Text::Wrap::unexpand = 0;
if ($mode eq "TEXT") {
	$Text::Wrap::columns = 78;
	$max_name_width = 21; # The maximal width of a name.
	$indent = 7;
	$tab = " " x $indent;
} elsif ($mode eq "CPP") {
	$Text::Wrap::columns = 48;	# Approx.
}

# Convert HTML entities to ASCII for the plain text mode
sub html_entities_to_ascii {
	my $text = shift;
	
	# For now we hardcode these mappings
	# &aacute;  -> a
	# &eacute;  -> e
	# &oslash;  -> o
	# &ouml;    -> o / oe
	# &auml;    -> a
	# &amp;     -> &
	# &#322;    -> l
	$text =~ s/&aacute;/a/g;
	$text =~ s/&eacute;/e/g;
	$text =~ s/&oslash;/o/g;
	$text =~ s/&#322;/l/g;

	$text =~ s/&auml;/a/g;
	$text =~ s/&uuml;/u/g;
	# HACK: Torbj*o*rn but G*oe*ffringmann and R*oe*ver
	$text =~ s/&ouml;r/or/g;
	$text =~ s/&ouml;/oe/g;

	$text =~ s/&amp;/&/g;
	
	return $text;
}

# Convert HTML entities to RTF codes
sub html_entities_to_rtf {
	my $text = shift;
	
	$text =~ s/&aacute;/\\'87/g;
	$text =~ s/&eacute;/\\'8e/g;
	$text =~ s/&oslash;/\\'bf/g;
	$text =~ s/&#322;/\\uc0\\u322 /g;

	$text =~ s/&auml;/\\'8a/g;
	$text =~ s/&ouml;/\\'9a/g;
	$text =~ s/&uuml;/\\'9f/g;

	$text =~ s/&amp;/&/g;
	
	return $text;
}

# Convert HTML entities to TeX codes
sub html_entities_to_tex {
	my $text = shift;
	
	$text =~ s/&aacute;/\\'a/g;
	$text =~ s/&eacute;/\\'e/g;
	$text =~ s/&oslash;/{\\o}/g;
	$text =~ s/&#322;/{\\l}/g;

	$text =~ s/&auml;/\\"a/g;
	$text =~ s/&ouml;/\\"o/g;
	$text =~ s/&uuml;/\\"u/g;

	$text =~ s/&amp;/\\&/g;
	
	return $text;
}

sub begin_credits {
	my $title = shift;

	if ($mode eq "TEXT") {
		#print html_entities_to_ascii($title)."\n";
	} elsif ($mode eq "TEX") {
		print "% This file was generated by credits.pl. Do not edit by hand!\n";
		print '\section{Credits}' . "\n";
		print '\begin{itemize}' . "\n";
	} elsif ($mode eq "RTF") {
		print '{\rtf1\mac\ansicpg10000' . "\n";
		print '{\fonttbl\f0\fswiss\fcharset77 Helvetica-Bold;\f1\fswiss\fcharset77 Helvetica;}' . "\n";
		print '{\colortbl;\red255\green255\blue255;\red0\green128\blue0;}' . "\n";
		print '\vieww6920\viewh15480\viewkind0' . "\n";
		print "\n";
	} elsif ($mode eq "CPP") {
		print "// This file was generated by credits.pl. Do not edit by hand!\n";
		print "static const char *credits[] = {\n";
	} elsif ($mode eq "XML") {
		print "<!-- This file was generated by credits.pl. Do not edit by hand! -->\n";
		print "<appendix>\n";
		print "  <title>" . $title . "</title>\n";
		print "  <informaltable frame='none'>\n";
		print "  <tgroup cols='3' align='left' colsep='0' rowsep='0'>\n";
		print "  <colspec colname='start' colwidth='0.5cm'/>\n";
		print "  <colspec colname='name' colwidth='4cm'/>\n";
		print "  <colspec colname='job'/>\n";
		print "  <tbody>\n";
	} elsif ($mode eq "HTML") {
		print "<!-- This file was generated by credits.pl. Do not edit by hand! -->\n";
		print "<h1>$title</h1>\n";
		print "<table border='0' cellpadding='5' cellspacing='0' style='margin-left: 3em;'>\n";
	}
}

sub end_credits {
	if ($mode eq "TEXT") {
	} elsif ($mode eq "TEX") {
		print '\end{itemize}' . "\n";
		print "\n";
	} elsif ($mode eq "RTF") {
		print "}\n";
	} elsif ($mode eq "CPP") {
		print "};\n";
	} elsif ($mode eq "XML") {
		print "  </tbody>\n";
		print "  </tgroup>\n";
		print "  </informaltable>\n";
		print "</appendix>\n";
	} elsif ($mode eq "HTML") {
		print "</table>\n";
	}
}

sub begin_section {
	my $title = shift;
	if ($mode eq "TEXT") {
		$title = html_entities_to_ascii($title);
		print $title.":\n";
	} elsif ($mode eq "TEX") {
		print '\item \textbf{' . html_entities_to_tex($title) . "}\\\\\n";
		print '  \begin{tabular}[h]{p{4cm}l}' . "\n";
	} elsif ($mode eq "RTF") {
		$title = html_entities_to_rtf($title);

		# Center text
		print '\pard\qc' . "\n";
		print '\f0\b\fs28 \cf2 ' . $title . "\n";
		print '\f1\b0\fs24 \cf0 \\' . "\n";
	} elsif ($mode eq "CPP") {
		$title = html_entities_to_ascii($title);
		print '"\\\\C\\\\c1""'.$title.':",' . "\n";
	} elsif ($mode eq "XML") {
		print "  <row><entry namest='start' nameend='job'>";
		print "<emphasis role='bold'>" . $title . ":</emphasis>";
		print "</entry></row>\n";
	} elsif ($mode eq "HTML") {
		print "<tr><td colspan=3><h2>$title:</h2></td></tr>\n";
	}
}

sub end_section {
	if ($mode eq "TEXT") {
		print "\n";
	} elsif ($mode eq "TEX") {
		print '  \end{tabular}' . "\n";
	} elsif ($mode eq "RTF") {
		print "\\\n";
	} elsif ($mode eq "CPP") {
		print '"\\\\L\\\\c0""",' . "\n";
	} elsif ($mode eq "XML") {
		print "  <row><entry namest='start' nameend='job'> </entry></row>\n\n";
	} elsif ($mode eq "HTML") {
		print "<tr><td colspan=3>&nbsp;</td></tr>\n";
	}
}

sub add_person {
	my $name = shift;
	my $nick = shift;
	my $desc = shift;
	
	if ($mode eq "TEXT") {
		$name = $nick if $name eq "";
		$name = html_entities_to_ascii($name);
		$desc = html_entities_to_ascii($desc);
		
		printf $tab."%-".$max_name_width.".".$max_name_width."s - ", $name;
		
		# Print desc wrapped
		my $inner_indent = $indent + $max_name_width + 3;
		my $multitab = " " x $inner_indent;
		print substr(wrap($multitab, $multitab, $desc), $inner_indent)."\n"
	} elsif ($mode eq "TEX") {
		$name = $nick if $name eq "";
		$name = html_entities_to_tex($name);
		$desc = html_entities_to_tex($desc);

		print "    $name & $desc\\\\\n";
	} elsif ($mode eq "RTF") {
		$name = $nick if $name eq "";
		$name = html_entities_to_rtf($name);
		$desc = html_entities_to_rtf($desc);

		# Left align name
		print '\pard\ql\qnatural' . "\n";
		print $name . "\\\n";

		# Left align description, with a left indention
		print '\pard\li560\ql\qnatural' . "\n";
		# Italics
		print "\\i " . $desc . "\\i0\\\n";
	} elsif ($mode eq "CPP") {
		$name = $nick if $name eq "";
		$name = html_entities_to_ascii($name);
		$desc = html_entities_to_ascii($desc);

		print '"\\\\L\\\\c0""  '.$name.'",' . "\n";

		# Print desc wrapped
		my $line_start = '"\\\\L\\\\c2""';
		my $line_end = '",';
		$Text::Wrap::separator = $line_end . "\n" .$line_start ;
		print $line_start . wrap("    ", "    ", $desc) . $line_end . "\n";
		$Text::Wrap::separator = "\n";

	} elsif ($mode eq "XML") {
		$name = $nick if $name eq "";
		print "  <row><entry namest='name'>" . $name . "</entry>";
		print "<entry>" . $desc . "</entry></row>\n";
	} elsif ($mode eq "HTML") {
		$name = "???" if $name eq "";
		print "<tr>";
		print "<td>".$name."</td>";
		if ($nick ne "") {
			print "<td>[&nbsp;".$nick."&nbsp;]</td>";
		} else {
			print "<td></td>";
		}
		print "<td>".$desc."</td>\n";
	}
}

sub add_paragraph {
	my $text = shift;
	
	if ($mode eq "TEXT") {
		print wrap($tab, $tab, html_entities_to_ascii($text))."\n";
		print "\n";
	} elsif ($mode eq "TEX") {
		print "\n";
		print $text;
		print "\n";
	} elsif ($mode eq "RTF") {
		# Left align text
		print '\pard\ql\qnatural' . "\n";
		print $text . "\\\n";
		print "\\\n";
	} elsif ($mode eq "CPP") {
		my $line_start = '"\\\\L\\\\c0""';
		my $line_end = '",';
		print $line_start . $text . $line_end . "\n";
		print $line_start . $line_end . "\n";
	} elsif ($mode eq "XML") {
		print "  <row><entry namest='start' nameend='job'>" . $text . "</entry></row>\n";
		print "  <row><entry namest='start' nameend='job'> </entry></row>\n\n";
	} elsif ($mode eq "HTML") {
		print '<tr><td colspan="3">';
		print $text;
		print '</td></tr>'."\n";
		print '<tr><td colspan="3">&nbsp;</td></tr>'."\n";
	}
}

#
# Now follows the actual credits data! The format should be clear, I hope.
# Note that people are sorted by their last name in most cases; in the
# 'Team' section, they are first grouped by category (Engine; porter; misc).
#

begin_credits("Credits");
  begin_section("The ScummVM team");
	add_person('James Brown', 'endy', "Lead developer");
	add_person('Max Horn', 'fingolfin', "Lead developer");
	add_person("Torbj&ouml;rn Andersson", "eriktorbjorn", "Engine: SCUMM, Broken Sword II, SAGA, Gob");
	add_person("David Eriksson", "twogood", "Engine: Flight of the Amazon Queen");
	add_person("Robert G&ouml;ffringmann", "lavosspawn", "Engine: Beneath a Steel Sky, Broken Sword I");
	add_person("Jonathan Gray", "khalek", "Engine: SCUMM, HE, Broken Sword II");
	add_person("Travis Howell", "Kirben", "Engine: SCUMM, HE, Simon the Sorcerer");
	add_person("Oliver Kiehl", "olki", "Engine: Beneath a Steel Sky, Simon");
	add_person("Pawe&#322; Ko&#322;odziejski", "aquadran", "Engine: SCUMM (Codecs, iMUSE, Smush, etc.)");
	add_person("Andrew Kurushin", "ajax16384", "Engine: SAGA");
	add_person("Gregory Montoir", "cyx", "Engine: Flight of the Amazon Queen, HE, Kyra");
	add_person("Joost Peters", "joostp", "Engine: Beneath a Steel Sky, Flight of the Amazon Queen");
	add_person("Eugene Sandulenko", "_sev", "Engine: SCUMM (FT INSANE), HE, SAGA, Gob");
	add_person("Johannes Schickel", "LordHoto", "Engine: Kyra, GUI improvements");
	add_person("Chris Apers", "chrilith ", "Port: PalmOS");
	add_person("Nicolas Bacca", "arisme", "Port: PocketPC/WinCE");
	add_person("Jurgen Braam", "SumthinWicked", "Port: EPOC/SymbianOS maintainer");
	add_person("Marcus Comstedt", "", "Port: Dreamcast");
	add_person("Hans-J&ouml;rg Frieden", "", "Port: AmigaOS 4");
	add_person("Lars Persson", "AnotherGuest", "Port: EPOC/SymbianOS, ESDL");
	add_person("Jerome Fisher", "KingGuppy", "MT-32 emulator");
	add_person("Jochen Hoenicke", "hoenicke", "Speaker &amp; PCjr sound support, Adlib work");
  end_section();


  begin_section("Retired Team Members");
	add_person("Ralph Brorsen", "painelf", "Help with GUI implementation");
	add_person("Jamieson Christian", "jamieson630", "iMUSE, MIDI, all things musical");
	add_person('Vincent Hamm', 'yazoo', "Co-Founder");
	add_person("Ruediger Hanke", "", "Port: MorphOS");
	add_person("Felix Jakschitsch", "yot", "Zak256 reverse engineering");
	add_person("Mutwin Kraus", "mutle", "Original MacOS porter");
	add_person("Peter Moraliyski", "ph0x", "Port: GP32");
	add_person('Jeremy Newman', 'laxdragon', "Former webmaster");
	add_person('Ludvig Strigeus', 'ludde', "Original ScummVM and SimonVM author");
	add_person("Lionel Ulmer", "bbrox", "Port: X11");
  end_section();


  begin_section("Contributors");
	add_person("Tore Anderson", "tore", "Packaging for Debian GNU/Linux");
	add_person("Stuart Caie", "", "Decoders for Simon 1 Amiga data files");
	add_person("Janne Huttunen", "", "V3 actor mask support, Dig/FT SMUSH audio");
	add_person("Kov&aacute;cs Endre J&aacute;nos", "", "Several fixes for Simon1");
	add_person("Jeroen Janssen", "", "Numerous readability and bugfix patches");
	add_person("Andreas Karlsson", "Sprawl", "Initial port for EPOC/SymbianOS");
	add_person("Robert Kelsen", "", "Packaging for SlackWare");
	add_person("Claudio Matsuoka", "", 'Daily Linux builds');
	add_person("Mikesch Nepomuk", "", "MI1 VGA floppy patches");
	add_person("Juha Niemim&auml;ki", "", "AmigaOS 4 port maintaining");
	add_person("Nicolas Noble", "pixels", "Config file and ALSA support");
	add_person("Willem Jan Palenstijn", "wjp", "Packaging for Fedora/RedHat");
	add_person("Stefan Parviainen", "", "Packaging for BeOS");
	add_person("", "Quietust", "Sound support for Amiga SCUMM V2/V3 games, MM NES support");
	add_person("Andreas R&ouml;ver", "", "Broken Sword 1/2 MPEG2 cutscene support");
	add_person("Edward Rudd", "", "Fixes for playing MP3 versions of MI1/Loom audio");
	add_person("Daniel Schepler", "", "Final MI1 CD music support, initial Ogg Vorbis support");
	add_person("Paul Smedley", "Creeping", "OS/2 fixes");
	add_person("Andr&eacute; Souza", "", "SDL-based OpenGL renderer");
	add_person("Tim ???", "realmz", "Initial MI1 CD music support");
  end_section();


  add_paragraph("And to all the contributors, users, and beta testers we've missed. Thanks!");

  # HACK!
  $max_name_width = 15;

  begin_section("Special thanks to");
	add_person("Sander Buskens", "", "For his work on the initial reversing of Monkey2");
	add_person("", "Canadacow", "For the original MT-32 emulator");
	add_person("Kevin Carnes", "", "For Scumm16, the basis of ScummVM's older gfx codecs");
	add_person("", "Jezar", "For his freeverb filter implementation");
	add_person("Ivan Dubrov", "", "For contributing the initial version of the Gobliiins engine");
	add_person("Jim Leiterman", "", "Various info on his FM-TOWNS/Marty SCUMM ports");
	add_person("Jimmi Th&oslash;gersen", "", "For ScummRev, and much obscure code/documentation");
	add_person("", "Tristan", "For additional work on the original MT-32 emulator");
  end_section();

  # HACK!
  $Text::Wrap::columns = 46 if $mode eq "CPP";

  add_paragraph(
  "Tony Warriner and everyone at Revolution Software Ltd. for sharing ".
  "with us the source of some of their brilliant games, allowing us to ".
  "release Beneath a Steel Sky as freeware... and generally being ".
  "supportive above and beyond the call of duty.");

  add_paragraph(
  "John Passfield and Steve Stamatiadis for sharing the source of their ".
  "classic title, Flight of the Amazon Queen and also being incredibly ".
  "supportive.");

  add_paragraph(
  "Joe Pearce from The Wyrmkeep Entertainment Co. for sharing the source ".
  "of their famous title Inherit the Earth and always prompt replies to ".
  "our questions.");

  add_paragraph(
  "Aric Wilmunder, Ron Gilbert, David Fox, Vince Lee, and all those at ".
  "LucasFilm/LucasArts who made SCUMM the insane mess to reimplement ".
  "that it is today. Feel free to drop us a line and tell us what you ".
  "think, guys!");

end_credits();
