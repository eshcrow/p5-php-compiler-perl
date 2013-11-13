use 5.010001;
use strict;
use warnings;

package PHP::Compiler::Perl;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.001';

use IPC::Open2 qw(open2);
use PHP::Compiler::Perl::AST;
use XML::LibXML 2;

our @ExtParser = ('php', 'share/php-parse.php');

sub php_to_ast
{
	my $class = shift;
	$class->xml_to_ast( $class->php_to_xml(@_) );
}

sub php_to_xml
{
	my $class = shift;
	my ($php) = @_;
	
	my ($OUT, $IN);
	my $pid = open2($OUT, $IN, @ExtParser)
		or die "Could not execute external parser: $!";
	print {$IN} $php, "\n";
	close($IN);
	my $xml = XML::LibXML->load_xml(IO => $OUT);
	waitpid($pid, 0);
	return $xml;
}

sub xml_to_ast
{
	my $class = shift;
	my ($node) = @_;
	
	$node = $node->documentElement if $node->nodeName eq '#document';
	
	if ($node->localname eq 'AST' and not defined $node->namespaceURI)
	{
		return $class->xml_to_ast( $node->getChildrenByTagName('*')->[0] );
	}
	
	if ($node->namespaceURI eq "http://nikic.github.com/PHPParser/XML/scalar")
	{
		if ($node->localname eq 'array')
		{
			return [ map $class->xml_to_ast($_), $node->getChildrenByTagName('*') ];
		}
		return $node->textContent;
	}
	
	if ($node->namespaceURI eq "http://nikic.github.com/PHPParser/XML/node")
	{
		my $node_class = sprintf('PHP::Compiler::Perl::AST::%s', $node->localname);
		my %params     = map $class->xml_to_ast($_), $node->getChildrenByTagName('*');
		
		return $node_class->new(%params);
	}
	
	if ($node->namespaceURI eq "http://nikic.github.com/PHPParser/XML/attribute")
	{
		my $name  = sprintf('_%s', $node->localname);
		my $value = $class->xml_to_ast( $node->getChildrenByTagName('*')->[0] );
		return $name, $value;
	}
	
	if ($node->namespaceURI eq "http://nikic.github.com/PHPParser/XML/subNode")
	{
		my $name  = sprintf('%s', $node->localname);
		my $value = $class->xml_to_ast( $node->getChildrenByTagName('*')->[0] );
		return $name, $value;
	}
	
	die "UNRECOGNISED XML! $node";
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

PHP::Compiler::Perl - a module that does something-or-other

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=PHP-Compiler-Perl>.

=head1 SEE ALSO

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

