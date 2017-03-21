#!/usr/bin/perl

use SimpleR::Reshape;
use List::AllUtils qw/mesh/;
use utf8;

our @HEAD = qw/client global_rec_cnt big_rec_cnt q360 qsina qtianya good_cnt_rate log10_sec_dom_cnt log10_qcnt is_china/;

my $src= 'client_qtype/client_A_secdom_1k.shrink.csv';
my $learn_f = $src;
$learn_f=~s/.shrink.csv$/.learn.csv/;

#my @test= qw/209.209.171.37	7372	10506	3521	36	3	0	0	6.913737351	17.57443297	0	other/;
#print check_type(\@test);
#exit;

read_table($src, 
    write_file => $learn_f, 
    skip_head => 1, 
    write_head => [ @HEAD, 'type' ], 
    conv_sub => sub {
        my ($r) = @_;
        my $type = check_type($r);
        return if($type ne 'other');
        push @$r, $type;
        return $r;
    },
    charset => 'utf8', 
    return_arrayref=>0,
    skip_head => 1, 
);

sub check_type {
    my ($r) = @_;
    my %d = mesh @HEAD, @$r;

    ## {{
    return 'recur_public' if($d{client}=~/^\Q208.67.219./); #opendns
    return 'recur_public' if($d{client}=~/^74\.125\.1[6-9]\./
            or $d{client}=~/^74\.125\.4[6-7]\./
            or $d{client}=~/^74\.125\.7[2-8]\./
            or $d{client}=~/^74\.125\.80\./
            or $d{client}=~/^74\.125\.11[3-4]\./
            or $d{client}=~/^74\.125\.17[6-8]\./
            or $d{client}=~/^74\.125\.18[0-7]\./
            or $d{client}=~/^74\.125\.190\./
            or $d{client}=~/^173\.194\.89\./
            or $d{client}=~/^173\.194\.9[0-9]\./
    ); #google open dns
    return 'service_spider' if($d{client}=~/^\Q178.255.215./); #exabot
    return 'service_spider' if($d{client}=~/^\Q66.249.66./); #google spider
    return 'service_spider' if($d{client}=~/^66\.249\.7[346]\./);#google spider
    return 'service_spider' if($d{client}=~/^\Q220.181.108./); #baidu spider
    return 'service_spider' if($d{client}=~/\Q67.195.93./); #yahoo spider
    return 'service_spider' if($d{client}=~/^\Q188.165.15./); #seek.fr spider
    return 'service_spider' if($d{client}=~/^\Q123.125.71./); #baidu spider
    return 'service_spider' if($d{client}=~/^\Q84.201.146./); #yandex spider
    return 'recur_important' if($d{big_rec_cnt}>0);
    return 'recur_important' if($d{global_rec_cnt}>300); #many front

    return 'service_cloud' if($d{client}=~/\Q91.236.239./); #firstheberg.com
    return 'service_cloud' if($d{client}=~/\Q82.165.226./); # 1and1
    return 'recur_isp' if($d{client}=~/\Q106.120.151./); #chinamobile bj
    return 'service_cloud' if($d{client}=~/\Q208.115.113./ or $d{client}=~/\Q208.115.111./); #wowrack


    return 'service_large_query' if($d{client}=~/\Q15.203.224./ or $d{client}=~/\Q15.211.192./); #hp.com

    ## }}
#small_qcnt
#spider maybe_spider isp_recur public_recur other_recur maybe_recur 
#maybe_service_like_mail evil_spider evil_spam maybe_evil other
    ## {{
    return 'recur_isp' if($d{global_rec_cnt}>50
            and ($d{q360}>$d{qsina} and $d{q360}>$d{qtianya} and $d{qsina}>0)
            and $d{good_cnt_rate}>0.5
            and $d{log10_qcnt}<6 and $d{log10_sec_dom_cnt}>4
    );
    return 'recur_isp' if($d{global_rec_cnt}>0
            and ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and $d{good_cnt_rate}>0.5
            and $d{log10_qcnt}<7 and $d{log10_sec_dom_cnt}>4
    );
    return 'recur_isp' if($d{global_rec_cnt}>0
            and ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and $d{good_cnt_rate}<0.3
            and $d{log10_qcnt}<6.5 and $d{log10_sec_dom_cnt}>5
    );
    return 'recur_isp' if($d{global_rec_cnt}>0
            and ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and $d{good_cnt_rate}>0.3
            and $d{log10_qcnt}>5 and $d{log10_sec_dom_cnt}>5
    );
    return 'recur_cloud' if(
            $d{global_rec_cnt}>0 
            and ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.05 and $d{good_cnt_rate}<0.2)
            and ($d{log10_sec_dom_cnt}>3 and $d{log10_sec_dom_cnt}<4)
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<6.5)
    );
    return 'recur_cloud' if(
        $d{global_rec_cnt}>0
            and ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and $d{good_cnt_rate}>0.3
            and $d{log10_sec_dom_cnt}<5.5
            and $d{log10_qcnt}<6 
    );
    return 'recur_cloud' if( 
        # wowrack 
        $d{global_rec_cnt}>0
            and ($d{good_cnt_rate}>0.1 and $d{good_cnt_rate}<0.3)
            and ($d{log10_sec_dom_cnt}<4 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<7 and $d{log10_qcnt}>4) 
    );
    return 'recur_small' if(
        $d{global_rec_cnt}>0
            and $d{log10_qcnt}<6 and $d{log10_sec_dom_cnt}<5
    );
    return 'recur_isp' if( 
        $d{global_rec_cnt}>0 
            and ($d{good_cnt_rate}>0.3 and $d{good_cnt_rate}<0.6)
            and ($d{log10_sec_dom_cnt}<6 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<7 and $d{log10_qcnt}>5) 
    );
    return 'recur_cloud' if( 
#wowrack 
        $d{global_rec_cnt}>0 
            and ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and ($d{good_cnt_rate}>0.01 and $d{good_cnt_rate}<0.2)
            and ($d{log10_sec_dom_cnt}<4 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<7 and $d{log10_qcnt}>5) 
    );
    return 'recur_other' if($d{global_rec_cnt}>0
            and ($d{q360}>$d{qtianya} and $d{qtianya}>$d{qsina} and $d{qsina}>0)
            and $d{log10_qcnt}<8 and $d{log10_sec_dom_cnt}<8
    );
    return 'recur_small' if($d{global_rec_cnt}>0
            and ($d{qtianya}>0 and $d{q360}>0 and $d{qsina}>0)
            and $d{good_cnt_rate}>0.7
            and $d{log10_qcnt}<5.5 and $d{log10_sec_dom_cnt}>3
    );


    return 'maybe_recur_isp' if(#
            ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.4 and $d{good_cnt_rate}<0.6)
            and ($d{log10_sec_dom_cnt}<4 and $d{log10_sec_dom_cnt}>5)
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<6)
    );

    return 'maybe_recur_isp' if(
            ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and ($d{good_cnt_rate}>0.1 and $d{good_cnt_rate}<0.2)
            and ($d{log10_sec_dom_cnt}<6 and $d{log10_sec_dom_cnt}>4)
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<7)
    );

    return 'maybe_recur_isp' if(
            ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and ($d{good_cnt_rate}>0.01 and $d{good_cnt_rate}<0.1)
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<6)
            and ($d{log10_sec_dom_cnt}<6 and $d{log10_sec_dom_cnt}>5)
    );

    return 'maybe_recur_isp' if(#
            ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and $d{good_cnt_rate}>0.6
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<6)
            and ($d{log10_sec_dom_cnt}<5 and $d{log10_sec_dom_cnt}>4)
    );

    return 'maybe_recur' if(
            ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and ($d{good_cnt_rate}>0.001 and $d{good_cnt_rate}<0.01)
            and ($d{log10_sec_dom_cnt}<5 and $d{log10_sec_dom_cnt}>6)
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<7)
    );

    return 'maybe_cloud' if(
            ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and $d{good_cnt_rate}>0.3
            and $d{log10_sec_dom_cnt}<5.5
            and $d{log10_qcnt}<6 
    );
    return 'maybe_recur_small' if(
            ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.3 and $d{good_cnt_rate}<0.5)
            and ($d{log10_sec_dom_cnt}>3 and $d{log10_sec_dom_cnt}<4)
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<7)
    );
    return 'maybe_recur_small' if(
            ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.2 and $d{good_cnt_rate}<0.3)
            and ($d{log10_sec_dom_cnt}>4 and $d{log10_sec_dom_cnt}<5)
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<6)
    );
    return 'maybe_cloud' if($d{good_cnt_rate}>0.7
            and $d{log10_qcnt}<7 and $d{log10_sec_dom_cnt}<4
    );
    return 'maybe_recur_small' if( 
            ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.2 and $d{good_cnt_rate}<0.35)
            and ($d{log10_sec_dom_cnt}<4 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<6 and $d{log10_qcnt}>4) 
    );
    return 'maybe_service' if( 
            ($d{q360}<400 and $d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.5 and $d{good_cnt_rate}<0.6)
            and ($d{log10_sec_dom_cnt}<5 and $d{log10_sec_dom_cnt}>4)
            and ($d{log10_qcnt}<6 and $d{log10_qcnt}>5) 
    );
    


    return 'maybe_service' if( 
        ($d{q360}<400 and $d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.05 and $d{good_cnt_rate}<0.1)
            and ($d{log10_sec_dom_cnt}<5.5 and $d{log10_sec_dom_cnt}>5)
            and ($d{log10_qcnt}<6.5 and $d{log10_qcnt}>6) 
    );

    return 'maybe_recur_small' if( 
            ($d{q360}<200 and ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0))
            and ($d{good_cnt_rate}>0.2 and $d{good_cnt_rate}<0.5)
            and ($d{log10_sec_dom_cnt}<5 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<6 and $d{log10_qcnt}>5) 
    );
    return 'maybe_recur_small' if( 
            ($d{q360}<200 and $d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.05 and $d{good_cnt_rate}<0.2)
            and ($d{log10_sec_dom_cnt}<5 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<6 and $d{log10_qcnt}>5) 
    );
    return 'maybe_recur_small' if( 
#gd tel 
#bluehost
            ($d{q360}<200 and $d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.45 and $d{good_cnt_rate}<0.6)
            and ($d{log10_sec_dom_cnt}<5 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<6 and $d{log10_qcnt}>5) 
    );
    return 'maybe_cloud' if( 
            ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and ($d{good_cnt_rate}>0.01 and $d{good_cnt_rate}<0.2)
            and ($d{log10_sec_dom_cnt}<4.5 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<7 and $d{log10_qcnt}>5) 
    );
    return 'maybe_recur_small' if( 
            ($d{q360}<200 and $d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.6 and $d{good_cnt_rate}<0.7)
            and ($d{log10_sec_dom_cnt}<6 and $d{log10_sec_dom_cnt}>5)
            and ($d{log10_qcnt}<6 and $d{log10_qcnt}>5) 
    );
    return 'maybe_recur_small' if( 
            ($d{q360}<1000 and $d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.4 and $d{good_cnt_rate}<0.7)
            and ($d{log10_sec_dom_cnt}<6 and $d{log10_sec_dom_cnt}>3)
            and ($d{log10_qcnt}<6 and $d{log10_qcnt}>4) 
    );
    return 'maybe_recur_small' if( 
            ($d{q360}>0 and $d{qtianya}>0 and $d{qsina}>0)
            and ($d{good_cnt_rate}>0.2 and $d{good_cnt_rate}<0.35)
            and ($d{log10_sec_dom_cnt}<6.5 and $d{log10_sec_dom_cnt}>5)
            and ($d{log10_qcnt}<7 and $d{log10_qcnt}>5) 
    );
    return 'maybe_service' if(
            ($d{qsina}>100 and $d{qtianya}>100 and $d{q360}>100)
            and $d{good_cnt_rate}>0.9
            and $d{log10_qcnt}<6 and $d{log10_sec_dom_cnt}>3
    );
    ## }}

    return 'maybe_probe' if( 
        $d{global_rec_cnt}<10 
            and ($d{q360}>0 or $d{qtianya}>0 or $d{qsina}>0)
            and ($d{good_cnt_rate}<0.01)
            and ($d{log10_sec_dom_cnt}>6 and $d{log10_sec_dom_cnt}<7)
            and ($d{log10_qcnt}>6 and $d{log10_qcnt}<7) 
    );

    return 'maybe_service' if( 
        $d{global_rec_cnt}<10 
            and ($d{q360}==0 and $d{qtianya}==0 and $d{qsina}==0)
            and ($d{good_cnt_rate}>0.25 and $d{good_cnt_rate}<0.35)
            and ($d{log10_sec_dom_cnt}>3 and $d{log10_sec_dom_cnt}<4)
            and ($d{log10_qcnt}>5 and $d{log10_qcnt}<6) 
    );

    return 'maybe_evil' if( 
        $d{global_rec_cnt}<10 
            and ($d{q360}==0 and $d{qtianya}==0 and $d{qsina}==0)
            and ($d{good_cnt_rate}<0.01)
            and ($d{log10_sec_dom_cnt}>5)
            and ($d{log10_qcnt}>5) 
    );


    return 'other_small_query' if($d{log10_qcnt}<5); # qcnt < 100000/day
    return 'other';
}
