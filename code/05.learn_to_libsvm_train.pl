#!/usr/bin/perl

my ($f) = @ARGV;

open my $fh, '<', $f;
open my $fhw, '>', "$f.libsvm.train";

my $head = <$fh>;
#chomp($head);
#my @head_col = split /,/, $head;
#shift @head_col;
#print $fhw join(",", @head_col),"\n";

my $n=1;
my %mem_type;
while(<$fh>){
    chomp;
    my @data = split /,/;
    #shift @data;
    if(! exists $mem_type{$data[-1]}){
        $mem_type{$data[-1]}=$n;
        $n++;
    }
    my $dst_type = $mem_type{$data[-1]};
    pop @data;
    my @m = map { "$_:$data[$_]" } (1 .. $#data);
    print $fhw join(" ", $dst_type,@m),"\n";
}
close $fhw;
close $fh;

open my $fh, '>', "$f.libsvm.type";
print $fh "$_,$mem_type{$_}\n" for keys(%mem_type);
close $fh;
