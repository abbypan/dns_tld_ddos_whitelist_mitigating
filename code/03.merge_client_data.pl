#!/usr/bin/perl
use SimpleR::Reshape;
use Data::Dumper;
$|=1;

#client, qtype, sec_dom_cnt
my $src = 'client_qtype/client_A_secdom.csv';
my $dst_file=$src;
$dst_file =~s/.csv$/.merge.csv/; 
#system(qq[perl add_ip_info.pl -f $dst_file -i 0 -d $dst_file.loc.csv]);
#exit;

print "read client qtype\n";
my %see_client;
my $client_qtype_r = read_table($src, conv_sub => sub {
        my ($r)= @_;
        $see_client{$r->[0]} = 1;
        return $r;
    });

print "read good_rank_1000.txt\n";
#client,all_qcnt,good_qcnt,good_rate
my $rank = 'good_rank_1000.txt';
my %client_secdom_rank;
read_table($rank,
    return_arrayref=>0,
    conv_sub => sub {
        my ($r) = @_;
        next unless($see_client{$r->[0]});
        $client_secdom_rank{$r->[0]} = [ $r->[1], $r->[3] ];
    },
);

print "read big\n";
my $big_f = 'big_back/big_back.txt';
my $big_bb = read_table("$big_f.back_c.back_cnt.csv");
my %big_bb_h = map { $_->[0] => $_->[1] } @$big_bb;
my $big_bf = read_table("$big_f.back_c.front_cnt.csv");
my %big_bf_h = map { $_->[0] => $_->[1] } @$big_bf;
my $big_fb = read_table("$big_f.front_c.back_cnt.csv");
my %big_fb_h = map { $_->[0] => $_->[1] } @$big_fb;
my $big_ff = read_table("$big_f.front_c.front_cnt.csv");
my %big_ff_h = map { $_->[0] => $_->[1] } @$big_ff;

print "read mr\n";
my $mr_f = 'mr_back/mr_back.txt';
my $mr_bb = read_table("$mr_f.back_c.back_cnt.csv");
my %mr_bb_h = map { $_->[0] => $_->[1] } @$mr_bb;
my $mr_bf = read_table("$mr_f.back_c.front_cnt.csv");
my %mr_bf_h = map { $_->[0] => $_->[1] } @$mr_bf;
my $mr_fb = read_table("$mr_f.front_c.back_cnt.csv");
my %mr_fb_h = map { $_->[0] => $_->[1] } @$mr_fb;
my $mr_ff = read_table("$mr_f.front_c.front_cnt.csv");
my %mr_ff_h = map { $_->[0] => $_->[1] } @$mr_ff;

print "read big_rec\n";
my $brec_f = 'big_rec/big_rec.txt';
my $brec_bb = read_table("$brec_f.back_c.back_cnt.csv");
my %brec_bb_h = map { $_->[0] => $_->[1] } @$brec_bb;
my $brec_bf = read_table("$brec_f.back_c.front_cnt.csv");
my %brec_bf_h = map { $_->[0] => $_->[1] } @$brec_bf;
my $brec_fb = read_table("$brec_f.front_c.back_cnt.csv");
my %brec_fb_h = map { $_->[0] => $_->[1] } @$brec_fb;
my $brec_ff = read_table("$brec_f.front_c.front_cnt.csv");
my %brec_ff_h = map { $_->[0] => $_->[1] } @$brec_ff;

print "read dom client\n";
#client, client_c, no_dnssec_cnt, dnssec_cnt
my $q360 = read_table("360.cn/360.cn.A.csv.check.csv");
my %q360_h = map { $_->[0] => $_ } @$q360;
my $qsina = read_table("sina.com.cn/sina.com.cn.A.csv.check.csv");
my %qsina_h = map { $_->[0] => $_ } @$qsina;
my $qtianya = read_table("tianya.cn/tianya.cn.A.csv.check.csv");
my %qtianya_h = map { $_->[0] => $_ } @$qtianya;


print "merge\n";
open my $fh, '>', $dst_file;
print $fh "client,qtype,sec_dom_cnt,big_bb,big_bf,big_fb,big_ff,mr_bb,mr_bf,mr_fb,mr_ff,brec_bb,brec_bf,brec_fb,brec_ff,q360_n_dnssec,q360_dnssec,q360,qsina_n_dnsssec,qsina_dnssec,qsina,qtianya_n_dnssec,qtianya_dnssec,qtianya,qcnt,good_qcnt_rate,log10_sec_dom_cnt,log10_qcnt\n";
my $null_x = [];
for my $x (@$client_qtype_r){
    my ($client, $qtype, $sec_dom_cnt) = @$x;
    my $client_c = $client;
    $client_c=~s/\.\d+$//;

    push @$x, $big_bb_h{$client_c} || 0; 
    push @$x, $big_bf_h{$client_c} || 0; 
    push @$x, $big_fb_h{$client_c} || 0; 
    push @$x, $big_ff_h{$client_c} || 0; 

    push @$x, $mr_bb_h{$client_c} || 0; 
    push @$x, $mr_bf_h{$client_c} || 0; 
    push @$x, $mr_fb_h{$client_c} || 0; 
    push @$x, $mr_ff_h{$client_c} || 0; 

    push @$x, $brec_bb_h{$client_c} || 0; 
    push @$x, $brec_bf_h{$client_c} || 0; 
    push @$x, $brec_fb_h{$client_c} || 0; 
    push @$x, $brec_ff_h{$client_c} || 0; 

    push @$x, $q360_h{$client} ? @{$q360_h{$client}}[2, 3, 4] : ( 0, 0, 0 );
    push @$x, $qsina_h{$client} ? @{$qsina_h{$client}}[2, 3, 4] : ( 0, 0,0 );
    push @$x, $qtianya_h{$client} ? @{$qtianya_h{$client}}[2, 3, 4] : ( 0, 0, 0 );

    my $rank_r = $client_secdom_rank{$client};
    push @$x, $rank_r->[0] || 0; 
    push @$x, $rank_r->[1] || 0; 

    push @$x, $sec_dom_cnt ? log($sec_dom_cnt)/log(10) : 0;
    push @$x, $rank_r->[0] ? log($rank_r->[0])/log(10) : 0;

    s///g for @$x;
    print $fh join(",", @$x), "\n";

    $x=$null_x;
}
close $fh;

print "loc\n";
my $loc_file=$src;
$loc_file =~s/.csv$/.loc.csv/; 
system(qq[perl add_ip_info.pl -f $dst_file -i 0 -d $loc_file]);
