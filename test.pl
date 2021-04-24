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


print("n: $command_n => f: $command_f  => command: $command_content => input files: @input_file_names\n");