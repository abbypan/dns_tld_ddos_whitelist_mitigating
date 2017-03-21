#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use SimpleR::Reshape;

my ( $f, $i ) = @ARGV;
$i ||= 0;

read_table(
    $f,
    write_file => "$f.spider",
    conv_sub   => sub {
        my ($r) = @_;
	my $x = check_spider( $r->[$i] );
	#return unless($x ne 'unknown');
        push @$r, $x;
        return $r;
    },
);

sub check_spider {
    my ($d) = @_;
    return 'baidu'  if ( $d =~ /^\Q180.76.15./ );      #baidu spider
    return 'exabot' if ( $d =~ /^\Q178.255.215./ );    #exabot
    return 'google'
      if ( $d =~ /^\Q66.249.66./ or $d =~ /^\Q66.249.70./ );    #google spider
    return 'google'  if ( $d =~ /^66\.249\.7[346]\./ );         #google spider
    return 'baidu'   if ( $d =~ /^\Q220.181.108./ );            #baidu spider
    return 'yahoo'   if ( $d =~ /\Q67.195.93./ );               #yahoo spider
    return 'seek.fr' if ( $d =~ /^\Q188.165.15./ );             #seek.fr spider
    return 'baidu'   if ( $d =~ /^\Q123.125.71./ );             #baidu spider
    return 'yandex'
      if ( $d =~ /^\Q84.201.146./
        or $d =~ /^\Q141.8.185./
        or $d =~ /^\Q2a02:6b8:0:c47::54c9:/ );                  #yandex spider

    return '360'  if ( $d =~ /^101\.226\.16\d\./ );             #360 spider
    return '360'  if ( $d =~ /^182\.118\.[23]\d\./ );           #360 spider
    return '360'  if ( $d =~ /^\Q61.55.185./ );                 #360 spider
    return '360'  if ( $d =~ /^\Q182.136.133./ );               #360 spider
    return '360'  if ( $d =~ /^\Q180.153.229./ );               #360 spider
    return '360'  if ( $d =~ /^\Q180.153.236./ );               #360 spider
    return 'bing' if ( $d =~ /^\Q65.55.37./ );                  #bing spider
    return 'fortinet'
      if ( $d =~ /^\Q207.102.138./ )
      ;    # Fortinet Technologies (Canada)  security test
    return 'yandex' if ( $d =~ /^\Q141.8.189./ );        # yandex.net
    return 'sohu'   if ( $d =~ /^\Q61.135.150.177/ );    # sohu
    return 'unknown';
}
