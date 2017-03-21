#!/usr/bin/perl
use SimpleR::Reshape;
my ($src) = @ARGV;

#calc_src_rank($src, "$src.0", 0); # client => sec_dom_rank
#calc_src_rank("$src.0", "$src.1", 1); # sec_dom => client_rank
#calc_src_rank("$src.1", "$src.0", 0); # client => sec_dom_rank
#calc_src_rank("$src.0", "$src.1", 1); # sec_dom => client_rank
calc_src_rank("$src.1", "$src.0", 0); # client => sec_dom_rank

sub calc_src_rank {
    my ($src, $dst, $id) = @_;
    print "calc_src_rank: $src, $dst, $id\n";

my %c_mem;
read_table($src,
    return_arrayref=>0,
    conv_sub => sub {
        my ($r) = @_;
        $c_mem{$r->[$id]}{cnt}+= $r->[2];
        $c_mem{$r->[$id]}{rank}+= $r->[2]*$r->[3];
    },
);

my ($max, $min) = (0, 0);
while(my ($client, $r) = each %c_mem){
    my $n = $r->{rank} / $r->{cnt};
    $c_mem{$client} = $n;
    $max = $n if($n>$max);
    $min = $n if(! $min or $min>$n);
}

$c_mem{$_} = ($c_mem{$_} - $min)/($max-$min) for keys %c_mem;
read_table($src,
    write_file => $dst, 
    return_arrayref=>0,
    conv_sub => sub {
        my ($r) = @_;
        return [ @{$r}[0,1,2], $c_mem{$r->[$id]} ];
    },
);
}
