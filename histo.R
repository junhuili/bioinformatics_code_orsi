# Read values from tab-delimited autos.dat
histo <- read.table("/Users/williamorsi/Desktop/R_working_directory/histo_taxa_phymm.txt", header=T)

# Create a histogram for autos in light blue with the y axis
# ranging from 0-1000

barplot(histo$Value)
