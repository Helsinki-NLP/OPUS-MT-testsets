#!/usr/bin/env perl

my %benchmarks=();

while (<>){
    my ($s,$t,$b) = split(/\t/);
    $benchmarks{$b}{"$s-$t"}++;
}

foreach my $b (sort keys %benchmarks){
    print $b,"\t";
    print join(' ',sort keys %{$benchmarks{$b}});
    print "\n";
}

