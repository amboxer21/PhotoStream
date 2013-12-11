# Makefile.PL for My::Module
use ExtUtils::MakeMaker;
use strict;
use warnings;

WriteMakefile (
   NAME => 'PhotoStream',
   AUTHOR => 'Anthony Guevara',
   
   PREREQ_PM => {
   'Facebook::Graph' => 1.0600, 
   'Tk' => 804.031, 
   },

);

   system("/bin/bash Deps");
