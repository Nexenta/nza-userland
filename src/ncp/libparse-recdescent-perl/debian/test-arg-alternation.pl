#! /usr/bin/perl -sw

use Parse::RecDescent;

$grammar =
q{
        main   : foo[ "ok" ]
        foo    : (token1[ $arg[0] ])(s /\|/)
        token1 : 'a'
                 {print "$arg[0]\n"}
};

$parse = new Parse::RecDescent ($grammar);

defined $parse->main('a | a') 
  or die "Arguments being passed to either implicit or alternations are lost";
