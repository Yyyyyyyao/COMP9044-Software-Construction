
# $. marks the current line number it read to 

if ($address =~ / s\/(.*)\/(.*)\/ /){
    $part1 = $1;
    $part2 = $2;

}elsif ($. == $address){

}


# '/^s/s/e/g/g'
