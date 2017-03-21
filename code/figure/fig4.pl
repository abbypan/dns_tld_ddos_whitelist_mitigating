#!/usr/bin/perl
use SimpleR::Reshape;

my $s = 0;
read_table('client_qrcnt_fig_3.id.rev',
    sep=> ' ', 
    return_arrayref=>0,
    conv_sub => sub {
        my ($r) = @_;
        $s+=$r->[-1];
        return;
    });

my $c = 0;
read_table('client_qrcnt_fig_3.id.rev',
    sep=> ' ', 
    return_arrayref=>0,
    write_file=> 'client_qrcnt_fig_4.id.stat', 
    conv_sub => sub {
        my ($r) = @_;
        $c+=$r->[-1];
        my $p = $c/$s;
        push @$r, $c ;
        push @$r, $p || 0;
        return $r;
    });
