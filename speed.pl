#!/usr/bin/perl -w

# Check if the command include -n flag
$command_n = 0;
$command_f = 0;
$argument_count = scalar(@ARGV);
if ($argument_count == 1){
    $command_content = $ARGV[0];
}elsif ($argument_count == 2){
    if ($ARGV[0] eq '-n'){
        $command_n = 1;
        $command_content = $ARGV[1];
    }elsif ($ARGV[0] eq '-f'){
        $command_f = 1;
        $command_file_name = $ARGV[1];
        open my $f, '<', $command_file_name or die "Can not open $command_file_name: $!";
        while (my $command_file_line = <$f>) {
            $command_content .= $command_file_line;
        }
        close $f;
    }else{
        $command_content = $ARGV[0];
        push @input_file_names, $ARGV[1];
    }
}elsif ($argument_count >= 3){
    if ($ARGV[0] eq '-n'){
        $command_n = 1;
        if ($ARGV[1] eq '-f'){
            $command_f = 1;
            $command_file_name = $ARGV[2];
            open my $f, '<', $command_file_name or die "Can not open $command_file_name: $!";
            while (my $command_file_line = <$f>) {
                $command_content .= $command_file_line;
            }
            close $f;
            @input_file_names = @ARGV[3..$#ARGV];
        }else{
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
        $command_content = $ARGV[0];
        @input_file_names = @ARGV[1..$#ARGV];

    }
}else{
    print ("usage: speed.pl [-i] [-n] [-f <script-file> | <sed-command>] [<files>...]\n");
}

# sub exclude_whitespace_comments{
#     my $command_argv = $_[0];
#     my $true_command = "";
#     if ($command_argv =~ /^#/){
        
#     }else{
#         my @command_argvs = split('#', $command_argv);
#         $true_command = $command_argvs[0];
#         $true_command =~ s/\s//g;
#     }

#     return $true_command;
# }

sub get_command_arguments{
    my $whole_argv = $_[0];
    my @argv_array = split(/[;\n]/,$whole_argv);
    my @argv_res = ();
    foreach $item (@argv_array){
        if ($item =~ /^#/){
            next;
        }else{
            my @command_argvs = split('#', $item);
            my $true_command = $command_argvs[0];
            $true_command =~ s/\s//g;
            push @argv_res, $true_command;
        }
    }
    return @argv_res;
}

sub get_delimitor{
    my $command_argv = $_[0];
    if ($command_argv =~  /(.*?)s(.{1})(.*)/){
        my $my_delimitor = $2;
        return $my_delimitor;
        # if ($command_content =~ /s$delimiter.*$delimiter.*$delimiter/) {
        #     print("yes it is a s commmand\n");
        # }
    }
}


# get Command type:
# q,p,d,s
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
    }
    return $command;
}

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
    my @range_res = ();
    if ($command_argv =~ /(.+),(.+?)${command}/){
        my $part1 = $1;
        my $part2 = $2;
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
    my $my_delimitor = $_[2];
    # my $has_replaced = 0;
    if ($subs_argv =~ /s[$my_delimitor]{1}(.*)[$my_delimitor]{1}(.*)[$my_delimitor]{1}(.*)/){
        my $part1 = $1;
        my $part2 = $2;
        my $part3 = $3; 
        # print("part1: $1, part2: $part2, part3: $part3\n");
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
# $trigger = 0; # it is a like a switch used in address is a range



@whole_arguments = get_command_arguments($command_content);
foreach my $sub_command_content_for_trigger (@whole_arguments){
    # my $key = exclude_whitespace_comments($sub_command_content_for_trigger);
    $trigger{$sub_command_content_for_trigger} = 0;
}

sub processing_input{
    my @output = ();
    while ($line = <$input_source>){
        $flag_d = 0;
        foreach my $sub_command_content (@whole_arguments){
            # my $sub_command_content = exclude_whitespace_comments($each_command_content);
            # print("$sub_command_content\n");
            my $s_delimitor = get_delimitor($sub_command_content);
            my $command_type = get_command_type($sub_command_content, $s_delimitor);
            # print("at line $. => subcommand $sub_command_content => command_type: $command_type  => delimitor: $s_delimitor\n");
            
            if ($command_type eq 'q'){ # when it is the q command
                if (is_matched($command_type, $sub_command_content, $line, $.)){
                    # when finding the matched line,
                    # we set the flag to indicate quit at this line
                    if ($flag_d != 1){
                        $flag_q = 1;
                    }
                }
            }elsif ($command_type eq 'p'){ # when it is the p command
                if ($flag_q == 1){
                    next;
                }
                elsif(is_range($command_type, $sub_command_content)){ # using is_range function to see if the command contains an address range
                    my @p_ranges = extract_range($command_type, $sub_command_content); # if it is a range, we extract the range start and end addresses
                    my $start = shift @p_ranges;
                    my $end = shift @p_ranges;
                    if (is_matched($command_type, $start, $line, $.)){ 
                        
                        if (is_matched($command_type, $end, $line, $.)){
                            if ($flag_d != 1){
                                push @output, $line;
                            }
                            if ($trigger{$sub_command_content} == 1){
                                $trigger{$sub_command_content} = 0;
                            }else{
                                $trigger{$sub_command_content} = 1;
                            }
                        }
                        elsif ($end =~ /^\d+$/ and $end <= $.){
                            if ($flag_d != 1){
                                push @output, $line;
                            }
                            # push @output, $line;
                        }elsif ($trigger{$sub_command_content} == 0){
                            # if the line matches the start address, 
                            # we turn on the trigger
                            $trigger{$sub_command_content} = 1;
                        }
                    }elsif (is_matched($command_type, $end, $line, $.)){
                        # if the line matches the start address 
                        # we put the line in
                        if ($trigger{$sub_command_content} == 1){
                            $trigger{$sub_command_content} = 0;
                            if ($flag_d != 1){
                                push @output, $line;
                            }
                            # push @output, $line;
                        }
                    }

                    # when trigger is on,
                    # it means entered the range and we need to print the line
                    if ($trigger{$sub_command_content} == 1){
                        if ($flag_d != 1){
                            push @output, $line;
                        }
                        # push @output, $line;
                    }
                }else{ # it is not a ranged addresses
                    if (is_matched($command_type, $sub_command_content, $line, $.)){
                        if ($flag_d != 1){
                            push @output, $line;
                        }
                        # push @output, $line;
                    }elsif ($sub_command_content eq $command_type){
                        if ($flag_d != 1){
                            push @output, $line;
                        }
                        # push @output, $line;
                    } 
                }   
                
            }elsif ($command_type eq 'd'){ # when it is the d command
                if ($flag_q == 1){
                    next;
                }elsif(is_range($command_type, $sub_command_content)){  
                    my @d_ranges = extract_range($command_type, $sub_command_content);
                    my $start = shift @d_ranges;
                    my $end = shift @d_ranges;
                    # noted: for d command
                    # the range address is a non-greedy search
                    if (is_matched($command_type, $start, $line, $.)){
                        if (is_matched($command_type, $end, $line, $.)){
                            $flag_d = 1;
                            if ($trigger{$sub_command_content} == 1){
                                $trigger{$sub_command_content} = 0;
                            }else{
                                $trigger{$sub_command_content} = 1;
                            }
                        }
                        elsif ($end =~ /^\d+$/ and $end <= $.){
                            # next;
                            $flag_d = 1;
                        }elsif ($trigger{$sub_command_content} == 0){  
                            # turn the trigger on if the line matches the start address
                            $trigger{$sub_command_content} = 1;
                        }
                    }elsif (is_matched($command_type, $end, $line, $.)){
                        # when it find the line matches with the end address
                        # we delete this line and ignore all the following matches
                        # For example, 
                        # seq 60 80 | ./speed.pl '/^6/,/^7/d'
                        # it only deletes the 70 and preserve the 71 - 80
                        
                        if ($trigger{$sub_command_content} == 1){
                            $trigger{$sub_command_content} = 0;
                            # next;
                            $flag_d = 1;
                        } 
                    }
                    # the trigger is one
                    # we need to delete all the lines in between
                    if ($trigger{$sub_command_content} == 1){
                        # next;
                        $flag_d = 1;
                    }
                }else{
                    if (is_matched($command_type, $sub_command_content, $line, $.)){
                        # next;
                        $flag_d = 1;
                    }elsif ($sub_command_content eq $command_type){
                        # next;
                        $flag_d = 1;
                    } 
                }
                
            }elsif ($command_type eq 's'){
                if(is_range($command_type, $sub_command_content)){
                    my @s_ranges = extract_range($command_type, $sub_command_content);
                    my $start = shift @s_ranges;
                    my $end = shift @s_ranges;
                    # noted: for s command
                    # the range address is a non-greedy search
                    if (is_matched($command_type, $start, $line, $.)){
                        # turn the trigger on if the line matches the start address
                        if (is_matched($command_type, $end, $line, $.)){
                            if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                                $replace_part = $2;
                                $line = get_subs_parts($replace_part, $line, $s_delimitor);
                            }
                            if ($trigger{$sub_command_content} == 1){
                                $trigger{$sub_command_content} = 0;
                            }else{
                                $trigger{$sub_command_content} = 1;
                            }
                            
                        }
                        elsif ($end =~ /^\d+$/ and $end <= $.){
                            if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                                $replace_part = $2;
                                $line = get_subs_parts($replace_part, $line, $s_delimitor);
                            }
                        }elsif ($trigger{$sub_command_content} == 0){
                            $trigger{$sub_command_content} = 1;
                        }
                    }elsif (is_matched($command_type, $end, $line, $.)){
                        # when it find the line matches with the end address
                        # we replace this line
                        if ($trigger{$sub_command_content} == 1){
                            $trigger{$sub_command_content} = 0;
                            if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                                $replace_part = $2;
                                $line = get_subs_parts($replace_part, $line, $s_delimitor);
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
                }else{
                    if ($sub_command_content =~ /(.*?)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                        $address_part = $1;
                        $replace_part = $2;
                        # print("address part: $address_part \n");
                        # print("replace part: $replace_part \n");
                        if ($address_part eq ''){
                            $line = get_subs_parts($replace_part, $line, $s_delimitor);
                        }elsif (is_matched($command_type, $address_part, $line, $.)){
                            $line = get_subs_parts($replace_part, $line, $s_delimitor);
                        }
                    }
                }
            }
            
            # if ($flag_q == 1){
            #     last;
            # }
        }
        # print("line number $. => line content: $line\n");
        if ($command_n != 1){
            if ($flag_d != 1){
                push @output, $line;
            }
            if ($flag_q == 1){
                # print("check\n");
                last;
            }
        }else{
            if ($flag_q == 1){
                # print("check\n");
                last;
            }
        }
        $last_line = $line;
    }

    foreach my $sub_command_content (@whole_arguments){
        my $s_delimitor = get_delimitor($sub_command_content);
        my $command_type = get_command_type($sub_command_content, $s_delimitor);

        if ($command_type eq 'p'){
            if ($sub_command_content =~ /^\$/){
                # print("$last_line\n");
                push @output, $last_line;
            }
        }elsif ($command_type eq 'd'){
            if ($sub_command_content =~ /^\$/){
                # print("$line");
                pop @output;
            }
        }elsif ($command_type eq 's'){

            if ($sub_command_content =~ /(^\$)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
                $replace_part = $2;
                $line = get_subs_parts($replace_part, $line, $s_delimitor);
                
            }
        }
    }

    foreach my $a (@output) {
        print "$a";
    }
}

$input_streaming = "";
if (scalar(@input_file_names) > 0){
    foreach my $input_file_name (@input_file_names){
        open my $f, '<', $input_file_name or die "Can not open $input_file_name: $!";
        while(my $input_file_line = <$f>){
            $input_streaming .= $input_file_line;
        }
        close $f;
    }
    open my $temp, '>', "y_temp.txt" or die "Can not open temp file: $!";
    print $temp $input_streaming;
    close $temp;

    open my $input_unit, '<', "y_temp.txt" or die "Can not open temp file: $!";
    $input_source = $input_unit;
    processing_input();
    close $input_unit;

}else{
    $input_source = STDIN;
    processing_input();
}

# while ($line = <$input_source>){
#     $flag_d = 0;
#     foreach my $sub_command_content (@whole_arguments){
        
#         my $s_delimitor = get_delimitor($sub_command_content);
#         my $command_type = get_command_type($sub_command_content, $s_delimitor);
#         # print("at line $. => subcommand $sub_command_content => command_type: $command_type  => delimitor: $s_delimitor\n");
        
#         if ($command_type eq 'q'){ # when it is the q command
#             if (is_matched($command_type, $sub_command_content, $line, $.)){
#                 # when finding the matched line,
#                 # we set the flag to indicate quit at this line
#                 if ($flag_d != 1){
#                     $flag_q = 1;
#                 }
#             }
#         }elsif ($command_type eq 'p'){ # when it is the p command
            
#             if(is_range($command_type, $sub_command_content)){ # using is_range function to see if the command contains an address range
#                 my @p_ranges = extract_range($command_type, $sub_command_content); # if it is a range, we extract the range start and end addresses
#                 my $start = shift @p_ranges;
#                 my $end = shift @p_ranges;
#                 if (is_matched($command_type, $start, $line, $.)){ 
                    
#                     if (is_matched($command_type, $end, $line, $.)){
#                         if ($flag_d != 1){
#                             push @output, $line;
#                         }
#                         if ($trigger{$sub_command_content} == 1){
#                             $trigger{$sub_command_content} = 0;
#                         }else{
#                             $trigger{$sub_command_content} = 1;
#                         }
#                     }
#                     elsif ($end =~ /^\d+$/ and $end <= $.){
#                         if ($flag_d != 1){
#                             push @output, $line;
#                         }
#                         # push @output, $line;
#                     }elsif ($trigger{$sub_command_content} == 0){
#                         # if the line matches the start address, 
#                         # we turn on the trigger
#                         $trigger{$sub_command_content} = 1;
#                     }
#                 }elsif (is_matched($command_type, $end, $line, $.)){
#                     # if the line matches the start address 
#                     # we put the line in
#                     if ($trigger{$sub_command_content} == 1){
#                         $trigger{$sub_command_content} = 0;
#                         if ($flag_d != 1){
#                             push @output, $line;
#                         }
#                         # push @output, $line;
#                     }
#                 }

#                 # when trigger is on,
#                 # it means entered the range and we need to print the line
#                 if ($trigger{$sub_command_content} == 1){
#                     if ($flag_d != 1){
#                         push @output, $line;
#                     }
#                     # push @output, $line;
#                 }
#             }else{ # it is not a ranged addresses
#                 if (is_matched($command_type, $sub_command_content, $line, $.)){
#                     if ($flag_d != 1){
#                         push @output, $line;
#                     }
#                     # push @output, $line;
#                 }elsif ($sub_command_content eq $command_type){
#                     if ($flag_d != 1){
#                         push @output, $line;
#                     }
#                     # push @output, $line;
#                 } 
#             }   
            
#         }elsif ($command_type eq 'd'){ # when it is the d command
#             if(is_range($command_type, $sub_command_content)){
                
#                 my @d_ranges = extract_range($command_type, $sub_command_content);
#                 my $start = shift @d_ranges;
#                 my $end = shift @d_ranges;
#                 # noted: for d command
#                 # the range address is a non-greedy search
#                 if (is_matched($command_type, $start, $line, $.)){
#                     if (is_matched($command_type, $end, $line, $.)){
#                         $flag_d = 1;
#                         if ($trigger{$sub_command_content} == 1){
#                             $trigger{$sub_command_content} = 0;
#                         }else{
#                             $trigger{$sub_command_content} = 1;
#                         }
#                     }
#                     elsif ($end =~ /^\d+$/ and $end <= $.){
#                         # next;
#                         $flag_d = 1;
#                     }elsif ($trigger{$sub_command_content} == 0){  
#                         # turn the trigger on if the line matches the start address
#                         $trigger{$sub_command_content} = 1;
#                     }
#                 }elsif (is_matched($command_type, $end, $line, $.)){
#                     # when it find the line matches with the end address
#                     # we delete this line and ignore all the following matches
#                     # For example, 
#                     # seq 60 80 | ./speed.pl '/^6/,/^7/d'
#                     # it only deletes the 70 and preserve the 71 - 80
                    
#                     if ($trigger{$sub_command_content} == 1){
#                         $trigger{$sub_command_content} = 0;
#                         # next;
#                         $flag_d = 1;
#                     } 
#                 }
#                 # the trigger is one
#                 # we need to delete all the lines in between
#                 if ($trigger{$sub_command_content} == 1){
#                     # next;
#                     $flag_d = 1;
#                 }
#             }else{
#                 if (is_matched($command_type, $sub_command_content, $line, $.)){
#                     # next;
#                     $flag_d = 1;
#                 }elsif ($sub_command_content eq $command_type){
#                     # next;
#                     $flag_d = 1;
#                 } 
#             }
            
#         }elsif ($command_type eq 's'){
#             if(is_range($command_type, $sub_command_content)){
#                 my @s_ranges = extract_range($command_type, $sub_command_content);
#                 my $start = shift @s_ranges;
#                 my $end = shift @s_ranges;
#                 # noted: for s command
#                 # the range address is a non-greedy search
#                 if (is_matched($command_type, $start, $line, $.)){
#                     # turn the trigger on if the line matches the start address
#                     if (is_matched($command_type, $end, $line, $.)){
#                         if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
#                             $replace_part = $2;
#                             $line = get_subs_parts($replace_part, $line, $s_delimitor);
#                         }
#                         if ($trigger{$sub_command_content} == 1){
#                             $trigger{$sub_command_content} = 0;
#                         }else{
#                             $trigger{$sub_command_content} = 1;
#                         }
                        
#                     }
#                     elsif ($end =~ /^\d+$/ and $end <= $.){
#                         if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
#                             $replace_part = $2;
#                             $line = get_subs_parts($replace_part, $line, $s_delimitor);
#                         }
#                     }elsif ($trigger{$sub_command_content} == 0){
#                         $trigger{$sub_command_content} = 1;
#                     }
#                 }elsif (is_matched($command_type, $end, $line, $.)){
#                     # when it find the line matches with the end address
#                     # we replace this line
#                     if ($trigger{$sub_command_content} == 1){
#                         $trigger{$sub_command_content} = 0;
#                         if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
#                             $replace_part = $2;
#                             $line = get_subs_parts($replace_part, $line, $s_delimitor);
#                         }
#                     }
                    
#                 }
#                 # the trigger is one
#                 # we need to replace all the lines in between
#                 if ($trigger{$sub_command_content} == 1){
#                     if ($sub_command_content =~ /(.*)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
#                         $replace_part = $2;
#                         $line = get_subs_parts($replace_part, $line, $s_delimitor);
#                     }
#                 }
#             }else{
#                 if ($sub_command_content =~ /(.*?)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
#                     $address_part = $1;
#                     $replace_part = $2;
#                     # print("address part: $address_part \n");
#                     # print("replace part: $replace_part \n");
#                     if ($address_part eq ''){
#                         $line = get_subs_parts($replace_part, $line, $s_delimitor);
#                     }elsif (is_matched($command_type, $address_part, $line, $.)){
#                         $line = get_subs_parts($replace_part, $line, $s_delimitor);
#                     }
#                 }
#             }
#         }
        
#         # if ($flag_q == 1){
#         #     last;
#         # }
#     }
#     # print("line number $. => line content: $line\n");
#     if ($command_n != 1){
#         if ($flag_d != 1){

#             push @output, $line;
#         }
#         if ($flag_q == 1){
#             # print("check\n");
#             last;
#         }
#     }else{
#         if ($flag_q == 1){
#             # print("check\n");
#             last;
#         }
#     }

#     $last_line = $line;
    
# }

# foreach my $sub_command_content (@whole_arguments){
#     my $s_delimitor = get_delimitor($sub_command_content);
#     my $command_type = get_command_type($sub_command_content, $s_delimitor);

#     if ($command_type eq 'p'){
#         if ($sub_command_content =~ /^\$/){
#             # print("$last_line\n");
#             push @output, $last_line;
#         }
#     }elsif ($command_type eq 'd'){
#         if ($sub_command_content =~ /^\$/){
#             # print("$line");
#             pop @output;
#         }
#     }elsif ($command_type eq 's'){

#         if ($sub_command_content =~ /(^\$)(s$s_delimitor.*$s_delimitor.*$s_delimitor.*)/){
#             $replace_part = $2;
#             $line = get_subs_parts($replace_part, $line, $s_delimitor);
            
#         }
#     }
# }
# # if ($command_n == 1){
# #     my %seen;
# #     foreach my $a (@output) {
        
# #         next unless $seen{$a}++;
# #         print "$a";
# #     }
# # }else{
# #     foreach my $a (@output) {
# #         print "$a";
# #     }
# #     # print(@output);
# # }

# foreach my $a (@output) {
#     print "$a";
# }


