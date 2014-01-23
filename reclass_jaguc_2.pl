#!/usr/bin/perl -w

# Script to reclassify eukaryotic 18S rRNA OTUs (from the QIIME pipeline)   based on OTU identifications made using JAGUC (http://wwwagak.cs.uni-kl.de/jaguc.html)
# database
#

use strict;

use Getopt::Long;

my $infilename = 'input.txt';
my $outfilename = 'output.txt';
my $classfilename = 'classification.txt';
my $help =0;

GetOptions(
            'c|class:s'  => \$classfilename,
	    'i|in:s'     => \$infilename,
            'o|out:s'    => \$outfilename,
	    'h|help|?'   => \$help,
	    );


my $USAGE = "usage: reclass_jaguc.pl -c classfile -i inputfile [-o outfile]\n";
if( $help ) {
    die $USAGE;
}

open(CLASSFILE,"<$classfilename") || die "Can't open classification file: ",$classfilename;

open(INFILE,"<$infilename") || die "Can't open input file: ",$infilename;


open(OUTFILE,">$outfilename") || die "Can't open output file: ",$outfilename;

my %otu_classes = ();
my $taxonomy;

# populate hash of OTUs given in classification file
while (<CLASSFILE>) {
    my($line) = $_;
    chomp($line);
    # if current line is a taxonomy, make it current
    if($line =~ m/\//) {
	my  @pstring = (split(/;/,$line));
	$taxonomy = $pstring[0];
	$taxonomy =~ s/ \/ /\;/g;
	#print "taxonomy: $taxonomy\n";
    }
    if($line =~ m/^unspecified/) {
	my  @pstring = (split(/;/,$line));
	$taxonomy = $pstring[0];
	$taxonomy =~ s/ \/ /\;/g;
	#print "taxonomy: $taxonomy\n";
    }
    if($line =~ m/^not identified/) {
	my  @pstring = (split(/;/,$line));
	$taxonomy = $pstring[0];
	$taxonomy =~ s/ \/ /\;/g;
	#print "taxonomy: $taxonomy\n";
    }
    # if current line contains OTU designation, create hash entry
    # with current taxonomy
    if($line =~ m/- Sequence/) {
	my  @pstring = (split(/\;/,$line));
	# the OTU should be the first part of the fifth token (index 4)
	my $token = $pstring[4];
	#print "token1 $token\n";
	my @tokens = split(/\s/,$token);
	$token = $tokens[0];
	if ($token =~ /^\d+\z/) {
	#print "token2 $token\n";
	#$token =~ s/.*OTU_/OTU_/;
	    if ($taxonomy) {
		$otu_classes{ $token } = $taxonomy;
	    } else {
		print "ERROR: unrecognized taxonomy at OTU $token\n";
	    }
	} else {
	    print "ERROR: non-whole number token at taxonomy $taxonomy\n";
	}

    }
    # all other lines silently ignored

}

# for debugging
if (0) {
    while ((my $key, my $value) = each(%otu_classes)){
	print $key.": ".$value."\n";
    }
}


while (<INFILE>) {
    my($line) = $_;
    chomp($line);
    # file may have ^Ms - need to remove those as well:
    $line =~ s/\r//g;
    if($line =~ m/^#/) {
	print OUTFILE $line;
	print OUTFILE "\n";
    } 
    elsif ($line =~ m/^\d/) {
	# if the line begins with a digit, assume it is the OTU identifier
	my  @pstring = (split(/\t/,$line));
	my $otu_token = $pstring[0];
	if (exists $otu_classes{$otu_token}) {
	    my $update = join("\t",$line,$otu_classes{$otu_token});
	    print OUTFILE $update;
	    print OUTFILE "\n";
	} else {
	    # could print error here, but will silently ignore for now
	    # and print the line, as is, to the output file
	    print OUTFILE $line;
	    print OUTFILE "\n";
	}
    } else {
	# catch-all for any other lines - probably should never reach
	# this point.  May want to print error here.
	print OUTFILE $line;
	print OUTFILE "\n";
    }
    
    
}


