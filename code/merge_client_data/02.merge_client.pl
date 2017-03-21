#!/usr/bin/perl
use SimpleR::Reshape;
use SimpleR::Stat;
use Data::Dumper;

my %client;
my @hive_header = qw/query_cnt dom_cnt imp_qry_cnt imp_dom_cnt imp_qry_rate imp_dom_rate sina_com_cn weibo_cn 360_cn tianya_cn t_dom_rate entro_avg entro_avg_imp/;
read_row_csv( \%client ,'client_hive_final.csv', \@hive_header );
my @recur_header = qw/front_n important_front_n user_num c_front_n c_important_front_n c_user_num state prov isp/;
read_row_csv( \%client ,'client_recur_final.csv', \@recur_header );

open my $fh, '>', 'client_merge_final.csv';
my @final_header = ('client', @hive_header, @recur_header);
print $fh join( ",", @final_header), "\n";
while ( my ( $c, $r ) = each %client ) {
    $r->{client} = $c;
    $r->{$_} ||= 0 for @final_header;
    print $fh join( ",", @{$r}{@final_header}), "\n";
}

sub read_row_csv {
    my ( $dst_hash, $f, $header ) = @_;
    my $r = read_table(
        $f,
        sep             => ',',
        return_arrayref => 0,
        conv_sub        => sub {
            my ($rr) = @_;
            my ( $k, @d ) = @$rr;
            $dst_hash->{$k}{ $header->[$_] } = $d[$_] || 0
              for ( 0 .. $#$header );
        }
    );
}
