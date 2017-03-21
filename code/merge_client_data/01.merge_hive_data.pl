#!/usr/bin/perl
use SimpleR::Reshape;
use SimpleR::Stat;
use Data::Dumper;

my %main;
read_main_csv( \%main, 'main_imp_domcnt_qrcnt.csv',
    [qw/imp_dom_cnt imp_qry_cnt/] );
read_main_csv( \%main, 'main_qrcnt_domcnt.csv', [qw/query_cnt dom_cnt/] );

my %client;
read_spec_dom_csv( \%client, 'client_specdom_qrcnt.csv' );
read_row_csv( \%client, 'client_qrcnt_domcnt.csv', [qw/query_cnt dom_cnt/] );
read_row_csv( \%client, 'client_entro.csv', [qw/entro_sum entro_qry_cnt/] );
read_row_csv(
    \%client,
    'client_impqrcnt_impdomcnt_qrcnt_domcnt_impqrrate_impdomrate.csv',
    [qw/ imp_qry_cnt  imp_dom_cnt  qry_cnt d_cnt imp_qry_rate imp_dom_rate /]
);

#qry_cnt d_cnt entro_sum entro_qry_cnt  
my @final_header =
  qw/query_cnt dom_cnt imp_qry_cnt imp_dom_cnt imp_qry_rate imp_dom_rate sina_com_cn weibo_cn 360_cn tianya_cn/;
open my $fh, '>', 'client_hive_final.csv';
print $fh join( ",",
    'client', @final_header, 
    #'t_imp_dom_rate', 
    't_dom_rate', 
    'entro_avg', 'entro_avg_imp' ),
  "\n";
while ( my ( $c, $r ) = each %client ) {
    $r->{$_} ||= 0 for @final_header;
    $r->{t_imp_dom_rate} = calc_rate( $r->{imp_dom_cnt}, $main{imp_dom_cnt} );
    $r->{t_dom_rate}     = calc_rate( $r->{dom_cnt},     $main{dom_cnt} );
    $r->{entro_avg}      = calc_rate( $r->{entro_sum},   $r->{query_cnt} );
    $r->{entro_avg_imp}  = calc_rate( $r->{entro_sum},   $r->{entro_qry_cnt} );
    print $fh join( ",",
        $c,
        @{$r}{@final_header},
        @{$r}{qw/t_imp_dom_rate t_dom_rate entro_avg entro_avg_imp/} ),
      "\n";
}

#print Dumper(\%main, \%client);

sub read_main_csv {
    my ( $dst_hash, $f, $header ) = @_;
    my $r = read_table(
        $f,
        sep             => ',',
        return_arrayref => 0,
        conv_sub        => sub {
            my ($rr) = @_;
            $dst_hash->{ $header->[$_] } = $rr->[$_] || 0
              for ( 0 .. $#$header );
        }
    );
}

sub read_spec_dom_csv {
    my ( $dst_hash, $f ) = @_;
    my $r = read_table(
        $f,
        sep             => ',',
        return_arrayref => 0,
        conv_sub        => sub {
            my ($rr) = @_;
            my ( $k, $dom, $cnt ) = @$rr;
            $dst_hash->{$k}{$dom} = $cnt || 0;
        }
    );

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
