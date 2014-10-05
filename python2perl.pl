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
push @parsedLines, "#!/usr/bin/perl -w\n";
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
	#$line =~ s/\s*([$operators])\s*/$1/g;
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
	elsif ($line =~ /^(\s*)(\w)+\s*[$operators].*/)
	{
		#mathematical expression. 
		$line = $1.parseExpression($line).";\n";
	}
	elsif ($line =~ /^(\s*)print\s*\(*"(.*)"\)*\s*$/)
	{

		#generic string printing, reproduce
		$string = $2;
		$whitespace = $1;

		#for python concatenate string printing, replace ", " with a space
		$string =~ s/\s*\"\s*\,\s*\"\s*/ /g;
		print "#string is $string\n";
		$line = "$whitespace print \"$string\\n\";";


	}
	elsif ($line =~ /^(\s*)print\s*"(.*)"\s*\%\s*\(*([^\(\)]*)\)*/)
	{
		#formatted print statements. the inclusion of % is key
		$whitespace = $1;
		$formattedString = '"'.$2.'\n'.'"';
		$arguments = parseExpression($3);
		$line = "$whitespace"."printf($formattedString, $arguments);";
	}
	elsif ($line =~ /^(\s*)print\s*(.*)/)
	{
		#inline printing
		#for 'print' or 'print x'
		$whitespace = $1;
		
		if ($2)
		{
			$expression = parseExpression($2).",";
		}

		#decide whether or not to auto include newline
		if ($expression =~ /\,,$/)
		{
			#print "FUUU\n";
			$expression =~ s/,$//g;
			$line = $whitespace.'print '.$expression.';';
		}
		else
		{
			$line = $whitespace.'print '.$expression.'"\n"'.';';
		}

		
	}
	elsif ($line =~ /^(\s*)sys.stdout.write\s*\(['\"](.*)['\"]\)/)
	{
		#stdout.write operates the same way as print
		$line = "$1print \"$2\";";
	}
	elsif ($line =~ /(\s*)(elif|if|while|else)\s*(.*)/)
	{
		#basic conditionals.
		#extra code to handle 
		$whitespace = $1;
		$keyword = $2;

        #seperate condition from the rest of the phrase
        my @condition_phrase = split (':',$3);
		my $condition = parseExpression($condition_phrase[0]);
		
		$keyword =~ s/elif/elsif/g;
		$line = "$whitespace$keyword";

        if (!($keyword =~ /else/))
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
		$itr = parseExpression($3);
		$range = parseExpression($4);

		#case to deal with range being an array instead of someting else
		$range =~ s/^\$/\@/g;
		$line = "$1foreach my ".$itr." "."($range)";


	}
    elsif($line =~ /^\s*(break|continue)(\s*|\n)/)
    {
    	#print "#found print \n";
        $line = generateIndents($currIndent).parseExpression($1);
    }
    elsif ($line =~ /(\s*)(\w+)\.append\((\w+)\)/)
    {
    	$expression = parseExpression($3);
    	#print "beforeappend is $2";
    	$line = "$1push \@$2, $expression;";

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


sub parseFunction
{
	my ($expr) = @_;
	print "found function\n";

}
sub parseExpression
{
	my ($expr) = @_;
	
	$expr =~ s/\s*([$operators])\s*/$1/g;
	#Generic operators
	$expr =~ s/^\s*//g;
	$expr =~ s/\s*or\s+/ || /g;
	$expr =~ s/\s*and\s*/ && /g;
	$expr =~ s/\s*not\s*/ ! /g;

	
	if (($expr =~ /([a-zA-Z]\w*)=range.*/) ||
		($expr =~ /([a-zA-Z]\w*)=sys.stdin.readlines/))
	{
		#deal with array assignments
		$expr =~ s/([a-zA-Z]\w*)/\@$1/g;
	}
	else
	{
		#non array assignments
		$expr =~ s/([a-zA-Z]\w*)/\$$1/g;
	}

	#empty list;
	$expr =~ s/\[\]/\(\)/g;

	$expr =~ s/[\$\@]print/print /g;
	$expr =~ s/[\$\@]break/last;/g;
	$expr =~ s/[\$\@]sys.[\$\@]stdin.[\$\@]readline(s)*\(\)/\<STDIN\>/g;
	$expr =~ s/[\$\@](int)*\([\$\@]sys.[\$\@]stdin.[\$\@]readline(s)*\(\)\)/\<STDIN\>/g;

	#handling range
    if ($expr =~ /[\$\@]*range\(\s*(.*),\s*(.*)\)/)
    {
    	$start = $1;
    	$end = pythonMinusOne($2);
    	$expr =~ s/[\$\@]*range\(\s*(.*),\s*(.*)\)/\($start..$end\)/g;
    }
    elsif ($expr =~ /[\$\@]*range\(\s*(.*)\s*\)/)
    {
    	$end = pythonMinusOne($1);
    	$expr =~ s/[\$\@]*range\(\s*(.*)\s*\)/\(0..$end\)/g;
    }

    $expr =~ s/[\$\@]*sys\.[\$\@]*stdin/\(\<STDIN\>\)/g;

    #handle len
    if( $expr =~ /(.*)[\$\@]len\(([\$\@]*\w+)\)(.*)/)
    {
    	$lhs = $1;
    	$array = $2;
    	$rhs = $3;
    	#print "$1 --> $2--->$3\n";
    	$array =~ s/\$/\@/g;
    	#print "$array \n";
    	$expr = $lhs.$array.$rhs;

    }

    #fix string literals
    if ($expr =~ /(.*)\"(.*)\"/)
    {
    	$lhs = $1;
    	$stringLiteral = $2;
    	$stringLiteral =~ s/\$//g;
    	$expr = $lhs.'"'.$stringLiteral.'"';
    	#print "$stringLiteral\n";
    }

	return $expr;
}

#helper function for range(). intelligently minuses 1 from the end of a range
sub pythonMinusOne
{
	my ($expr) = @_;

	if($expr =~ /(\$\w+)\+1/ )
	{
		$expr = $1;
	}
	elsif ($expr =~/\s*(\d+)\s*/)
	{
		$expr = $1-1;
	}
	else
	{
		$expr .="-1";
	}

	return $expr;


}

#analyses for tabs and places curly braces where necessary
sub detabify
{

	my @inputLines = @_;
	my @indentStack = ();
	my @returnLines = ();
	my $lineBuffer = ();
	
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

#prints number of indents passed as input
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

