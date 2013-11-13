package PHP::Compiler::Perl::AST;
use B ();
use Moops;

my $Node;

my $DEBUG; BEGIN { $DEBUG = sub { use Data::Dumper; die Dumper(@_) } };

role Node
{
	has _startLine => (is => 'ro', isa => Int);
	has _endLine => (is => 'ro', isa => Int);
	
	method to_perl ()
	{
		confess("No serialization for $self");
	}
	
	$Node = ConsumerOf[__PACKAGE__];
}

role Expr with Node;

class Expr_Print with Expr {
	has expr => (is => 'ro', isa => $Node);
	
	method to_perl ()
	{
		sprintf('print(%s);', $self->expr->to_perl());
	}
}

role Expr_Infix with Expr
{
	has left  => (is => 'ro', isa => $Node);
	has right => (is => 'ro', isa => $Node);
	
	requires 'symbol';
	
	method to_perl ()
	{
		sprintf('(%s) %s (%s)', $self->left->to_perl, $self->symbol, $self->right->to_perl);
	}
}

# PHP's boolean 'and' and 'or' operators return booleans.
role Expr_Infix_CastToBool with Expr_Infix
{
	around to_perl ()
	{
		sprintf('!!(%s)', $self->${^NEXT}(@_));
	}
}

class Expr_BooleanAnd with Expr_Infix_CastToBool { define symbol = "&&" }
class Expr_BooleanOr  with Expr_Infix_CastToBool { define symbol = "||" }
class Expr_Plus       with Expr_Infix { define symbol = "+" }
class Expr_Minus      with Expr_Infix { define symbol = "-" }
class Expr_Mul        with Expr_Infix { define symbol = "*" }
class Expr_Div        with Expr_Infix { define symbol = "/" }
class Expr_Mod        with Expr_Infix { define symbol = "%" }
class Expr_Concat     with Expr_Infix { define symbol = "." }

role Expr_Prefix with Expr
{
	has expr => (is => 'ro', isa => $Node);
	
	requires 'symbol';
	
	method to_perl ()
	{
		sprintf('%s(%s)', $self->symbol, $self->expr->to_perl);
	}
}

class Expr_BooleanNot  with Expr_Prefix { define symbol = "!" }
class Expr_UnaryPlus   with Expr_Prefix { define symbol = "+" }
class Expr_UnaryMinus  with Expr_Prefix { define symbol = "-" }
class Expr_PreInc      with Expr_Prefix { define symbol = "++" }
class Expr_PreDec      with Expr_Prefix { define symbol = "--" }
class Expr_Cast_Bool   with Expr_Prefix { define symbol = "!!" }
class Expr_Cast_Double with Expr_Prefix { define symbol = "0+" }

class Expr_Cast_Int with Expr
{
	has expr => (is => 'ro', isa => $Node);
	method to_perl ()
	{
		sprintf('int(%s)', $self->expr->to_perl);
	}	
}

role Expr_Suffix with Expr
{
	has expr => (is => 'ro', isa => $Node);
	
	requires 'symbol';
	
	method to_perl ()
	{
		sprintf('(%s)%s', $self->expr->to_perl, $self->symbol);
	}
}

class Expr_PostInc with Expr_Suffix { define symbol = "++" }
class Expr_PostDec with Expr_Suffix { define symbol = "--" }

role Scalar with Node;

role Scalar_Value with Scalar
{
	has value => (is => 'ro', isa => Str);
	
	method to_perl ()
	{
		$self->value;
	}
}

class Scalar_LNumber with Scalar_Value;
class Scalar_DNumber with Scalar_Value;

class Scalar_String with Scalar_Value
{
	method to_perl ()
	{
		B::perlstring($self->value);
	}
}

class Stmt_Echo with Stmt
{
	has exprs => (is => 'ro', isa => ArrayRef[$Node]);
	
	method to_perl ()
	{
		sprintf('print(%s);', join q[, ], map $_->to_perl(), @{$self->exprs});
	}
}

class Stmt_InlineHTML with Stmt
{
	has value => (is => 'ro', isa => Str);
	
	method to_perl ()
	{
		sprintf('print(%s);', B::perlstring($self->value));
	}
}

class Stmt_If with Stmt
{
	has cond    => (is => 'ro');
	has stmts   => (is => 'ro', isa => ArrayRef);
	has elseifs => (is => 'ro', isa => ArrayRef);
	has else    => (is => 'ro');
	
	method to_perl ()
	{
		my $r = sprintf(
			'if (%s) { %s }',
			$self->cond->to_perl(),
			join(q[], map $_->to_perl(), @{$self->stmts}),
		);
		
		for my $e (@{ $self->elseifs })
		{
			$r .= sprintf(
				' elsif (%s) { %s }',
				$e->cond->to_perl(),
				join(q[], map $_->to_perl(), @{$e->stmts}),
			);
		}
		
		if (my $e = $self->else)
		{
			$r .= sprintf(
				' else { %s }',
				join(q[], map $_->to_perl(), @{$e->stmts}),
			);
		}
	}
}

class Stmt_ElseIf with Stmt
{
	has cond    => (is => 'ro');
	has stmts   => (is => 'ro', isa => ArrayRef);
}

class Stmt_Else with Stmt
{
	has stmts   => (is => 'ro', isa => ArrayRef);
}

## TODO
#
# Arg
# Const
# Expr_ArrayDimFetch
# Expr_ArrayItem
# Expr_Array
# Expr_AssignBitwiseAnd
# Expr_AssignBitwiseOr
# Expr_AssignBitwiseXor
# Expr_AssignConcat
# Expr_AssignDiv
# Expr_AssignMinus
# Expr_AssignMod
# Expr_AssignMul
# Expr_Assign
# Expr_AssignPlus
# Expr_AssignRef
# Expr_AssignShiftLeft
# Expr_AssignShiftRight
# Expr_BitwiseAnd
# Expr_BitwiseNot
# Expr_BitwiseOr
# Expr_BitwiseXor
# Expr_Cast_Array
# Expr_Cast_Object
# Expr_Cast
# Expr_Cast_String
# Expr_Cast_Unset
# Expr_ClassConstFetch
# Expr_Clone
# Expr_Closure
# Expr_ClosureUse
# Expr_ConstFetch
# Expr_Empty
# Expr_Equal
# Expr_ErrorSuppress
# Expr_Eval
# Expr_Exit
# Expr_FuncCall
# Expr_GreaterOrEqual
# Expr_Greater
# Expr_Identical
# Expr_Include
# Expr_Instanceof
# Expr_Isset
# Expr_List
# Expr_LogicalAnd
# Expr_LogicalOr
# Expr_LogicalXor
# Expr_MethodCall
# Expr_Mod
# Expr_New
# Expr_NotEqual
# Expr_NotIdentical
# Expr_PropertyFetch
# Expr_ShellExec
# Expr_ShiftLeft
# Expr_ShiftRight
# Expr_SmallerOrEqual
# Expr_Smaller
# Expr_StaticCall
# Expr_StaticPropertyFetch
# Expr_Ternary
# Expr_Variable
# Expr_Yield
# Name_FullyQualified
# Name
# Name_Relative
# Param
# Scalar_ClassConst
# Scalar_DirConst
# Scalar_Encapsed
# Scalar_FileConst
# Scalar_FuncConst
# Scalar_LineConst
# Scalar_MethodConst
# Scalar_NSConst
# Scalar_TraitConst
# Stmt_Break
# Stmt_Case
# Stmt_Catch
# Stmt_ClassConst
# Stmt_ClassMethod
# Stmt_Class
# Stmt_Const
# Stmt_Continue
# Stmt_DeclareDeclare
# Stmt_Declare
# Stmt_Do
# Stmt_Foreach
# Stmt_For
# Stmt_Function
# Stmt_Global
# Stmt_Goto
# Stmt_HaltCompiler
# Stmt_Interface
# Stmt_Label
# Stmt_Namespace
# Stmt_Property
# Stmt_PropertyProperty
# Stmt_Return
# Stmt_Static
# Stmt_StaticVar
# Stmt_Switch
# Stmt_Throw
# Stmt_Trait
# Stmt_TraitUseAdaptation_Alias
# Stmt_TraitUseAdaptation
# Stmt_TraitUseAdaptation_Precedence
# Stmt_TraitUse
# Stmt_TryCatch
# Stmt_Unset
# Stmt_Use
# Stmt_UseUse
# Stmt_While

