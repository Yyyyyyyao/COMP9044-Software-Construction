#!/usr/bin/perl -w

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
    if ($command_argv =~ /(.+),(.+?)${command}/){
        $part1 = $1;
        $part2 = $2;
        push @range_res, $part1;
        push @range_res, $part2;
        return @range_res;
    }
}


$command_content = $ARGV[0];
# @command_content_breaked = split('', $command_content);

if ($command_content =~  /(.*?)s(.{1})(.*)/){
    print("$1, $2, $3 \n");
    $delimiter = $2;
    if ($command_content =~ /s$delimiter.*$delimiter.*$delimiter/) {
        print("yes it is a s commmand\n");
    }
}

if (is_range('s', $command_content)) {
    print("yes it is a range \n");
    @output = extract_range('s', $command_content);
    $start = shift @output;
    $end = shift @output;
    print("from $start to $end\n");
}



# if ($command_content_breaked[-1] eq 'g' ){

    
#     if ($command_content_breaked[-2] eq 'g'){
#         # situation 1: 'sg[ae]gzzzgg'  delimiter: g and having g flag

#     }elsif ($command_content_breaked[-2] ne 'g'){
#         # situation 2: 'sg[ae]gzzzg'   delimiter:g and no g flag
#         # Noted: delimiter not appear in the content
#     }

    
#     # echo sgner sg| 2041 speed 'sXsgXzgXg'

#     # situation 3: 'sX[ae]XzzzXg' delimiter: NOT g and having g flag

#     $delimitor =  $command_content_breaked[-2];
# }else{ 
#     # situation 3: 'sX[ae]XzzzX' delimiter: NOT g and no g flag
#     $delimitor =  $command_content_breaked[-1];
    
# }



