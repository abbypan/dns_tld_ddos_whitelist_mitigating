#!/usr/bin/perl
use SimpleR::Reshape;
my $from = 'recur_front_back.tidy.small.csv';
my $to = 'open_recur_front_back.no_211.98';
my $dst = 'fff_front_back.csv';

my %mem;
read_table('recur_front_table.csv',
return_array_ref=>0, 
	conv_sub => sub {
my ($r) = @_;
my $c = $r->[0];
$c=~s/\.\d+$/.0/;
$mem{$c} = 1;
});

read_table($from, 
		write_file=>$dst,
		return_arrayref=> 0,
		conv_sub => sub {
		my ($r) = @_;
		my ($f, $b) = ($r->[0], $r->[1]);
		$f=~s/\.\d+$/.0/;
		$b=~s/\.\d+$/.0/;
		return unless(exists $mem{$f} or exists $mem{$b});
		return $r;	
		});

system(qq[cat $dst $to |sort |uniq > $dst.temp]);
system(qq[mv $dst.temp $dst]);
