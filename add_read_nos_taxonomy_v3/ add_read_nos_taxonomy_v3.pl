#!/usr/bin/perl -w
#This script will take PhymmBL output (tab delimited) and merge the taxonomic annotations with functional annotations (e.g. COG, Pfam) as produced by the RAMMCAP pipeline (through CAMERA website).  The script is currently setup to work with contigs made with CLC genomics workbench, so the regex matching the header must be changed to match the unique header for each dataset
use strict;



my $contigs_input = "cogs_with_reads_t1.txt";
my $taxon_input = "phymm_taxonomy.txt";

my $output_file = "cogs_with_taxonomy_t1_phymm_v3.txt";

my %hash_table;
my $hash_count = 0;
my $cogs_count = 0;

print "\nProgram started ............\n";

open (CONTIGS, $contigs_input) or die "Unable to open contig/reads input file, $contigs_input";
open (TAXON, $taxon_input) or die "Unable to open taxonomy input file, $taxon_input";

open (OUTPUT, ">$output_file") or die "Unable to open output file, $output_file";

print "Input and Output Files were successfully opened ......\n";

$/ = "\r";

while ( <TAXON> )
{
    my $line = $_;
    
    $line =~ s/\r//;
    
    my @fields = split (/\t/, $line);
    
    if ($fields[0] =~ m/(contig_\d*)/)
    {
        my $list = "";
        for (my $i = 1; $i <= $#fields; $i++)
        {
            $list = $list . $fields[$i] . ";"
        }
        
        $hash_table{$1} = $list;
        $hash_count++;
    }
}

$/ = "\n";

print "Hash-table of $hash_count taxonomy records created .......\n";

print OUTPUT "#Query\tTotal Read Count\tHit\tE-value\tIdentity\tScore\tQuery-start\tQuery-end\tHit-start\tHit-end\t",
             "Hit-length\tdescription\tclass\tclass description\tTaxonomy\n";

while ( <CONTIGS> )
{
    my $line = $_;
    chomp $line;
    my @fields = split (/\t/, $line);
    my $reads = 0;
    if ($fields[0] =~ m/(contig_\d*)/)
        {
            my $contig = $1;
            my $taxon = " - ";
            
            for (my $i = 0; $i <= $#fields; $i++)
            {
                print OUTPUT "$fields[$i]", "\t";
            }
            
            if ($hash_table{$contig})
            {
                $taxon = $hash_table{$contig};
                my @taxa = split (/;/, $taxon);
                for (my $i = 0; $i <= $#taxa; $i++)
                {
                    print OUTPUT "$taxa[$i]", "\t"; 
                }
            }
            
            print OUTPUT "\n";
            $cogs_count++;
        }
}

print "Output file, $output_file, created with $cogs_count entries...........\n";

close TAXON;
close CONTIGS;
close OUTPUT;

print "\nProgram Complete ..............\n";

