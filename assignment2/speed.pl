#!/usr/bin/perl -w

$command_n = 0; # a flag showing whether the commands contains -n
$command_f = 0; # a flag showing whether the commands contains -f
$argument_count = scalar(@ARGV);
if ($argument_count == 1){
    # if there is only one argument, 
    # it can only take the command
    # otherwise, print error messages
    $command_content = $ARGV[0];
    if ($command_content eq '-n' or $command_content eq '-f'){
        print ("usage: speed [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
        exit 1;
    }
}elsif ($argument_count == 2){
    # if there are 2 arguments 
    # either -n + command
    # or -f + commandfile
    # or command + one input files
    if ($ARGV[0] eq '-n'){
        $command_n = 1;
        $command_content = $ARGV[1];
    }elsif ($ARGV[0] eq '-f'){
        $command_f = 1;
        $command_file_name = $ARGV[1];
        open my $f, '<', $command_file_name or print "speed: couldn't open file a: No such file or directory\n" and exit 1;
        while (my $command_file_line = <$f>) {
            $command_content .= $command_file_line;
        }
        close $f;
    }else{
        $command_content = $ARGV[0];
        push @input_file_names, $ARGV[1];
    }
}elsif ($argument_count >= 3){
    # if there are more than 3 arguments
    # Since the command are in order
    # we first check -n, then -f
    if ($ARGV[0] eq '-n'){
        $command_n = 1;
        if ($ARGV[1] eq '-f'){
            $command_f = 1;
            $command_file_name = $ARGV[2];
            # open the command file
            open my $f, '<', $command_file_name or die "Can not open $command_file_name: $!";
            # concatenate the commands in commandfile
            while (my $command_file_line = <$f>) {
                $command_content .= $command_file_line;
            }
            close $f;
            # all the remainings are input files(or stdin)
            @input_file_names = @ARGV[3..$#ARGV];
        }else{
            # if not -f 
            # then it must be the command + inputfiles(or stdin)
            $command_content = $ARGV[1];
            @input_file_names = @ARGV[2..$#ARGV];
        }
    }elsif ($ARGV[0] eq '-f'){
        $command_f = 1;
        $command_file_name = $ARGV[1];
        open my $f, '<', $command_file_name or die "Can not open $command_file_name: $!";
        while (my $command_file_line = <$f>) {
            $command_content .= $command_file_line;
        }
        close $f;
        @input_file_names = @ARGV[2..$#ARGV];
        
    }else{
        # if the command doesnot have -n or -f
        # then it must be command + input files (or stdin)
        $command_content = $ARGV[0];
        @input_file_names = @ARGV[1..$#ARGV];
    }
}else{
    print ("usage: speed.pl [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
    exit 1;
}

# function to get the cleaned commands
# it will clean the white spaces and comments
sub get_command_arguments{
    my $whole_argv = $_[0];
    my @argv_array = split(/[;\n]/,$whole_argv);
    my @argv_res = ();
    foreach $item (@argv_array){
        if ($item =~ /^#/){
            # if the command only have comment,
            # we skip this one
            next;
        }else{
            my @command_argvs = split('#', $item);
            my $true_command = $command_argvs[0];
            $true_command =~ s/\s//g; # replace all whitespaces with empty string
            push @argv_res, $true_command; # push all possible commands into an array and return
        }
    }
    return @argv_res;
}

# funtion to find the delimitor in s command
sub get_delimitor{
    my $command_argv = $_[0];
    if ($command_argv =~  /(.*?)s(.{1})(.*)/){
        my $my_delimitor = $2;
        return $my_delimitor;
    }
}


# function to get Command type:
# q,p,d,s
# return q/p/d/s as result
# print error messages if none of them matched
sub get_command_type{
    my $command_argv = $_[0];
    my $command = '';
    my $my_delimitor = $_[1];
    if ($command_argv =~ /q$/){
        $command = 'q';
    }elsif ($command_argv =~ /p$/){
        $command = 'p';
    }elsif ($command_argv =~ /d$/){
        $command = 'd';
    }elsif ($command_argv =~ /s$my_delimitor.*$my_delimitor.*$my_delimitor/){
        $command = 's';
    }else{
        print ("speed: command line: invalid command\n");
        exit 1;
    }
    return $command;
}

# function to check if there is a range for the command
sub is_range{
    my $command = $_[0];
    my $command_argv = $_[1];
    if ($command_argv =~ /(.*)+,(.*)+${command}/){
        return 1;
    }
    return 0;
}

# function to extract range
# return an array which contains start and end address in order.
sub extract_range{
    my $command = $_[0];
    my $command_argv = $_[1];
    my @range_res = ();
    if ($command_argv =~ /(.+),(.+?)${command}/){
        my $part1 = $1;
        my $part2 = $2;
        push @range_res, $part1;
        push @range_res, $part2;
        return @range_res;
    }
}

# function to check if the current line match the address
# return 1 if it matches, 0 otherwise
sub is_matched{
    my $command = $_[0];
    my $command_argv = $_[1];
    my $line_content = $_[2];
    my $current_line_number = $_[3];
    my $last_line = $_[4];

    if ($command_argv =~ /\/(.*)\/(${command})?/){ # check if matched with the regex address
        my $regx_to_match = $1;
        if ($line_content =~ /$regx_to_match/){
            return 1;
        }
    }elsif ($command_argv =~ /^(\d+)(${command})?/){ # check if matched with the digit address
        if ($current_line_number == $1){
            return 1;
        }
    }elsif (($command_argv =~ /^\$/) and $last_line == 1){ # $ check if matched with the last line
        return 1;
    }
    return 0;
}

# function to extract the replacement parts in s command
# and conduct the replacement in this function 
# return the replaced line
sub get_subs_parts{
    my $subs_argv = $_[0];
    my $line_content = $_[1];
    my $my_delimitor = $_[2];
    # my $has_replaced = 0;
    if ($subs_argv =~ /s[$my_delimitor]{1}(.*)[$my_delimitor]{1}(.*)[$my_delimitor]{1}(.*)/){
        my $part1 = $1; # part to be replaced
        my $part2 = $2; # part to replace with
        my $part3 = $3; # store 'g' if specified
        if ($part3 eq ''){
            $line_content =~ s/$part1/$part2/;
        }elsif ($part3 eq 'g'){
            $line_content =~ s/$part1/$part2/g;
        }else{
            # print error if the s command does not match the correct format
            print("speed: command line: invalid command\n");
            exit 1;
        }
    }
    return $line_content;
}

$flag_q = 0; # a flag to indicate the quit on this line

# it is a like a switch used in address when it contains a range
# each command will have one switch trigger
# if the trigger is 0, it means not in range.
# if the trigger is 1, it means in range.
@whole_arguments = get_command_arguments($command_content);
foreach my $sub_command_content_for_trigger (@whole_arguments){
    # my $key = exclude_whitespace_comments($sub_command_content_for_trigger);
    $trigger{$sub_command_content_for_trigger} = 0;
}

# a function to conduct all the commands on the inputs
# Since we may have different input sources, either from a file or STDIN,
# I make it as a function
sub processing_input{
    my @output = (); # the final output array
    while ($line = <$input_source>){ # read each line
        $flag_d = 0; # a flag to indicate the delete command is operating on this line
        $last_line_flag = eof($input_source); # a flag to indicate it is the last line
        foreach my $sub_command_content (@whole_arguments){ # process each command in order
            # get the possible s delimitor
            my $s_delimitor = get_delimitor($sub_command_content); 
            # get the command type (q/p/d/s)
            my $command_type = get_command_type($sub_command_content, $s_delimitor); 
            
            if ($command_type eq 'q'){ # when it is the q command
                if (is_range($command_type, $sub_command_content)){
                    # command q should not have a range
                    print("speed: command line: invalid command\n");
                    exit 1;
                }elsif (is_matched($command_type, $sub_command_content, $line, $., $last_line_flag)){
                    # when finding the matched line,
                    # we set the flag to indicate quit at this line
                    # the pre-requisite is this line is not deleted in a head
                    if ($flag_d != 1){
                        $flag_q = 1;
                    }
                }
            }elsif ($command_type eq 'p'){ # when it is the p command
                if ($flag_q == 1){
                    # flag_q is on which means the quit command has been done on this linne
                    # we should not do any operation
                    next;
                }elsif(is_range($command_type, $sub_command_content)){ # using is_range function to see if the command contains an address range
                    my @p_ranges = extract_range($command_type, $sub_command_content); # if it is a range, we extract the range start and end addresses
                    my $start = shift @p_ranges;
                    my $end = shift @p_ranges;

                    # if the line matches with the start line
                    if (is_matched($command_type, $start, $line, $., $last_line_flag)){ 
                        
                        # if the line matches with the start and end address at the same time
                        if (is_matched($command_type, $end, $line, $., $last_line_flag)){
                            # if this line is not deleted
                            # we print this line
                            if ($flag_d != 1){
                                push @output, $line;
                            }
                            # And if the turn trigger to the opposite value
                            # which means if the trigger was on, I turn it off because it matches the end address.
                            # if the trigger was off, I turn in on because it matches the start address.
                            if ($trigger{$sub_command_content} == 1){
                                $trigger{$sub_command_content} = 0;
                            }else{
                                $trigger{$sub_command_content} = 1;
                            }
                        }elsif ($end =~ /^\d+$/ and $end <= $.){
                            # special case is that if the end address is a number
                            # And we have already passed the end address
                            # we only print the current line
                            # because there is no end address
                            # (if this line is not deleted)

                            # e.g. seq 1 10 | 2041 speed '/5/,3p'
                            # we should only print the 5
                            if ($flag_d != 1){
                                push @output, $line;
                            }
                        }else{
                            # if the start address is a number
                            # we turn the trigger on once the line reaches
                            # if the start address is a regex
                            # we only turn the trigger on if the line is there which is not deleted
                            if ($start =~ /^\d+$/){
                                if ($trigger{$sub_command_content} == 0){
                                    $trigger{$sub_command_content} = 1;
                                }
                            }else{
                                if ($flag_d == 1){
                                    $trigger{$sub_command_content} = 0;
                                }else{
                                    $trigger{$sub_command_content} = 1;
                                }
                            }
                        }
                    }elsif (is_matched($command_type, $end, $line, $., $last_line_flag)){
                        # if the line matches the end address 
                        # and the trigger is on, I shall print the line and after printing, turn the trigger off

                        # if the trigger is off, and it matches the end address
                        # I should do nothing because the command does not start

                        #e.g. seq 1 5 | 2041 speed '/6/,3p'
                        if ($trigger{$sub_command_content} == 1){
                            if ($flag_d != 1){
                                push @output, $line;
                                $trigger{$sub_command_content} = 0;
                            }
                            if ($end =~ /^\d+$/){
                                # if the end address is a number
                                # I turn off the trigger anyway
                                $trigger{$sub_command_content} = 0;
                            }else{
                                # if the end address is a regex
                                # I only turn off the trigger if the line is not deleted
                                if ($flag_d == 1){
                                    $trigger{$sub_command_content} = 1;
                                }else{
                                    $trigger{$sub_command_content} = 0;
                                }
                            }
                        }
                    }
                    # when trigger is on,
                    # it means entered the range and we need to print the line
                    if ($trigger{$sub_command_content} == 1){
                        if ($flag_d != 1){
                            push @output, $line;
                        }
                    }
                }else{ # the command does not have a ranged addresses
                    if (is_matched($command_type, $sub_command_content, $line, $., $last_line_flag)){
                        # print the line if matched and not deleted
                        if ($flag_d != 1){
                            push @output, $line;
                        }
                    }elsif ($sub_command_content eq $command_type){
                        # if command is a single p
                        # I should print all lines if they are not deleted
                        if ($flag_d != 1){
                            push @output, $line;
                        }
                    } 
                }   
                
            }elsif ($command_type eq 'd'){ # when it is the d command
                if ($flag_q == 1){
                    next;
                }elsif(is_range($command_type, $sub_command_content)){  
                    my @d_ranges = extract_range($command_type, $sub_command_content);
                    my $start = shift @d_ranges;
                    my $end = shift @d_ranges;
                    
                    if (is_matched($command_type, $start, $line, $., $last_line_flag)){
                        # if matched the start line
                        if (is_matched($command_type, $end, $line, $., $last_line_flag)){
                            # if matched the start and last line at the same time
                            # I set the flag_d because this line needs to be deleted
                            $flag_d = 1;
                            # toggle the trigger
                            if ($trigger{$sub_command_content} == 1){
                                $trigger{$sub_command_content} = 0;
                            }else{
                                $trigger{$sub_command_content} = 1;
                            }
                        }elsif ($end =~ /^\d+$/ and $end <= $.){
                            # Similar to print, 
                            # when the end address is a number,
                            # check if the start has already passed the end line or equal
                            # if yes, only delete this line
                            $flag_d = 1;
                        }elsif ($trigger{$sub_command_content} == 0){
                            # turn the trigger on if the line matches the start address
                            $trigger{$sub_command_content} = 1;
                        }
                    }elsif (is_matched($command_type, $end, $line, $., $last_line_flag)){
                        # if the line matches with the end address
                        # turn the switch off
                        # if the switch is not turn on, we just ignore
                        if ($trigger{$sub_command_content} == 1){
                            $trigger{$sub_command_content} = 0;
                            $flag_d = 1;
                        } 
                    }
                    # the trigger is one
                    # we need to delete all the lines in between
                    if ($trigger{$sub_command_content} == 1){
                        $flag_d = 1;
                    }
                }else{ # if the commands does not have a range address
                    if (is_matched($command_type, $sub_command_content, $line, $., $last_line_flag)){
                        # delete the match line
                        $flag_d = 1;
                    }elsif ($sub_command_content eq $command_type){
                        # if the command is 'd', we delete all the lines
                        $flag_d = 1;
                    } 
                }
                
            }elsif ($command_type eq 's'){ # when it is s command
                if(is_range($command_type, $sub_command_content)){ # if it is a range address
                    my @s_ranges = extract_range($command_type, $sub_command_content);
                    my $start = shift @s_ranges;
                    my $end = shift @s_ranges;

                    if (is_matched($command_type, $start, $line, $., $last_line_flag)){
                        # turn the trigger on if the line matches the start address

                        # Similar to print
                        if (is_matched($command_type, $end, $line, $., $last_line_flag)){
                            if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                                $replace_part = $2;
                                $line = get_subs_parts($replace_part, $line, $s_delimitor);
                            }
                            # toggle the trigger 
                            # if both start and end match at the same line
                            if ($trigger{$sub_command_content} == 1){
                                $trigger{$sub_command_content} = 0;
                            }else{
                                $trigger{$sub_command_content} = 1;
                            }
                            
                        }elsif ($end =~ /^\d+$/ and $end <= $.){
                            # if end address is a number
                            # we only substitue this line only
                            if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                                $replace_part = $2;
                                $line = get_subs_parts($replace_part, $line, $s_delimitor);
                            }
                        }else{
                            if ($start =~ /^\d+$/){
                                # if the start is a number,
                                # we turn the trigger anyway
                                if ($trigger{$sub_command_content} == 0){
                                    $trigger{$sub_command_content} = 1;
                                }
                            }else{
                                # if the start is a regex
                                # we only turn on the trigger if the line is not deleted
                                if ($flag_d == 1){
                                    $trigger{$sub_command_content} = 0;
                                }else{
                                    $trigger{$sub_command_content} = 1;
                                }
                            }
                        }
                        
                    }elsif (is_matched($command_type, $end, $line, $., $last_line_flag)){
                        # line matches the end address
                        if ($trigger{$sub_command_content} == 1){
                            if ($end =~ /^\d+$/){
                                # if the end address is a number
                                # we substitute the line and turn off the trigger anyway
                                $trigger{$sub_command_content} = 0;
                                if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                                    $replace_part = $2;
                                    $line = get_subs_parts($replace_part, $line, $s_delimitor);
                                }
                            }else{
                                #if the end address is a regex
                                # we only substitute the line and turn off the trigger if the line is not deleted
                                if ($flag_d == 1){
                                    $trigger{$sub_command_content} = 1;
                                }else{
                                    $trigger{$sub_command_content} = 0;
                                    if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                                        $replace_part = $2;
                                        $line = get_subs_parts($replace_part, $line, $s_delimitor);
                                    }
                                }
                            }
                        }


                        
                    }
                    # the trigger is one
                    # we need to replace all the lines in between
                    if ($trigger{$sub_command_content} == 1){
                        if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                            $replace_part = $2;
                            $line = get_subs_parts($replace_part, $line, $s_delimitor);
                        }
                    }
                }else{ # the command does not have a range address
                    if ($sub_command_content =~ /(.*?)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                        # substitue if matches
                        $address_part = $1;
                        $replace_part = $2;
                        if ($address_part eq ''){
                            $line = get_subs_parts($replace_part, $line, $s_delimitor);
                        }elsif (is_matched($command_type, $address_part, $line, $., $last_line_flag)){
                            $line = get_subs_parts($replace_part, $line, $s_delimitor);
                        }
                    }
                }
            }
        }
        
        if ($command_n != 1){
            # if -n command not exist
            # I should output the command
            if ($flag_d != 1){
                push @output, $line;
            }
            if ($flag_q == 1){
                # quit is the flag_q poped
                last;
            }
        }else{
            # if -n command exists
            # I doesnot push anything
            # because only can p command pushes lines
            if ($flag_q == 1){
                # quit is the flag_q poped
                last;
            }
        }
    }
    # print all final results
    foreach my $a (@output) {
        print "$a";
    }
}

$input_streaming = ""; # a string to store the lines in all input files
if (scalar(@input_file_names) > 0){
    # if having input files,
    # I open all input files and concatenate all lines into input_steaming
    foreach my $input_file_name (@input_file_names){
        open my $f, '<', $input_file_name or print "speed: error\n" and exit 1;
        while(my $input_file_line = <$f>){
            $input_streaming .= $input_file_line;
        }
        close $f;
    }

    # Store the input_streaming into a temp file
    open my $temp, '>', "y_temp.txt" or print "speed: error\n" and exit 1;
    print $temp $input_streaming;
    close $temp;

    # read the temp file and do all operations
    open my $input_unit, '<', "y_temp.txt" or print "speed: error\n" and exit 1;
    $input_source = $input_unit;
    processing_input();
    close $input_unit;

}else{
    # if no input files,
    # read from STDIN
    $input_source = STDIN;
    processing_input();
}



