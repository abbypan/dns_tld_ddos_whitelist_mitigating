#!/usr/bin/perl

my ($f) = @ARGV;

open my $fh, '<', $f;
open my $fhw, '>', "$f.libsvm.test";

my $head = <$fh>;
#chomp($head);
#my @head_col = split /,/, $head;
#shift @head_col;
#print $fhw join(",", @head_col),"\n";

my $dst_type = 0;
my $n=1;
my %mem_type;
while(<$fh>){
    chomp;
    my @data = split /,/;
    #shift @data;
    pop @data;
    my @m = map { "$_:$data[$_]" } (1 .. $#data);
    print $fhw join(" ", $dst_type,@m),"\n";
}
close $fhw;
close $fh;
