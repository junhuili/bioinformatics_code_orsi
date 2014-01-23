#!/usr/bin/perl -w
#This script will count the number of reads mapping to functional categories (e.g. COGs) that were assigned to different taxa.  The input for this script is the output from the add_reads_nos_taxonomy_v3.pl script.

use strict;

####################################################
#
#  Declare global variables
#
#####################################################

my $input_file = "";            #supplied by arguments
my $output_file = "";
my $COG_category = "";

my $total_reads = 0;            # total of reads in entire input file

my %COG_hash;                   # has table data structure to store reads counts

my $name_trigger = 0;           # COG category name


####################################################
#
#  Process Arguments
#     -i input file name
#     -cog COG category to select (e.g. A)
#     -o output file anme
#
#####################################################


for (my $argument = 0; $argument <= $#ARGV; $argument++)
{
    if ($ARGV[$argument] eq "-i")
    {
        $input_file = $ARGV[$argument + 1];
    }
    
    if ($ARGV[$argument] eq "-o")
    {
        $output_file = $ARGV[$argument + 1];
    }
    
    if ($ARGV[$argument] eq "-cog")
    {
        $COG_category = $ARGV[$argument + 1];
    }
    
}

####################################################
#
#  Open input and output files; test for line feed character
#
#####################################################


open (INPUT, $input_file) or die "Unable to open input file, $input_file";
open (OUT, ">$output_file") or die "Unable to open output file, $output_file";

while ( <INPUT> )
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


close INPUT;
open (INPUT, $input_file) or die "Unable to open input file, $input_file";

####################################################
#
#  Process input file; Store read count in hash table with taxa as keys
#  $name_trigger = COG categpry name
#  Proteobacteria taxa are given prefix of "Proteo" in order that they
#        printed together in the "P" section
#  If taxonomy field is blank given taxa name "no taxonomy"
#
#####################################################


while ( <INPUT> )
{
    my $line = $_;
    chomp $line;
    
    my @fields = split (/\t/, $line);
    
    my $reads_count = "0";
    
    
    if ($fields[1] =~ m{\d+})
    {
        $reads_count = $fields[1];
    }
    
    if ($fields[12] eq $COG_category)
    {
        if ($name_trigger eq "0")
        {
            $name_trigger = $fields[13];
        }
        
        my $taxon = $fields[14];
        
        unless ( $taxon )
        {
            $taxon = "no taxonomy";
        }
        
        if ($taxon eq "Proteobacteria")
        {
            $taxon = "Proteo" . $fields[15];
        }
        
        if ( $COG_hash{$taxon} )
        {
            $COG_hash{$taxon} += $reads_count;
        }
        else
        {
            $COG_hash{$taxon} = $reads_count;
        }
    }
    
    $total_reads += $reads_count;
    
}


####################################################
#
#  Create csv output file including a headings line
#  Rows are sorted alphabetically by taon name except
#     that proteoacteria are printed togetehr under "P"
#
#####################################################



print OUT "$name_trigger", ",", "Annotated Reads", ",", "Percent of Total Annotated Reads", ",",
          "Total Annotated Reads", "\n";


foreach my $key ( sort keys %COG_hash )
{    
    my $percent = $COG_hash{$key} / $total_reads;
    
    my $name;
    
    if ( $key =~ m/Proteo(.*)/ )
    {
        $name = $1;
    }
    else
    {
        $name = $key;     
    }
    
    print OUT "$name", ",", "$COG_hash{$key}", ",", "$percent", ",", "$total_reads" ,"\n"; 
}



