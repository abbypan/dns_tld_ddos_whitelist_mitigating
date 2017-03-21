#!/usr/bin/perl
use SimpleR::Reshape;

my $big = 'recur_front_back.tidy.csv.graph.perl.0.1.1.0.0.1.sort';
my $small = 'recur_front_back.tidy.csv.id.perl';
my $merge = "$big.merge.csv";

merge_file( 
    $small, 
    $big, 
    merge_file => "$big.merge.1", 
    by_x => [ 1 ], 
    value_x => [0, 2], 
    by_y => [ 0 ], 
    value_y => [ 0, 1, 2, 3 ], 
);

merge_file( 
    $small, 
    "$big.merge.1", 
    merge_file => "$big.merge.2", 
    by_x => [ 1 ], 
    value_x => [0, 2], 
    by_y => [ 1 ], 
    value_y => [ 0, 1, 2, 3, 4, 5 ], 
);

sub merge_file {
	# $y left join $x , with some coulumn
	my ( $x, $y, %opt ) = @_;
	$opt{default_cell_value} //= 0;
	$opt{sep} //= ',';
	$opt{merge_file} ||= "$y.merge";

	my $x_raw = {
		by    => $opt{by_x} || $opt{by},
		value => $opt{value_x} || $opt{value} ,
	};
	my %mem_x;
	read_table($x, 
			%opt, 
			return_arrayref=>0, 
			conv_sub => sub {
			my ($r) = @_;
			my $cut = join( $opt{sep}, @{$r}[@{$x_raw->{by}}] );
			my @vs = map {
			$r->[$_] // $opt{default_cell_value}
			} @{$x_raw->{value}};
			$mem_x{$cut} = \@vs;
			});

	my $y_raw = {
		by    => $opt{by_y} || $opt{by},
		value => $opt{value_y} || $opt{value} ,
	};

	read_table($y, 
			%opt,
			write_file => $opt{merge_file}, 
			return_arrayref=>0, 
			conv_sub => sub {
			my ($d) = @_;
			my $cut = join( $opt{sep}, @{$d}[@{$y_raw->{by}}] );
			my @vs = map {
			$d->[$_] // $opt{default_cell_value}
			} @{$y_raw->{value}};
			push @vs, @{$mem_x{$cut}};
			return \@vs;
			}, 
		  );

	return $opt{merge_file};
}
