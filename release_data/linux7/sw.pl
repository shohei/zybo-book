#!/usr/bin/perl
print "Content-type: text/html\n\n";
print "read sw cgi start<br>\r\n";
system("/usr/lib/cgi-bin/memread /dev/xillybus_mem_8 0");
print "<br>\r\n";
print "cgi end <br>\r\n";
print "<br>\r\n";
print "<FORM>\r\n";
print " <INPUT type=\"button\" value=\"back to ZYBO control page \" onClick=\"history.back()\">";
print "</FORM>";
