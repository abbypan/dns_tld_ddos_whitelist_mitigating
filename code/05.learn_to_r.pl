#!/usr/bin/perl

my ($f) = @ARGV;

my $dst_f = $f;
$dst_f=~s/.csv$/.rdat/;

open my $fh, '<', $f;
open my $fhw, '>', $dst_f;

my $head = <$fh>;
chomp($head);
my @head_col = split /,/, $head;
shift @head_col;
print $fhw join(",", @head_col),"\n";

my $n=1;
my %mem_type;
while(<$fh>){
    chomp;
    my @data = split /,/;
    shift @data;
    if(! exists $mem_type{$data[-1]}){
        $mem_type{$data[-1]}=$n;
        $n++;
    }
    $data[-1] = $mem_type{$data[-1]};
    print $fhw join(",", @data),"\n";
}
close $fhw;
close $fh;

my $type_f = $f;
$type_f=~s/.csv$/.rtype/;
open my $fh, '>', $type_f;
print $fh "$_,$mem_type{$_}\n" for keys(%mem_type);
close $fh;
