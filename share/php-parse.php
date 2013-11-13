<?php

require 'PHP-Parser/lib/bootstrap.php';

$parser = new PHPParser_Parser(new PHPParser_Lexer);
$ser    = new PHPParser_Serializer_XML ();
$code   = file_get_contents("php://stdin");

print $ser->serialize( $parser->parse($code) );

# That's all folks!
