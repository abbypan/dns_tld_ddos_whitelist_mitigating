#!/usr/bin/perl
use Socket qw/inet_ntoa/;
use Data::Validate::IP qw/is_ipv6 is_public_ipv4/;


my ($f, $df) = @ARGV;
if(!$df) {
    $df=$f;
    $df=~s/bind_log/bind_log_tidy/;
}
print "$f -> $df\n";

open my $fh, '<', $f;
open my $fhw, '>', "$df.tmp";
while(<$fh>){
chomp;
my ($front, $back) = split ',';
next unless($back=~/\S/ and $front=~/\S/);
next unless(is_ipv6($back) or is_public_ipv4($back));
next unless(is_ipv6($front) or is_public_ipv4($front));
print $fhw "$front,$back\n";
}
close $fh;
close $fhw;

system(qq[cat $df.tmp | sort | uniq  > $df]);
unlink("$df.tmp");
