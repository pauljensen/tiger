#!/usr/bin/perl -w

open(CATS,$ARGV[1]) || die "cats $!";
open(INDEX,$ARGV[0]) || die "index $!";
while (my $in = <INDEX>) {
   if ($in =~ /<h2>Matlab Directories/) {
      # start
      print "<h2>Matlab Functions by Category</h2>\n";
      while (my $cline = <CATS>) {
         chomp $cline;
         next if ($cline eq "");
         if ($cline =~ /^>/) {
            $cline =~ s/^>//;
            print "</ul><b><font color='#006699'>$cline</b>\n<ul>";
         } else {
            print "<li>" . get_link($cline) . "</li>\n";
         }
      }
      print "</ul></font>\n";
   }
   print $in;
}
      

sub get_link {
   my $name = shift;
   open(INFILE,$ARGV[0]) || die $!;
   while (my $line = <INFILE>) {
      if ($line =~ m!>$name</a!) {
         $line =~ m!(<a[^<>]+>$name</a>)!;
         $rval = $1;
         last;
      }
   }
   close(INFILE);
   return $rval;
}

