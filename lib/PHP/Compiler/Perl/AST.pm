package PHP::Compiler::Perl::AST;
use B ();
use Moops;

my $Node;

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

role Scalar with Node;

class Scalar_String with Scalar
{
	has value => (is => 'ro', isa => Str);
	
	method to_perl ()
	{
		B::perlstring($self->value);
	}
}

class Scalar_LNumber with Scalar
{
	has value => (is => 'ro', isa => Str);
	
	method to_perl ()
	{
		$self->value;
	}
}

role Stmt with Node;

class Stmt_Echo with Stmt
{
	has exprs => (is => 'ro', isa => ArrayRef[$Node]);
	
	method to_perl ()
	{
		sprintf('print(%s);', join q[, ], map $_->to_perl(), @{$self->exprs});
	}
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
# Expr_BooleanAnd
# Expr_BooleanNot
# Expr_BooleanOr
# Expr_Cast_Array
# Expr_Cast_Bool
# Expr_Cast_Double
# Expr_Cast_Int
# Expr_Cast_Object
# Expr_Cast
# Expr_Cast_String
# Expr_Cast_Unset
# Expr_ClassConstFetch
# Expr_Clone
# Expr_Closure
# Expr_ClosureUse
# Expr_Concat
# Expr_ConstFetch
# Expr_Div
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
# Expr_Minus
# Expr_Mod
# Expr_Mul
# Expr_New
# Expr_NotEqual
# Expr_NotIdentical
# Expr
# Expr_Plus
# Expr_PostDec
# Expr_PostInc
# Expr_PreDec
# Expr_PreInc
# Expr_PropertyFetch
# Expr_ShellExec
# Expr_ShiftLeft
# Expr_ShiftRight
# Expr_SmallerOrEqual
# Expr_Smaller
# Expr_StaticCall
# Expr_StaticPropertyFetch
# Expr_Ternary
# Expr_UnaryMinus
# Expr_UnaryPlus
# Expr_Variable
# Expr_Yield
# Name_FullyQualified
# Name
# Name_Relative
# Param
# Scalar_ClassConst
# Scalar_DirConst
# Scalar_DNumber
# Scalar_Encapsed
# Scalar_FileConst
# Scalar_FuncConst
# Scalar_LineConst
# Scalar_LNumber
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
# Stmt_ElseIf
# Stmt_Else
# Stmt_Foreach
# Stmt_For
# Stmt_Function
# Stmt_Global
# Stmt_Goto
# Stmt_HaltCompiler
# Stmt_If
# Stmt_InlineHTML
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

