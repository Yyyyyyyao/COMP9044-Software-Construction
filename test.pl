#!/usr/bin/perl -w

@option = @ARGV;

sub is_range{

    my $command = $_[0];
    my $command_argv = $_[1];
    print($command_argv);
    if ($command_argv =~ /(.*)+,(.*)+${command}/){
        return 1;
    }
    return 0;
}


sub extract_range{

    my $command = $_[0];
    my $command_argv = $_[1];
    if ($command_argv =~ /(.+),(.+)${command}/){
        $part1 = $1;
        $part2 = $2;
        push @output, $part1;
        push @output, $part2;
        print("from $part1 to $part2 \n");
        return @output;
    }
}

$command_type = 's';
$command_content = $option[0];

if (is_range($command_type, $command_content)){
    @range = extract_range($command_type, $command_content);
    print("from $range[0] to $range[1] \n");
}else{
    print("not in range\n");
}

    