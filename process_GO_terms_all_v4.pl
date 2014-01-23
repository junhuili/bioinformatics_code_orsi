#!/usr/bin/perl -w
#Enables a search of any GO term and creates a new output file with the number of contigs with hits to that GO term, their read abundance, and taxonomy.  Input for this script is the output from add_read_nos_taxonomy_v3.pl
use strict;

my $reads_input;
my $HMM_input;
my $taxonomy;
my $HMM_output_file;
my $contig_stats_output;
my $test_expression = "-";
my $test = $#ARGV;

my @HMM_file;
my @reads_file;
my @taxon_file;

for (my $argument = 0; $argument <= $#ARGV; $argument++)
{
    if ($ARGV[$argument] eq "-t")
    {
        $HMM_input = $ARGV[$argument + 1];
    }
    
    if ($ARGV[$argument] eq "-m")
    {
        $reads_input = $ARGV[$argument + 1];
    }
    
    if($ARGV[$argument] eq "-tx")
    {
        $taxonomy = $ARGV[$argument + 1];
    }
    
    if ($ARGV[$argument] eq "-go")
    {
        $test_expression = $ARGV[$argument + 1];
    }
    
    if ($ARGV[$argument] eq "-o")
    {
        $HMM_output_file = $ARGV[$argument + 1];
    }
    
}

$contig_stats_output = "$HMM_input" . "_contig_stats";

my %reads_hash_table;
my $reads_hash_count = 0;

my @contig_array;

my %contigs_hash_table;
my $contigs_hash_count = 0;

open (READS, $reads_input) or die "Unable to open reads input file, $reads_input";
open (TAX, $taxonomy) or die "Unable to open taxonomy file, $taxonomy";
open (HMM, $HMM_input) or die "Unable to open cogs input file, $HMM_input";

open (OUT1, ">$HMM_output_file") or die "Unable to open output file, $HMM_output_file";
open (OUT2, ">$contig_stats_output") or die "Unable to open output file, $contig_stats_output";

print "Input and Output Files were successfully opened ......\n";

################################################################
#
#    Create Hash Table of Contigs ----> Reads
#
#################################################################


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


while ( <READS> )
{
    my $line = $_;
    $line =~ s/\r//g;
    $line =~ s/\n//g;
    
    push (@reads_file, $line);
}


for (my $i = 0; $i <= $#reads_file; $i++)
{   
    my @fields = split (/\t/, $reads_file[$i]);
    if ($fields[0] =~ m/(contig \d*) mapping/)
    {
        $reads_hash_table{$1} = $fields[2];
        $reads_hash_count++;
    }
}

print "Hash-table of $reads_hash_count reads created .......\n";

close READS;

#################################################################
#
# Create taxonomy hash table
#
#
#################################################################

while ( <TAX> )
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

close TAX;

open (TAX, $taxonomy) or die "Unable to open taxonomy file, $taxonomy";

my %tax_hash;
my $tax_count = 0;

while ( <TAX> )
{
    my $line = $_;
    $line =~ s/\r//g;
    $line =~ s/\n//g;
    
    push (@taxon_file, $line);
}


for (my $i = 0; $i <= $#taxon_file; $i++)
{            
    my @fields = split (/\t/, $taxon_file[$i]);
    if ($fields[0] =~ m/(contig_\d*)/)
    {
        my $list = "";
        for (my $i = 1; $i <= $#fields; $i++)
        {
            $list = $list . $fields[$i] . ";"
        }
        
        $tax_hash{$1} = $list;
        $tax_count++;
    }
}

print "Hash-table of $tax_count taxonomy records created .......\n";
close TAX;


##################################################################
#
#   Process HMM and TAX files; place in array
#
##################################################################

while ( <HMM> )
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


close HMM;

open (HMM, $HMM_input) or die "Unable to open cogs input file, $HMM_input";

my $counter = 0;
my $current_go_term = "";
my $contig = "";

while ( <HMM> )
{
    my $line = $_;
    $line =~ s/\r//g;
    $line =~ s/\n//g;
    
    push (@HMM_file, $line);
}

for (my $i = 0; $i <= $#HMM_file; $i++)
{            
    my @fields = split (/\t/, $HMM_file[$i]);
    my $name = $fields[0];
    my $go_term = $fields[5];
    
    unless ( $name )
    {
        next;
    }
    
        
    if ( $name =~ m/(contig)_(\d*)/)
    {
        $contig = $1 . "_" . $2;
        my $contig_2 = $1 . " " . $2;
        $contig_array[$counter][0] = $contig;
        $contig_array[$counter][1] = $name;
        $contig_array[$counter][2] = $go_term;
        $contig_array[$counter][3] = $reads_hash_table{$contig_2};
        if ($tax_hash{$contig})
        {
            $contig_array[$counter][4] = $tax_hash{$contig};
        }
        else
        {
            $contig_array[$counter][4] = " - ";
        }    
        
        $counter++;
    }
    
}

close HMM;


##################################################################
#
#   Create sorted version of array to count go_terms per contig
#
##################################################################



my @sorted_array = sort {$a->[0] cmp $b->[0]} @contig_array;


my $first_one = 0;
my $go_counter = 0;
my $total_go_counter = 0;
my $i = 0;

print OUT2 "Contig\tNo of Go Terms\n";

for ($i = 0; $i <= $#sorted_array; $i++)
{
    if ($first_one == 0)
    {
        $go_counter++;
        $total_go_counter++;
        $first_one = 1;
    }
    elsif ($sorted_array[$i][0] eq $sorted_array[$i - 1][0])
    {
        $go_counter++;
        $total_go_counter++;
    }
    else
    {
        print OUT2 ("$sorted_array[$i - 1][0]", "\t", "$go_counter", "\n");
        $go_counter = 1;
        $total_go_counter++;
    }
}

print OUT2 ("$sorted_array[$i - 1][0]", "\t", "$go_counter", "\n");
print OUT2 ("\nTotal", "\t", "$total_go_counter", "\n");
print "Total GO Terms of $total_go_counter counted by contig.........\n";

#################################################################
#
#   Create sorted version of array to exclude duplicated contigs in any go_term
#
##################################################################

my @sorted_array_2 = sort {$a->[2] cmp $b->[2]} @sorted_array;;

my $counter_1 = 0;
my $counter_2 = 0;
$first_one = 0;

for (my $i = 0; $i <= $#sorted_array_2; $i++)
{
    unless ($test_expression eq "-")
    {
        unless ($sorted_array_2[$i][2] =~ m/($test_expression)/i)
        {
            next;  
        }
    }
    
    $counter_1++;
    if ($first_one == 0)
    {
        print OUT1 "$sorted_array_2[$i][0]", ",", "$sorted_array_2[$i][1]", ",",
                   "$sorted_array_2[$i][2]", ",", "$sorted_array_2[$i][3]", ",";
        my @taxa = split (/;/, $sorted_array_2[$i][4]);
        for (my $j = 0; $j < 4; $j++)
        {
            if ($taxa[$j])
            {
                print OUT1 "$taxa[$j]", ",";
            }
        }
        print OUT1 "\n";
        $first_one = 1;
        $counter_2++
    }
    elsif ($sorted_array_2[$i][2] eq $sorted_array_2[$i - 1][2] )
    {
        if ($sorted_array_2[$i][0] eq $sorted_array_2[$i - 1][0])
            { }
        else
        {
            print OUT1 "$sorted_array_2[$i][0]", ",", "$sorted_array_2[$i][1]", ",",
                       "$sorted_array_2[$i][2]", ",", "$sorted_array_2[$i][3]", ",";
            my @taxa = split (/;/, $sorted_array_2[$i][4]);
            for (my $j = 0; $j < 4; $j++)
            {
                if ($taxa[$j])
                {
                    print OUT1 "$taxa[$j]", ",";
                }
            }
            print OUT1 "\n";
            $counter_2++;
        }
    }
    else
    {
        print OUT1 "$sorted_array_2[$i][0]", ",", "$sorted_array_2[$i][1]", ",",
                   "$sorted_array_2[$i][2]", ",", "$sorted_array_2[$i][3]", ",";
        my @taxa = split (/;/, $sorted_array_2[$i][4]);
        for (my $j = 0; $j < 4; $j++)
        {
            if ($taxa[$j])
            {
                print OUT1 "$taxa[$j]", ",";
            }
        }
        print OUT1 "\n";
        $counter_2++;
    }
}

my $net = $counter_1 - $counter_2;

print "Total contigs processed were $counter_1. ", "Duplicates removed were $net.........\n";




