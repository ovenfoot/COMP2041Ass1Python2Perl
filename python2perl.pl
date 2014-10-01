#!/usr/bin/perl
# Starting point for COMP2041/9041 assignment
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# written by andrewt@cse.unsw.edu.au September 2014


$varnames = '.(?!print|for|while)*';

$operators = '\-=\*\+\&\!\|><:/%';
#$varnames = 'answer';
$currIndent = 0;
my @simplifiedPython = simplifyPython(<>);
#print "Parsed the pythin: \n";
#print @simplifiedPython;
foreach my $input (@simplifiedPython)
{

	#print "$input \n";
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

	@lines = split(';', $line);

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

	elsif ($line =~ /^print\s+(.+)/)
	{
		#inline printing
		$expression = parseExpression($1);

		#print "$variables\n";
		#$expression =~ s/([$operators])([a-zA-Z]\w+)/$1\$$2/g;
		$line = 'print '."$expression".','.'"\n"'.';';
	}
	elsif ($line =~ /^(if|while)\s+(.*)/)
	{

        my @condition_phrase = split (':',$2);
        #print "original is $2 parsed split is "
		my $condition = parseExpression($condition_phrase[0]);
		$line = "$1 ($condition) \n";
       	$line.= generateIndents($currIndent);
        $line.="{\n";

        $currIndent++;
        my $expressions = join(':', @condition_phrase[1..$#condition_phrase]);
		my @subexpressions = split (';', $expressions);
		foreach  my $subexpr (@subexpressions)
		{
			chomp $subexpr;
			$subexpr =~ s/^\s*//g;
			$expression = parseLine($subexpr);

            #indenting
        	$line.= generateIndents($currIndent);
			$line .= "$expression";
			#print "$subexpr\n";
		}

        $currIndent--;
        #for (my $i = 0; $i<$currIndent; $i++)
        #{
            #$line .= "\t";
            #}
		$line.= generateIndents($currIndent);
        $line.="}\n";

	}
    elsif($line =~ /^\s*(break|continue)(\s*|\n)/)
    {
        $line = parseExpression($1);
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
	$expr =~ s/\$print/print/g;
    $expr =~ s/\$break/last;/g;
	return $expr;
}

sub simplifyPython
{
	my @inputLines = @_;
	my @returnLines = ();
	my $lineBuffer = ();

	$inLoop = 0;
	$currentTab = 0;

	foreach my $line(@inputLines)
	{
		$tabspaces = $line =~ m/^\s/g;

		if ($inLoop == 1 && $tabspaces == 0)
		{
			$inLoop = 0;
			push @returnLines, $lineBuffer;
			$lineBuffer = '';
		}


		if ($line =~ /^while(.*):/)
		{
			$inLoop = 1;
		}

		if($inLoop)
		{
			chomp $line;
			if (!($line =~ /^while(.*):/))
			{
				$line .= ";";
			}
		}

		$lineBuffer .=$line;
		if(!$inLoop)
		{	#print "$lineBuffer\n";
			push @returnLines, $lineBuffer;
			$lineBuffer = '';
		}

		#print "$lineBuffer\n";


	}
	if($lineBuffer)
	{
		#print "$lineBuffer\n";
		push @returnLines, $lineBuffer;
	}



	return @returnLines;
}

sub generateIndents
{
    my ($noIndents) = @_;
    my $returnString = '';

    for (my $i =0; $i<$noIndents; $i++)
    {
        $returnString.="\t";
    }

    return $returnString;

}
