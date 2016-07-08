#!/usr/bin/perl
$buffer = $ENV{'QUERY_STRING'};             #
($arg1,$arg2,$arg3,$arg4) = split( /&/ , $buffer );     #
($name1,$value1) = split( /=/ , $arg1 );    #
$value1 =~ tr/+/ /;                         #
print "Content-type: text/html\n\n";        #
print "led_matrix cgi start <br> \r\n";
print "p1 = $name1 $value1 <br>\r\n";
if($value1==0){
system("/usr/lib/cgi-bin/led_matrix_bmp_rd /dev/xillybus_write_32 test_1.bmp");
}
elsif($value1==1){
system("/usr/lib/cgi-bin/led_matrix_bmp_rd /dev/xillybus_write_32 red.bmp");
}
elsif($value1==2){
system("/usr/lib/cgi-bin/led_matrix_bmp_rd /dev/xillybus_write_32 green.bmp");
}
elsif($value1==3){
system("/usr/lib/cgi-bin/led_matrix_bmp_rd /dev/xillybus_write_32 blue.bmp");
}
else{
system("/usr/lib/cgi-bin/led_matrix_off /dev/xillybus_write_32 ");
}
print "cgi end<br> \r\n";
print "<br>\r\n";
print "<FORM>\r\n";
print " <INPUT type=\"button\" value=\"back to ZYBO control page \" onClick=\"history.back()\">";
print "</FORM>";
