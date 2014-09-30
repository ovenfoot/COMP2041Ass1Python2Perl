#!/usr/bin/perl
# Starting point for COMP2041/9041 assignment 
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# written by andrewt@cse.unsw.edu.au September 2014


$varnames = '.(?!print|for|while)*';
$operators = '\-=\*\+\&\!\|';
%pythonKeywords = createKeywordHash();
#$varnames = 'answer';

@partParsedLines = parseLine(<>);
#@partParsedLines = tokenSplit(@partParsedLines);
print "@partParsedLines\n";
#print "\n------------\n\n";



#dumbParseLine(@partParsedLines);


sub parseLine
{
	my @lines = @_;
	my @returnLines = ();
	foreach my $line (@lines)
	{
		#remove leading white space
		$line =~s/^\s.//g;
		#remove white space from variable names
		$line =~ s/\s*([$operators])\s*/$1/g;


		#add dollar signs to variable names
		$line =~ s/([$operators])([a-zA-Z]\w+)/$1\$$2/g;

		if ($line =~ /^#!/)
		{
			#firstline
			$line = "#!/usr/bin/perl -w";
		}
		elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) 
		{
			# Blank & comment lines can be passed unchanged
			$line = $line;
		} 
		elsif ($line =~ /print\s*"(.*)"\s*$/) 
		{
		
			#generic string matching
			$line = "print \"$1\\n\";\n";
		}
		
		elsif ($line =~ /print\s+(.+)/)
		{
			#inline printing
			$expression = $1;
			#print "$variables\n";
			#$expression =~ s/([$operators])([a-zA-Z]\w+)/$1\$$2/g;
			$line = 'print '.'$'.$expression.','.'"\n"'.';';		
		}
		elsif ($line =~/(\w+)=(.*)/)
		{
			#variable assignment
			#print "WHOOP\n";
			$line = '$'.$1.'='.$2.';';
		}
		else
		{
			$line = '#'.$line;
		}



		$line = $line."\n"; 
		push @returnLines, $line;


		
	}

	return @returnLines;
}



sub dumbParseLine
{
	my @lines = @_;
	foreach my $line (@lines)
	{
		if ($line =~ /^#!/) 
		{
		
			print "#!/usr/bin/perl -w\n";
		} 
		elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) 
		{
		
			# Blank & comment lines can be passed unchanged
			
			print $line;
		} 
		elsif ($line =~ /print\s*"(.*)"\s*$/) 
		{
		
			# Python's print print a new-line character by default
			# so we need to add it explicitly to the Perl print statement
			
			print "print \"$1\\n\";\n";
		}
		#elsif ($line =~/(\w+)=(.*)/)
		#{
		#	#variable assignment
		#	#print "WHOOP\n";
		#	print "\$$1=$2;\n"
		#}
		#elsif ($line =~/print\s*(\w+)/)
		#{
		#	#variable assignment
		#		#print "WHOOP\n";
		#	print "print \"\$$1\\n\"; \n";
		#} 
		else 
		{
		
			# Lines we can't translate are turned into comments
			print "#raw output\n";
			print "$line\n";
		}
	}

}



##Helpper functions not used for now---------------------
sub removeWhitespaces
{
	my @lines = @_;
	my @returnLines = ();
	foreach my $line (@lines)
	{
		$line =~ s/\s*=\s*/=/g;
		#$line =~ s/^\s*//g;
		push @returnLines, $line;
		
	}

	return @returnLines;


}

#Note - TokenSplit not working. placeholder for now
sub tokenSplit
{
	my @lines = @_;

	return split(/[*+=]/, @lines)

}


sub createKeywordHash
{

	my %keywords = {};
	$keywords{print}++;

	return %keywords;
}