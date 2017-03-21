#!/usr/bin/perl
use strict;
use warnings;

use SimpleR::Reshape;
use List::AllUtils qw/mesh max min/;

use SimpleCall::ChartDirector;
use Data::Validate::IP qw/is_public_ipv6 is_public_ipv4/;

use utf8;


our @HEAD = qw/
  client query_cnt dom_cnt imp_qry_cnt imp_dom_cnt imp_qry_rate imp_dom_rate sina_com_cn weibo_cn 360_cn tianya_cn t_dom_rate entro_avg entro_avg_imp front_n important_front_n user_num c_front_n c_important_front_n c_user_num 
  /;


my ($src)     = @ARGV;
$src ||= 'client_merge_test.csv';

my $learn_f = $src;
$learn_f =~ s/csv$/learn.csv/;

our %important_front_client;
read_table(
    'bind_client_id.log.back.important_front.csv',
    return_arrayref => 0,
    conv_sub        => sub {
        my ($r) = @_;
        my $c = $r->[0];
        $c =~ s#\.\d+$#.0#;
        $important_front_client{$c} = 1;
    },
);

my %rem_type;

read_table(
    $src,
    write_file => $learn_f,
    skip_head  => 1,
    write_head => [ 'type', @HEAD[0 .. 19 ], 'spec_dom_type' ],
    conv_sub   => sub {
        my ($r) = @_;
        pop @$r; #isp
        pop @$r; #prov
        pop @$r; #state

        return unless ( $r->[1] =~ /^\d+$/ );
        $_=~s/NULL// for @$r;
        $r->[$_] ||= 0  for( 1 .. $#$r);

        my $type = check_type($r);
        $rem_type{$type} += $r->[1];

        #return if($type ne 'other');
        #$r->[5]=sprintf("%f", $r->[5]);
        #$r->[6]=sprintf("%f", $r->[6]);
        for ( 7 , 8, 9, 10){
            $r->[$_] = $r->[$_]>0 ? log($r->[$_])/log(100) : 0 ;
        };

        for ( 2 .. $#$r ) {
            next unless ( $r->[$_] =~ /e/i or $r->[$_]=~/\./ );
            #print "src $r->[$_]\n";
            $r->[$_] = sprintf( "%.8f", $r->[$_] );
            #print "dst $r->[$_]\n";
        }

        my $ss = check_special_dom($r);
        push @$r, $ss;
        #($r->[-4], $r->[-1]) = ($r->[-1], $r->[-4]);
        unshift @$r, $type || 'other';
        #return if($r->[0] eq 'other');
        return $r;
    },
    charset => 'utf8',

    #charset => 'cp936',
    return_arrayref => 0,
);

use Encode;
open my $fh,  '<:utf8', $learn_f;
open my $fhw, '>',      "$learn_f.cp936.csv";
while (<$fh>) {
    print $fhw encode( "cp936", $_ );
}
close $fhw;
close $fh;

my @rem_type =
  sort { $b->[1] <=> $a->[1] } map { [ $_, $rem_type{$_} ] } keys(%rem_type);


chart_pie(
    [ map { $_->[1] } @rem_type ],
    file            => 'manual_check.png',
    title           => '> 10000 per day ',
    label           => [ map { $_->[0] } @rem_type ],
    width           => 900,
    height          => 600,
    pie_size        => [ 400, 290, 180 ],
    title_font_size => 12,

    #color => [ qw/Yellow Green Red1/ ],

    #图例
    with_legend        => 1,
    legend_pos_x       => 265,
    legend_pos_y       => 55,
    legend_is_vertical => 0,

    #旋转角度
    start_angle => 30,

    #饼图各部分的标签
    label_format => "{label}\n{value}, {percent}%",
    label_pos    => 20,

    #拉出一条线指向一块饼
    label_side_layout => 1,
);

sub check_special_dom {
    my ($r) = @_;
    my %d = mesh @HEAD, @$r;
    my $min = min(@d{qw/sina_com_cn 360_cn tianya_cn/});
    my $max = max(@d{qw/sina_com_cn 360_cn tianya_cn/});


    # 频繁请求的逗比
    return 1 if(
        $d{sina_com_cn}> $d{'360_cn'} 
        and $d{sina_com_cn}>$d{weibo_cn}
        and $d{'360_cn'} > 10*$d{tianya_cn}
        and $d{tianya_cn}> 50
    );
    
    # 不算太频繁的逗比
    return 2 if(
        $d{sina_com_cn}> $d{'360_cn'} 
        and $d{'360_cn'} > $d{tianya_cn}
        and $d{tianya_cn}> 500
        and $d{sina_com_cn}>$d{weibo_cn}
    );

    #不用360的好孩子
    return 3 if(
        $d{sina_com_cn}> $d{tianya_cn} 
        and $d{tianya_cn}> 100
        and $d{'360_cn'}==0
    );

    return 4 if(
        $d{'360_cn'}>$d{sina_com_cn}
        and $d{sina_com_cn}>$d{tianya_cn}
        and $d{'360_cn'}>10000
        and $d{sina_com_cn}>1000
    );

    return 5 if(
        $d{'360_cn'}>$d{tianya_cn}
        and $d{tianya_cn}>$d{sina_com_cn}
        and $d{sina_com_cn}>0
        and $max<600
    );


    #都很小
    return 6 if($max<10);

    #比较平均
    return 7 if($min>1000 and $max<3000);

    # read into 2-level domain ns recur

    return 0;
}

sub check_type {
    my ($r) = @_;
    my %d = mesh @HEAD, @$r;

    ## {{ manual check
    return 'not_public_ip'
      unless ( is_public_ipv4( $d{client} ) 
              or is_public_ipv6( $d{client} ) );
    return 'recur_public' if ( $d{client} =~ /^\Q208.67.219./ );    #opendns
    return 'recur_public'
      if (
           $d{client} =~ /^74\.125\.1[6-9]\./
        or $d{client} =~ /^74\.125\.4[6-7]\./
        or $d{client} =~ /^74\.125\.7[2-8]\./
        or $d{client} =~ /^74\.125\.80\./
        or $d{client} =~ /^74\.125\.11[3-4]\./
        or $d{client} =~ /^74\.125\.17[6-8]\./
        or $d{client} =~ /^74\.125\.18[0-7]\./
        or $d{client} =~ /^74\.125\.190\./
        or $d{client} =~ /^173\.194\.89\./
        or $d{client} =~ /^173\.194\.9[0-9]\./
        or $d{client} =~ /^2a00:1450:4010:c0/
      );    #google open dns
    return 'recur_public' if ( $d{client} =~ /\Q183.61.13./ );    #ali dns
    return 'service_spider' if ( $d{client} =~ /^\Q180.76.15./ );  #baidu spider
    return 'service_spider' if ( $d{client} =~ /^\Q178.255.215./ );    #exabot
    return 'service_spider'
      if ( $d{client} =~ /^\Q66.249.66./
        or $d{client} =~ /^\Q66.249.70./ );    #google spider
    return 'service_spider'
      if ( $d{client} =~ /^66\.249\.7[346]\./ );    #google spider
    return 'service_spider'
      if ( $d{client} =~ /^\Q220.181.108./ );       #baidu spider
    return 'service_spider' if ( $d{client} =~ /\Q67.195.93./ );   #yahoo spider
    return 'service_spider'
      if ( $d{client} =~ /^\Q188.165.15./ );    #seek.fr spider
    return 'service_spider' if ( $d{client} =~ /^\Q123.125.71./ ); #baidu spider
    return 'service_spider'
      if ( $d{client} =~ /^\Q84.201.146./
        or $d{client} =~ /^\Q141.8.185./
        or $d{client} =~ /^\Q2a02:6b8:0:c47::54c9:/ );    #yandex spider

    return 'service_spider'
      if ( $d{client} =~ /^101\.226\.16\d\./ );           #360 spider
    return 'service_spider'
      if ( $d{client} =~ /^182\.118\.[23]\d\./ );         #360 spider
    return 'service_spider' if ( $d{client} =~ /^\Q61.55.185./ );   #360 spider
    return 'service_spider' if ( $d{client} =~ /^\Q182.136.133./ ); #360 spider
    return 'service_spider' if ( $d{client} =~ /^\Q180.153.229./ ); #360 spider
    return 'service_spider' if ( $d{client} =~ /^\Q180.153.236./ ); #360 spider
    return 'service_spider' if ( $d{client} =~ /^\Q65.55.37./ );    #bing spider
    return 'service_spider'
      if ( $d{client} =~ /^\Q207.102.138./ )
      ;    # Fortinet Technologies (Canada)  security test
    return 'service_spider' if ( $d{client} =~ /^\Q141.8.189./ );   # yandex.net
    return 'service_spider' if ( $d{client} =~ /^\Q61.135.150.177/ );    # sohu

    return 'recur_public' if ( $d{client} =~ /\Q199.66.200./ );     #comodo dns
    return 'recur' if ( $d{client} =~ /\Q106.120.151./ );    #chinamobile bj
    return 'recur' if ( $d{client} =~ /\Q42.120.220./ );     #ali yun

    return 'recur' if($d{client}=~/\Q222.217.39./ ); # guang xi tel dns

    my $c = $d{client};
    $c =~ s/\.\d+$/.0/;
    return 'recur' if ( exists $important_front_client{$c} );

    #return 'service_cloud' if ( $d{client} =~ /\Q91.236.239./ );    #firstheberg.com
    #return 'service_cloud' if ( $d{client} =~ /\Q82.165.226./ );    # 1and1
    #return 'service_cloud' if ( $d{client} =~ /\Q208.115.113./ or $d{client} =~ /\Q208.115.111./ ) ;#wowrack
    #return 'service_cloud' if ( $d{client} =~ /^\Q62.141.32.4/ ); 
    #return 'service_cloud' if ( $d{client} =~ /^\Q178.33.222./ );    #ovh
    #return 'service_cloud' if ( $d{client} =~ /^\Q94.23.19./ );      #didici.be
    #return 'service_cloud' if ( $d{client} =~ /^\Q67.210.234./ or $d{client} =~ /^\Q66.128.50./ );    # gipnetwork
    #return 'service_cloud' if ( $d{client} =~ /^\Q115.160.187./ );    # idc

    return 'service' if ( $d{client} =~ /^\Q180.149.156./ );          # bj tel
    return 'service' if ( $d{client} =~ /\Q15.203.224./ or $d{client} =~ /\Q15.211.192./ ) ;    #hp.com, large query
    return 'service' if ( $d{client} =~ /\Q94.100.181./ );   # mail service
    return 'service' if ( $d{client} =~ /\Q180.137.252./ );    # maybe 网吧
    return 'service' if ( $d{client} =~ /\Q222.217.39./ );     # maybe 网吧
    return 'service' if ( $d{client} =~ /\Q219.132.242./ );    # maybe 网吧
    return 'service' if ( $d{client} =~ /\Q42.156.207./ );     # 阿里 hichina
    return 'service' if ( $d{client} =~ /\Q151.80.31./ );    # ahrefs.com seo service
    return 'service' if ( $d{client} =~ /\Q94.228.34./ );    #truedns.co.uk
    return 'service' if ( $d{client} =~ /\Q211.99.227./ );   # cnnic service
    return 'service' if ( $d{client} =~ /\Q208.80.194./ );   # web sense

    return 'service' if ( $d{client} =~ /\Q199.30.228./ );   # domaintools
    return 'service'
      if ( $d{client} =~ /\Q125.96.160./ );    # fibrlink mail service
    return 'service'
      if ( $d{client} =~ /\Q94.245.112./
        or $d{client} =~ /\Q157.56.156./
        or $d{client} =~ /\Q65.55.81./
        or $d{client} =~ /\Q134.170.65./ );    # msnhst

    return 'recur' if ( $d{user_num} > 100000 );      #many user
    return 'recur' if ( $d{c_user_num} > 500000 );    #many user
    return 'recur' if ( $d{front_n} > 1000 );         #many front
    return 'recur' if ( $d{c_front_n} > 2000 );       #many front
    ## }}
    ## {{
    return 'recur' if ( $d{user_num} > 30000 or $d{front_n} > 500 );    #user
    return 'recur'
      if ( $d{imp_dom_cnt} > 10000 or $d{front_n} > 100 );    #dom cover
    return 'recur'
      if (  $d{front_n} > 20
        and $d{imp_dom_cnt} > 8000
        and $d{imp_qry_rate} > 0.9
        and $d{imp_dom_rate} > 0.8 );                         #small recur
    return 'recur'
      if (  $d{front_n} > 20
        and $d{imp_dom_cnt} > 50000
        and $d{imp_qry_rate} > 0.2
        and $d{query_cnt} > 500000
        and $d{sina_com_cn} > 10
        and $d{"360_cn"} > 10
        and $d{tianya_cn} > 10 );

    return 'recur'
      if (  $d{c_front_n} > 1000
        and $d{imp_dom_cnt} > 1000
        and $d{imp_dom_rate} > 0.4
        and $d{imp_qry_rate} > 0.6 );    #many front

    return 'maybe_recur'
      if (
            $d{front_n} > 0
        and $d{imp_dom_cnt} > 1000
        and $d{imp_dom_rate} > 0.5
        and $d{imp_qry_rate} > 0.75
        and $d{query_cnt} < 200000
        and (
            (
                    $d{sina_com_cn} > $d{tianya_cn}
                and $d{sina_com_cn} > $d{"360_cn"}
            )
            or
            ( $d{"360_cn"} > $d{tianya_cn} and $d{"360_cn"} > $d{sina_com_cn} )
        )
        and $d{tianya_cn} > 0

        #and $d{weibo_cn}> 0
        and $d{"360_cn"} > 0
      );
    return 'maybe_recur'
      if (  $d{query_cnt} < 150000
        and $d{imp_dom_cnt} > 3000
        and $d{c_front_n} > 0
        and $d{imp_dom_rate} > 0.45
        and $d{imp_qry_rate} > 0.7 );

    return 'maybe_recur'
      if (  $d{query_cnt} < 50000
        and $d{imp_dom_cnt} > 3000
        and $d{c_front_n} > 0
        and $d{imp_dom_rate} > 0.5
        and $d{imp_qry_rate} > 0.7 );

    return 'maybe_recur'
      if (
            $d{front_n} > 0
        and $d{query_cnt} < 50000
        and $d{imp_dom_cnt} > 1000
        and $d{imp_qry_rate} > 0.3
        and $d{imp_dom_rate} > 0.2
        and (  $d{'360_cn'} > 0
            or $d{tianya_cn} > 0
            or $d{sina_com_cn} > 0 )
      );

    return 'maybe_recur'
      if (
            $d{c_front_n} > 0
        and $d{query_cnt} < 50000
        and $d{imp_dom_cnt} > 1000
        and $d{imp_qry_rate} > 0.6
        and $d{imp_dom_rate} > 0.4
        and (  $d{'360_cn'} > 0
            or $d{tianya_cn} > 0
            or $d{sina_com_cn} > 0 )
      );

    return 'maybe_recur'
      if (  $d{front_n} > 0
        and $d{query_cnt} > 1000000
        and $d{imp_qry_rate} > 0.85
        and $d{'360_cn'} > $d{tianya_cn}
        and $d{tianya_cn} > $d{sina_com_cn}
        and $d{sina_com_cn} > $d{weibo_cn} );

    return 'recur'
      if (  $d{front_n} > 100
        and $d{query_cnt} > 30000
        and $d{imp_qry_rate} > 0.4 );

    return 'recur'
      if (
            $d{front_n} > 10
        and $d{imp_dom_cnt} > 1000
        and $d{imp_qry_rate} > 0.8
        and (
            (
                    $d{sina_com_cn} > $d{tianya_cn}
                and $d{sina_com_cn} > $d{"360_cn"}
            )
            or
            ( $d{"360_cn"} > $d{tianya_cn} and $d{"360_cn"} > $d{sina_com_cn} )
        )

        and $d{tianya_cn} > 0

        #and $d{weibo_cn}> 0
        and $d{"360_cn"} > 0

      );

    return 'recur'
      if (  $d{query_cnt} > 10000
        and $d{imp_qry_rate} > 0.6
        and $d{imp_dom_cnt} > 1000
        and $d{imp_dom_rate} > 0.5
        and $d{front_n} > 10 );

    return 'maybe_recur'
      if (  $d{query_cnt} < 300000
        and $d{front_n} > 0
        and $d{imp_dom_cnt} > 5000 );

    return 'maybe_service_spider'
      if (  $d{query_cnt} > 3000000
        and $d{dom_cnt} > 200000
        and $d{imp_dom_cnt} > 10000
        and $d{imp_qry_rate} < 0.1
        and $d{important_front_n} == 0
        and $d{c_important_front_n} == 0 );

    return 'maybe_evil'
      if (  $d{query_cnt} > 100000
        and ( $d{dom_cnt} / $d{query_cnt} > 0.85 )
        and $d{imp_dom_cnt} < 1000 );

    return 'maybe_recur'
      if (
            $d{query_cnt} < 100000
        and $d{front_n} > 0
        and (  ( $d{dom_cnt} > 10000 and $d{imp_dom_cnt} > 5000 )
            or ( $d{imp_qry_rate} > 0.6 and $d{imp_dom_cnt} > 1000 )
            or ( $d{imp_dom_rate} > 0.6 and $d{imp_qry_rate} > 0.6 ) )
        and ( $d{tianya_cn} > 0 or $d{weibo_cn} > 0 or $d{"360_cn"} > 0 )
      );

    return 'recur'
      if (  $d{query_cnt} < 100000
        and $d{c_front_n} > 20
        and $d{imp_dom_cnt} > 1000
        and ( $d{tianya_cn} > 0 or $d{weibo_cn} > 0 or $d{"360_cn"} > 0 ) );

    return 'maybe_recur'
      if (
            $d{query_cnt} < 300000
        and $d{dom_cnt} > 10000
        and $d{imp_qry_rate} > 0.8
        and $d{imp_dom_cnt} > 5000
        and $d{imp_dom_rate} > 0.5
        and (
            (
                    $d{sina_com_cn} > $d{tianya_cn}
                and $d{sina_com_cn} > $d{"360_cn"}
            )
            or
            ( $d{"360_cn"} > $d{tianya_cn} and $d{"360_cn"} > $d{sina_com_cn} )
        )

        and $d{tianya_cn} > 0

        #and $d{weibo_cn}> 0
        and $d{"360_cn"} > 0
      );

    return 'maybe_recur'
      if (  $d{query_cnt} < 50000
        and $d{dom_cnt} > 10000
        and $d{imp_qry_rate} > 0.7
        and $d{imp_dom_cnt} > 5000
        and $d{imp_dom_rate} > 0.4
        and ( $d{tianya_cn} > 0 or $d{weibo_cn} > 0 or $d{"360_cn"} > 0 ) );

    return 'maybe_recur'
      if (  $d{c_front_n} > 3
        and $d{query_cnt} < 150000
        and $d{imp_dom_cnt} > 3000
        and $d{imp_qry_rate} > 0.1 );

    return 'small_query' if($d{query_cnt}<10000); # qcnt < 100000/day
    return 'other';
}
