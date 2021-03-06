#!/usr/bin/perl
# Sujay Phadke (C) 2017
#
# Perl script to assign individual nets of an interface, from an input instance to output
#
# Usage:
# ./InterfaceMux.pl interfaces.sv Bus3 "Bus1,Bus2,Bus3,Bus4" sel "2'b00,2'b01,2'b10,2'b11" 1 myBus

use strict;
use warnings;
#use Tie::IxHash;


my $muxMode 		= 0;
my @selValues 		= ();
my $select 			= "";
my $outInterface 	= "";
my @inpInterfaces 	= ();
my $interface 		= "";

if ((scalar @ARGV) < 6){
	die "\nInsufficient number of arguments!\n";
	exit 1;
}

my $inpfile 		= $ARGV[0];
$outInterface 		= $ARGV[1];
@inpInterfaces 		= split(",", $ARGV[2]);
$select 			= $ARGV[3];
@selValues			= split(",", $ARGV[4]);
$muxMode 			= $ARGV[5];
$interface			= $ARGV[6];		# optional

my @NetNames;

ParseInput();


if ((scalar @NetNames) <= 0){
	print "\nError: No valid nets declared in input file interface!";
	print "\n";
	exit 1;
}

#PrintNets();

CreateMux();
print "\n";

exit;

sub ParseInput{
	my $INP;
	my $line;
	my $flag;
	
	open ($INP, "<", $inpfile) or die "\nCannot open input file. $!\n";
	
	if (! defined $interface){
		print "\nNo interface specified. Will parse entire file";
	}
	else{
		print "\nParsing input file for interface: $interface";
	}
	
	$flag = 0;
	while($line = <$INP>){
		
		# find start of interface
		if ((defined $interface) && ($flag == 0)){
			if ($line =~ m/interface\s*$interface/){
				$flag = 1;
			}
			
			next;
		}
		
		# find end of interface
		if ($flag == 1){
			if ($line =~ m/endinterface/){
				last;
			}
		}
		
		# match nets and populate array
		if ($line =~ m/(logic|wire)\s*(\[.*\])?\s*(.*);/i){
			push @NetNames, $3;	
		}
	
	} # end while
	
	if ((defined $interface) && ($flag == 0)){
		print "\nInterface $interface not found in input file!";
		return 1;
	}
	
	return 0;
	
}

sub CreateMux{
	my $i;
	
	# ternary operator
	if ($muxMode == 0){
		if (scalar @inpInterfaces < 2){
			print "\nError: Insufficient number of input interfaces specified for MUX mode: $muxMode";
			return 1;
		}
		#print "\nalways_comb";
		#print "\nbegin";
		
		foreach (@NetNames){
			#print "\n\t$outInterface.$_  <=  $select ? $inpInterfaces[0].$_ : $inpInterfaces[1].$_;";
			print "\n\tassign  $outInterface.$_  =  $select ? $inpInterfaces[0].$_ : $inpInterfaces[1].$_;";
		}
		
		#print "\nend";
	}
	
	# if..else
	elsif ($muxMode == 1){
		if ((scalar @inpInterfaces) < (scalar @selValues)){
			print "\nError: Insufficient input ports for the number of select values!\n";
			exit 1;
		}
			
		print "\nalways @(*)";
		print "\nbegin";
		print "\n\tcase($select)";
		for $i (0 .. $#selValues){
			print "\n\t\t$selValues[$i]: ";
			foreach (@NetNames){
				print "\n\t\t\t\t$outInterface.$_  =  $inpInterfaces[$i].$_;";
			}
		}
		print"\n\tendcase";	
		print "\nend";
	}
	
	else{
		print "\nError! Invalid MUX mode!\n";
		exit 1;
	}
}

sub PrintNets{
	foreach (@NetNames){
		print "\n$inpInterfaces[0].$_";
	}
}
