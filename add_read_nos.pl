#!/usr/bin/perl -w
#This script will take the read mapping output from CLC genomics workbench and add the number of reads mapping to each contig  in the functional annotation output from the RAMMCAP pipeline (on the CAMERA website).
use strict;



my $reads_input = "min300_mapping_WS50.txt";
my $cogs_input = "RPS-BLASTAGAINSTCOG-COGANNOTATION11.txt";

my $output_file = "cogs_with_reads_t1.txt";

my %hash_table;
my $hash_count = 0;
my $cogs_count = 0;

print "\nProgram started ............\n";

open (READS, $reads_input) or die "Unable to open reads input file, $reads_input";
open (COGS, $cogs_input) or die "Unable to open cogs input file, $cogs_input";

open (OUTPUT, ">$output_file") or die "Unable to open output file, $output_file";

print "Input and Output Files were successfully opened ......\n";

$/ = "\r";

while ( <READS> )
{
    my $line = $_;
    my @fields = split (/\t/, $line);
    if ($fields[0] =~ m/(contig \d*) mapping/)
    {
        $hash_table{$1} = $fields[2];
        $hash_count++;
    }
}

$/ = "\n";

print "Hash-table of $hash_count read counts created .......\n";

print OUTPUT "#Query\tTotal Read Count\tHit\tE-value\tIdentity\tScore\tQuery-start\tQuery-end\tHit-start\tHit-end\t",
             "Hit-length\tdescription\tclass\tclass description\n";

while ( <COGS> )
{
    my $line = $_;
    chomp $line;
    my @fields = split (/\t/, $line);
    my $reads = 0;
    if ($fields[0] =~ m/(contig)_(\d*)/)
        {
            my $contig = $1 . " " . $2;
            my $reads = $hash_table{$contig};
            print OUTPUT "$fields[0]", "\t", "$reads", "\t";
            for (my $i = 1; $i <= $#fields; $i++)
            {
                print OUTPUT "$fields[$i]", "\t";
            }
            print OUTPUT "\n";
            $cogs_count++;
        }
}

print "Output file, $output_file, created with $cogs_count entries...........\n";

close READS;
close COGS;
close OUTPUT;

print "\nProgram Complete ..............\n";
