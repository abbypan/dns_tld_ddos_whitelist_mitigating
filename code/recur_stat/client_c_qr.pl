#!/usr/bin/perl
use SimpleR::Reshape;

my %rem;
read_table('client_qrcnt_domcnt.csv',
return_arrayref=>0,
conv_sub => sub {
	my ($r)=@_;
	$r->[0]=~s/\.\d+$/.0/g;
	$rem{$r->[0]}+=$r->[1];
},
);

open my $fh, '>', 'client_c_qrcnt.csv';
while(my ($k, $cnt) = each %rem){
print $fh "$k,$cnt\n";
}
close $fh;

system(qq[sort client_c_qrcnt.csv > client_c_qrcnt.sort.csv]);
