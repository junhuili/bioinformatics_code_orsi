#!/usr/bin/perl -w
#This script will reformat a fasta file for submission to MG-RAST.  It is meant to be used for assembled contigs that have read mapping information associated.  The script adds the read mapping information from the output from CLC genomics workbench onto the header line in the contig fasta in the format compatible with MG-RAST.

use strict;



##     Input Files

my $reads_input = "min300_mapping_WS50.txt";
my $fasta_file = "min300_contigs_WS50.fa";


##     Output File

my $output_file = "min300_contigs_with_reads_WS50.fa";


##     Reads Hash Table

my %reads_hash;



##     Open Files

open (READS, $reads_input) or die "Unable to open input file $reads_input";
open (FASTA, $fasta_file) or die "Unable to open input file $fasta_file";

open (OUT, ">$output_file") or die "Unable to open output file $output_file";



##   Process reads file; create hash table containing nos. of reads


while ( <READS> )
{
    my $line = $_;
    
    if ($line =~ /\r/)
    {
        $/ = "\r";
    }
    
    elsif ($line =~ /\n/)
    {
        $/ = "\n";        
    }
    
    last;
}

close READS;
open (READS, $reads_input) or die "Unable to open reads input file, $reads_input";

my $reads_counter = 0;

while ( <READS> )
{
    my $line = $_;
    $line =~ s/\r//g;
    $line =~ s/\n//g;
    
    if ( $line =~ m/contig (\d+) mapping/ )
    {
        my $contig = "contig_" . "$1";
        my @fields = split(/\t/, $line);
        $reads_hash{$contig} = $fields[2];
        $reads_counter++;
    }
}

print "\n$reads_counter reads were processed and placed in internal hash table.\n";



#   Process fasta file; write a new fasta file containing reads data in proper format


while ( <FASTA> )
{
    my $line = $_;
    
    if ($line =~ /\r/)
    {
        $/ = "\r";
    }
    
    elsif ($line =~ /\n/)
    {
        $/ = "\n";        
    }
    
    last;
}

close FASTA;
open (FASTA, $fasta_file) or die "Unable to open reads input file, $fasta_file";

my $fasta_counter = 0;

while ( <FASTA> )
{
    my $line = $_;
    $line =~ s/\r//g;
    $line =~ s/\n//g;
    
    if ( $line =~ m/.*(contig_\d+)/ )
    {
        my $reads_data = $reads_hash{$1};
        my $formatted_reads = "_[cov=$reads_data]";
        print OUT "$line", "$formatted_reads", "\n";
        $fasta_counter++;
    }
    else
    {
        print OUT "$line\n";
    }
    
}

print "$fasta_counter FASTA sequences were processed with reads coverage added/\n"; 




