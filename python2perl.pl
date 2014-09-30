#!/usr/bin/perl
# Starting point for COMP2041/9041 assignment 
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# written by andrewt@cse.unsw.edu.au September 2014


$varnames = '.(?!print|for|while)*';

$operators = '\-=\*\+\&\!\|><:/%';
%pythonKeywords = createKeywordHash();
#$varnames = 'answer';

while (my $input = <>)
{
	$parsedLine = parseLine($input);
	print $parsedLine;
}
#@partParsedLines = tokenSplit(@partParsedLines);
#print "\n------------\n\n";



#dumbParseLine(@partParsedLines);


sub parseLine
{
	my ($line) = @_;

	#remove leading white space
	$line =~s/^\s.//g;
	#remove white space from variable names
	$line =~ s/\s*([$operators])\s*/$1/g;
	$line =~ s/\n//g;

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
	elsif ($line =~ /^(\w)+=.*/)
	{
		#found expression, parse
		#print "#expression is $line\n";
		$line = parseExpression($line).";\n";
	}
	elsif ($line =~ /^print\s*"(.*)"\s*$/) 
	{
	
		#generic string matching
		$line = "print \"$1\\n\";\n";
	}
	
	elsif ($line =~ /^print\s+(.+);(.+)/)
	{
		#inline printing and continue FIXME
		$expression1 = parseExpression($1);
		$expression2 = parseExpression($2);

		#print "#expression1 is $expression1 from $1 \n";
		#$expression =~ s/([$operators])([a-zA-Z]\w+)/$1\$$2/g;
		$line = 'print '.$expression1.','.'"\n"'.';'.$expression2."\n";		
	}

	elsif ($line =~ /^print\s+(.+)/)
	{
		#inline printing
		$expression = parseExpression($1);

		#print "$variables\n";
		#$expression =~ s/([$operators])([a-zA-Z]\w+)/$1\$$2/g;
		$line = 'print '."$expression".','.'"\n"'.';';		
	}
	elsif ($line =~ /^(if|while)\s+(.*):(.*)/)
	{	
		$condition = parseExpression($2);
		#printf "#condition is $condition\n";
		$expression = parseLine($3);
		#printf "#expression is $expression\n";

		$line = "$1 ($condition) \n{\n\t$expression}\n";

	}
	else
	{
		$line = '#'.$line;
	}




	$line = $line."\n"; 
	return $line;
}



sub parseExpression
{
	my ($expr) = @_;
	$expr =~ s/\s*or\s+/ || /g;
	$expr =~ s/\s*and\s*/ && /g;
	$expr =~ s/\s*not\s*/ ! /g;
	$expr =~ s/([a-zA-Z]\w*)/\$$1/g;
	#print "$expr\n";
	
	return $expr;
}

sub simplifyPython
{
	my @inputLines = @_;
	my @returnLines = ();

	$lineReady = 1;
	foreach my $line(@inputLines)
	{
		if ($line =~ /^while(.*)/)
		{
			print "whee\n";
		}

		if ($lineReady == 1)
		{
			push @returnLines, line;
		}


	}
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