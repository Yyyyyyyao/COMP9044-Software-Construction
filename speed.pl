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

# function to check if it is in range
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


sub is_matched{
    my $command = $_[0];
    my $command_argv = $_[1];
    my $line_content = $_[2];
    my $current_line_number = $_[3];

    if ($command_argv =~ /\/(.*)\/(${command})?/){
        my $regx_to_match = $1;
        if ($line_content =~ /$regx_to_match/){
            return 1;
        }
    }elsif ($command_argv =~ /^(\d+)(${command})?/){
        
        if ($current_line_number == $1){
            return 1;
        }
    }
    return 0;
}

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

$flag_q = 0;
$trigger = 0;
while ($line = <STDIN>){
    if ($command_type eq 'q'){
        if (is_matched($command_type, $command_content, $line, $.)){
            $flag_q = 1;
        }
    }elsif ($command_type eq 'p'){

        if(is_range($command_type, $command_content)){
            @ranges = extract_range($command_type, $command_content);
            $start = shift @ranges;
            $end = shift @ranges;
            
            if (is_matched($command_type, $start, $line, $.)){
                if ($trigger == 0){
                    $trigger = 1;
                }
            }elsif (is_matched($command_type, $end, $line, $.)){
                $trigger = 0;
                push @output, $line;
                
            }

            if ($trigger == 1){
                push @output, $line;
            }
        }else{
            if (is_matched($command_type, $command_content, $line, $.)){
                push @output, $line;
            }elsif ($command_content eq $command_type){
                push @output, $line;
            } 
        }   
        
    }elsif ($command_type eq 'd'){

        if(is_range($command_type, $command_content)){
            @ranges = extract_range($command_type, $command_content);
            $start = shift @ranges;
            $end = shift @ranges;
            
            if (is_matched($command_type, $start, $line, $.)){
                if ($trigger == 0){
                    $trigger = 1;
                }
            }elsif (is_matched($command_type, $end, $line, $.)){
                if ($trigger == 1){
                    $trigger = 0;
                    next;
                }
                
            }

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