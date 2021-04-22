#!/usr/bin/perl -w

# get Command type:
# q,p,d,s
sub get_command_type{
    my $command_argv = $_[0];
    my $command = '';
    if ($command_argv =~ /q$/){
        $command = 'q';
    }elsif ($command_argv =~ /p$/){
        $command = 'p';
    }elsif ($command_argv =~ /d$/){
        $command = 'd';
    }elsif ($command_argv =~ /s\/.*\/.*\//){
        $command = 's';
    }
    return $command;
}

# Check if the command include -n flag
$command_n = 0;
$argument_count = scalar(@ARGV);
if ($argument_count == 1){
    $command_content = $ARGV[0];
} elsif ($argument_count == 2){
    $command_n = 1;
    $command_content = $ARGV[1];
}
$command_type = get_command_type($command_content);

# function to check if it is in range for a command
sub is_range{
    my $command = $_[0];
    my $command_argv = $_[1];
    if ($command_argv =~ /(.*)+,(.*)+${command}/){
        return 1;
    }
    return 0;
}

# function to extract range
sub extract_range{

    my $command = $_[0];
    my $command_argv = $_[1];
    if ($command_argv =~ /(.+),(.+)${command}/){
        $part1 = $1;
        $part2 = $2;
        push @range_res, $part1;
        push @range_res, $part2;
        return @range_res;
    }
}

# to check if a line is match with the address
sub is_matched{
    my $command = $_[0];
    my $command_argv = $_[1];
    my $line_content = $_[2];
    my $current_line_number = $_[3];

    if ($command_argv =~ /\/(.*)\/(${command})?/){ # check if matched with the regex address
        my $regx_to_match = $1;
        if ($line_content =~ /$regx_to_match/){
            return 1;
        }
    }elsif ($command_argv =~ /^(\d+)(${command})?/){ # check if matched with the digit address
        if ($current_line_number == $1){
            return 1;
        }
    }
    return 0;
}

# extract the replacement parts in s command
# and conduct the replacement in this function 
# return the replaced line
sub get_subs_parts{
    my $subs_argv = $_[0];
    my $line_content = $_[1];
    # my $has_replaced = 0;
    if ($subs_argv =~ /s\/(.*)\/(.*)\/(.*)/){
        $part1 = $1;
        $part2 = $2;
        $part3 = $3; 
        if ($part3 eq ''){
            $line_content =~ s/$part1/$part2/;
            # print("$line_content");
            # $has_replaced = 1;
        }else{
            $line_content =~ s/$part1/$part2/g;
            # print("$line_content");
            # $has_replaced = 1;
        }
    }
    return $line_content;
}

$flag_q = 0; # a flag to indicate the quit on this line
$trigger = 0; # it is a like a switch used in address is a range
while ($line = <STDIN>){
    if ($command_type eq 'q'){ # when it is the q command
        if (is_matched($command_type, $command_content, $line, $.)){
            # when finding the matched line,
            # we set the flag to indicate quit at this line
            $flag_q = 1;
        }
    }elsif ($command_type eq 'p'){ # when it is the p command
        if(is_range($command_type, $command_content)){ # using is_range function to see if the command contains an address range
            @ranges = extract_range($command_type, $command_content); # if it is a range, we extract the range start and end addresses
            $start = shift @ranges;
            $end = shift @ranges;
            
            # noted:
            # for the print command, we find the longest pair
            # which is a greedy search
            if (is_matched($command_type, $start, $line, $.)){ 
                # if the line matches the start address, 
                # we turn on the trigger
                if ($trigger == 0){
                    $trigger = 1;
                }
            }elsif (is_matched($command_type, $end, $line, $.)){
                # if the line matches the start address 
                # we put the line in
                $trigger = 0;
                push @output, $line;
                
            }

            # when trigger is on,
            # it means entered the range and we need to print the line
            if ($trigger == 1){
                push @output, $line;
            }
        }else{ # it is not a ranged addresses
            if (is_matched($command_type, $command_content, $line, $.)){
                push @output, $line;
            }elsif ($command_content eq $command_type){
                push @output, $line;
            } 
        }   
        
    }elsif ($command_type eq 'd'){ # when it is the d command

        if(is_range($command_type, $command_content)){
            @ranges = extract_range($command_type, $command_content);
            $start = shift @ranges;
            $end = shift @ranges;
            
            # noted: for d command
            # the range address is a non-greedy search
            if (is_matched($command_type, $start, $line, $.)){
                # turn the trigger on if the line matches the start address
                if ($trigger == 0){
                    $trigger = 1;
                }
            }elsif (is_matched($command_type, $end, $line, $.)){
                # when it find the line matches with the end address
                # we delete this line and ignore all the following matches
                # For example, 
                # seq 60 80 | ./speed.pl '/^6/,/^7/d'
                # it only deletes the 70 and preserve the 71 - 80
                if ($trigger == 1){
                    $trigger = 0;
                    next;
                }
                
            }

            # the trigger is one
            # we need to delete all the lines in between
            if ($trigger == 1){
                next;
            }
        }else{
            if (is_matched($command_type, $command_content, $line, $.)){
                next;
            }
        }
        
    }elsif ($command_type eq 's'){
        if ($command_content =~ /(.*)(s\/.*\/.*\/.*)/){
            $address_part = $1;
            $replace_part = $2;
            if ($address_part eq ''){
                $line = get_subs_parts($replace_part, $line);
            }elsif (is_matched($command_type, $address_part, $line, $.)){
                $line = get_subs_parts($replace_part, $line);
            }
        }
    }

    push @output, $line;
    if ($flag_q == 1){
        last;
    }
    
}

if ($command_type eq 'p'){
    if ($command_content =~ /^\$/){
        # print("$line");
        push @output, $output[-1];
    }
}elsif ($command_type eq 'd'){
    if ($command_content =~ /^\$/){
        # print("$line");
        pop @output;
    }
}elsif ($command_type eq 's'){

    if ($command_content =~ /(^\$)(s\/.*\/.*\/.*)/){
        $replace_part = $2;
        $line = get_subs_parts($replace_part, $line);
        
    }
}

if ($command_n == 1){
    my %seen;
    foreach my $a (@output) {
        next unless $seen{$a}++;
        print "$a";
    }
}else{
    print(@output);
}
