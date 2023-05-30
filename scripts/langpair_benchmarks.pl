#!/usr/bin/env perl

my %langpairs=();

while (<>){
    my ($s,$t,$b) = split(/\t/);
    $langpairs{"$s-$t"}{$b}++;
}

foreach my $l (sort keys %langpairs){
    print $l,"\t";
    print join(' ',sort keys %{$langpairs{$l}});
    print "\n";
}

