#!/usr/bin/perl
# Starting point for COMP2041/9041 assignment
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# written by andrewt@cse.unsw.edu.au September 2014


#TODO: Figureout 2's complement

$varnames = '.(?!print|for|while)*';

$operators = '\-=\*\+\&\!\|></%^~';
#$varnames = 'answer';
$currIndent = 0;
my @simplifiedPython = detabify(<>);
#print @simplifiedPython;
#print "Parsed the pythin: \n";
#print @simplifiedPython;
foreach my $input (@simplifiedPython)
{

	#print "input: $input";
	$parsedLine = parseLine($input);
	#print "parsed: $parsedLine";
	push @parsedLines, $parsedLine;
}


print @parsedLines;
#@perlOutput = detabify (@parsedLines);

#print @perlOutput;

#@partParsedLines = tokenSplit(@partParsedLines);
#print "\n------------\n\n";



#dumbParseLine(@partParsedLines);
#

sub parseLine
{
	my ($line) = @_;

	#remove leading white space
	#$line =~s/^\s.//g;
	#remove white space from variable names
	$line =~ s/\s*([$operators])\s*/$1/g;
	chomp $line;
	#$line =~ s/\n//g;
	#@lines = split(';', $line);

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
	elsif ($line =~ /^(\s*)(\w)+[$operators].*/)
	{
		#found expression, parse
		#print "#expression is $line\n";

		$line = $1.parseExpression($line).";\n";
	}
	elsif ($line =~ /^(\s*)print\s*"(.*)"\s*$/)
	{

		#generic string matching
		$line = "$1 print \"$2\\n\";";
	}

	elsif ($line =~ /^(\s*)print\s+(.+)/)
	{
		#inline printing
		$expression = parseExpression($2);

		#print "$variables\n";
		#$expression =~ s/([$operators])([a-zA-Z]\w+)/$1\$$2/g;
		$line = "$1".'print '."$expression".','.'"\n"'.';';
	}
	elsif ($line =~ /(\s*)(if|while|else)\s*(.*)/)
	{
        #seperate condition from the rest of the phrase
        my @condition_phrase = split (':',$3);
		my $condition = parseExpression($condition_phrase[0]);
		$whitespace = $1;
        $line = "$1$2";
        if (!($2 =~ /else/))
        {
            $line.="($condition)";
        }
       	$line.= generateIndents($currIndent);
        #$currIndent++;

        #print "#conditon phrase is @condition_phrase\n";
        my $expressions = join(':', @condition_phrase[1..$#condition_phrase]);
        $expressions =~ s/^\s*//g;
        if ($expressions)
        {
        	#print "#FOOOOO $expressions\n";
        	$line.= generateIndents($currIndent);
        	$line.="\n".$whitespace."{\n";
        	$currIndent++;
       		$line.= $whitespace."\t";
			my @subexpressions = split (';', $expressions);
	        #print "#expressions are $expressions\n";
	        #join the rest of the phrase

			foreach  my $subexpr (@subexpressions)
			{
				chomp $subexpr;
				$subexpr =~ s/^\s*//g;
				#print "#subexpr is $subexpr";
				$expression = parseLine($subexpr);

	            #indenting
	        	$line.= generateIndents($currIndent);
				$line .= "$expression";
				#print "$subexpr\n";
			}
		}
        $currIndent--;
		$line.= generateIndents($currIndent);
		if($expressions)
		{
			$line.="\n".$whitespace."}\n";
		}

	}
	elsif ($line =~/(\s*)(for)\s*(\w+)\s*in\s*(.*):/)
	{
		$line = "$1$2 my ".parseExpression($3)." ".parseExpression($4);


	}
    elsif($line =~ /^\s*(break|continue)(\s*|\n)/)
    {
    	#print "#found print \n";
        $line = generateIndents($currIndent).parseExpression($1);
    }
    elsif ($line =~/[\{\}]/)
    {
    	$line = $line;
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
	
	#print $expr;
	if ($expr =~ /([a-zA-Z]\w*)=range.*/)
	{
		$expr =~ s/([a-zA-Z]\w*)/\@$1/g;

	}
	else
	{
		$expr =~ s/^\s*//g;
		$expr =~ s/\s*or\s+/ || /g;
		$expr =~ s/\s*and\s*/ && /g;
		$expr =~ s/\s*not\s*/ ! /g;
		$expr =~ s/([a-zA-Z]\w*)/\$$1/g;
		$expr =~ s/\$print/print /g;
	    $expr =~ s/\$break/last;/g;
	}
    if ($expr =~ /[\$\@]*range\(\s*(.*),\s*(.*)\)/)
    {
    	$start = $1;
    	$end = $2;
    	#print "EEEEND $end\n";
    	if($end =~ /(\$\w+)\+1/ )
    	{
    		$end = $1;
    	}
    	elsif ($end =~/\s*(\d+)\s*/)
		{
			$end = $1-1;
		}
    	else
    	{
    		$end .="-1";
    	}
    	#print "EEEEND $end\n";
    	$expr =~ s/[\$\@]*range\(\s*(.*),\s*(.*)\)/\($start..$end\)/g;
    }
    
	return $expr;
}


sub detabify
{

	my @inputLines = @_;
	my @indentStack = ();
	my @returnLines = ();
	my $lineBuffer = ();

	$inLoop = 0;
	
	$indentStack[0] = 0;

	foreach my $line(@inputLines)
	{
		$tabstring = $line;
		@tabarray = $tabstring =~ m/^\s+/g;
		$tabstring = $tabarray[0];
		@tabarray = $tabstring =~ m/(\s)/g;
		$tabspaces = $#tabarray+1;

		#print "#$tabspaces $line";

		$line =~ s/^(\s*)//g;
		
		
		if (!($line =~/^\s*#/) && !($line =~/^\s*$/))
		{

			if ($tabspaces < 0)
			{
				$tabspaces = 0;
			}

			if ($tabspaces > $indentStack[-1] )
			{
				#print "INCREASE\n";
				$lineBuffer .=generateIndents($#indentStack)."{\n";
				push @returnLines, $lineBuffer;
				$lineBuffer = '';
				push @indentStack, $tabspaces;
			}
			elsif ($tabspaces < $indentStack[-1])
			{
				#print "DEACREASE\n";
				while ($tabspaces < $indentStack[-1])
				{
					pop @indentStack;
					$lineBuffer.="\n".generateIndents($#indentStack)."}\n";
					push @returnLines, $lineBuffer;
					$lineBuffer = '';
				}


			}


			$lineBuffer.=generateIndents($#indentStack).$line;

			push @returnLines, $lineBuffer;
			$lineBuffer = '';
		}

	}
	while ($indentStack[-1] > 0)
	{
		pop @indentStack;
		$lineBuffer.="\n".generateIndents($#indentStack)."}\n";
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

