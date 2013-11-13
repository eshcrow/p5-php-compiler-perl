=pod

=encoding utf-8

=head1 PURPOSE

Test that PHP::Compiler::Perl works.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

use strict;
use warnings;
use Test::More;

use_ok('PHP::Compiler::Perl');

my $php = q[<?php echo "Hello world"; ?>];
my $xml = PHP::Compiler::Perl->php_to_xml( $php );

is($xml->documentElement->localname, 'AST', 'intermediate XML looks OK');

my $ast = PHP::Compiler::Perl->xml_to_ast( $xml );

isa_ok($ast->[0], 'PHP::Compiler::Perl::AST::Stmt_Echo', '$ast->[0]');

is($ast->[0]->to_perl, 'print("Hello world");', '$ast->[0] serializes to Perl OK');

done_testing;
