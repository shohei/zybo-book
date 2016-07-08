#!/usr/bin/perl
$buffer = $ENV{'QUERY_STRING'};             #
($arg1,$arg2,$arg3,$arg4) = split( /&/ , $buffer );     #
($name1,$value1) = split( /=/ , $arg1 );    #
($name2,$value2) = split( /=/ , $arg2 );    #
($name3,$value3) = split( /=/ , $arg3 );    #
($name4,$value4) = split( /=/ , $arg4 );    #
$value1 =~ tr/+/ /;                         #
$value2 =~ tr/+/ /;                         #
print "Content-type: text/html\n\n";        #
print "<br> \r\n";
print "LED cgi strat <br>\r\n";
print "p1 = $name1 $value1 <br>\r\n";
print "p2 = $name2 $value2 <br>\r\n";
print "p3 = $name3 $value3 <br>\r\n";
print "p4 = $name4 $value4 <br>\r\n";
$val= $value1 + $value2*2 + $value3*4 + $value4*8;
print "led value = $val <br>\r\n";
system("/usr/lib/cgi-bin/memwrite /dev/xillybus_mem_8 0 $val");
print "cgi end <br>\r\n";
print "<br>\r\n";
print "<FORM>\r\n";
print " <INPUT type=\"button\" value=\"back to ZYBO control page \" onClick=\"history.back()\">";
print "</FORM>";
