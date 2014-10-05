#!/usr/bin/perl
# Starting point for COMP2041/9041 assignment
# http://www.cse.unsw.edu.au/~cs2041/assignments/python2perl
# written by andrewt@cse.unsw.edu.au September 2014
# edited by Thien Nguyen October 2014


#TODO: Figureout 2's complement

%vartypes = ();

$operators = '\-=\*\+\&\!\|></%^~';
$currIndent = 0;
my @simplifiedPython = detabify(<>);
push @parsedLines, "#!/usr/bin/perl -w\n";
foreach my $input (@simplifiedPython)
{

	$parsedLine = parseLine($input);
	push @parsedLines, $parsedLine;
}

print @parsedLines;

sub parseLine
{
	my ($line) = @_;

	chomp $line;

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
	elsif ($line =~ /^(\s*)([\w\[\]\']+)\s*[$operators].*/)
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
		#print "#string is $string\n";
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
			$expression = parseExpression($2);
			$expression = $expression.",";
			$expression =~ s/;//g;
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
        my $expressions = join(':', @condition_phrase[1..$#condition_phrase]);
        $expressions =~ s/^\s*//g;


        if ($expressions)
        {
        	#case for single line while or if statements
        	#generate curly brace and newlines
        	#remember to indent
        	$line.= generateIndents($currIndent);
        	$line.="\n".$whitespace."{\n";
        	$currIndent++;
       		$line.= $whitespace."\t";

       		#split sub expressions and tread individually
			my @subexpressions = split (';', $expressions);

			foreach  my $subexpr (@subexpressions)
			{
				chomp $subexpr;
				$subexpr =~ s/^\s*//g;
				$expression = parseLine($subexpr);

	            #indenting
	        	$line.= generateIndents($currIndent);
				$line .= "$expression";

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

	$expr = parseVarnames($expr);	


	#empty lists, convert bracetype
	$expr =~ s/\[\]/\(\)/g;

	#special keywords, convert to perl
	$expr =~ s/[\$\@]print/print /g;
	$expr =~ s/[\$\@]break/last;/g;

	#special functions
	$expr =~ s/[\$\@]sys.[\$\@]stdin.[\$\@]readline(s)*\(\)/\<STDIN\>/g;
	$expr =~ s/[\$\@](int)*\([\$\@]sys.[\$\@]stdin.[\$\@]readline(s)*\(\)\)/\<STDIN\>/g;

	#handling range, autoconvert to array
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

    #handle len, auto convert to array
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

    #handle sorted and autoconvert to array
    if ($expr =~ /(.*)=[\$\@]sorted\((.*)\)/)
    {
    	#if expression has sorted function, make sure arguments are converted
    	#to perl style arrays. flip $ and @ and [] with ()
    	my $lhs = $1;
    	my $arg = $2;
    	$lhs =~ s/\$/\@/g;
    	$arg =~ s/\$/\@/g;
    	$arg =~ s/\[/\(/g;
    	$arg =~ s/\]/\)/g;
    	$expr = "$lhs=sort{\$a<=>\$b}($arg)"

    }

    #handling list functions, convert to array and store as array
    $expr =~ s/[\$\@]([a-zA-Z]\w*)=\[(.*)\]/\@$1=\($2\)/g;
    $vartypes{$1} = "array";
    $expr =~ s/[\$\@]([a-zA-Z]\w*).[\$\@]pop\(\)/pop\(\@$1\)/g;
    $vartypes{$1} = "array";

    #fix string literals so that double quotes dont contain variables
    $expr = fixStringLiteral($expr);

    #switch between arrays and hashes using a lookup table
    if ($expr =~ /\$([a-zA-Z]\w*)\[(.*)\]/)
    {
    	my $name = $1;
    	my $index = $2;
    	if ($vartypes{$name} eq "hash")
    	{
    		$expr =~ s/\$([a-zA-Z]\w*)\[(.*)\]/\$$1\{$2\}/g
    	}
    }

    #do a final check of varialbe type. convert arrays or hashes if necessary
    if ($expr =~ /^\$([a-zA-Z]\w+)$/)
	{
		#check variable type 
		$varname = $1;
		if ($vartypes{$varname} eq "hash")
		{
			$expr =~ s/\$/\%/g;
		}
		elsif ($vartypes{$varname} eq "array")
		{
			$expr =~ s/\$/\@/g;
		}

	}

	return $expr;
}

#remove variable names from single and double quotes
sub fixStringLiteral
{
	my ($input) = @_;
	if ($input =~ /(.*)([\"\'])(.*)([\'\"])(.*)/)
    {
    	my $lhs = $1;
    	my $quotemark = $2;
    	
    	my $stringLiteral = $3;
    	my $rhs = $5;

    	#recurse backwards on the line if you need to replace multiples
    	if ($lhs=~ /(.*)([\"\'])(.*)([\'\"])(.*)/)
    	{
    		#print "lhs is $lhs\n";
    		$lhs = fixStringLiteral($lhs);
    	}
    	$stringLiteral =~ s/\$//g;
    	$input = $lhs.$quotemark.$stringLiteral.$quotemark.$rhs;
    	
    }

	return $input;
}


sub parseVarnames
{
	my ($expr) = @_;
	if (($expr =~ /([a-zA-Z]\w*)=range.*/) ||
		($expr =~ /([a-zA-Z]\w*)=sys.stdin.readlines/))
	{
		#deal with array assignments
		$vartypes{$1} = "array";
		$expr =~ s/([a-zA-Z]\w*)/\@$1/g;
	}
	elsif ($expr =~ /([a-zA-Z]\w*)={(.*)}/)
	{
		#dictionary assignments
		$vartypes{$1} = "hash";
		$expr = "\%$1=\($2\)";
		$expr =~ s/\:/,/g;
	}
	else
	{
		#non array assignments
		$expr =~ s/([a-zA-Z]\w*)/\$$1/g;
	}


	


	return $expr

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
		#group all continuous whitespaces into single array
		@tabarray = $tabstring =~ m/^\s+/g;

		#grab first whitespace and count number of whitespaces
		$tabstring = $tabarray[0];
		@tabarray = $tabstring =~ m/(\s)/g;
		$tabspaces = $#tabarray+1;

		$line =~ s/^(\s*)//g;
		
		
		if (!($line =~/^\s*#/) && !($line =~/^\s*$/))
		{

			if ($tabspaces < 0)
			{
				$tabspaces = 0;
			}

			if ($tabspaces > $indentStack[-1] )
			{
				#increase in indent stack, push }
				$lineBuffer .=generateIndents($#indentStack)."{\n";
				push @returnLines, $lineBuffer;
				$lineBuffer = '';
				push @indentStack, $tabspaces;
			}
			elsif ($tabspaces < $indentStack[-1])
			{
				#decrease in indent stack, push }
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

	#place curly braces to de-indent everything
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

