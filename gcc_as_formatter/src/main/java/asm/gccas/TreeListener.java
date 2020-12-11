package asm.gccas;

import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.TerminalNode;

import asm.gccas.node.DirectiveNode;
import asm.gccas.node.InstructionNode;
import asm.gccas.node.Node;
import asm.gccas.node.ParameterListNode;
import asm.gccas.node.PreprocessorNode;
import gccas.gcc_asListener;
import gccas.gcc_asParser.CommentContext;
import gccas.gcc_asParser.DirectiveContext;
import gccas.gcc_asParser.ExprContext;
import gccas.gcc_asParser.InstructionContext;
import gccas.gcc_asParser.LabelContext;
import gccas.gcc_asParser.LineContext;
import gccas.gcc_asParser.MultilineCommentContext;
import gccas.gcc_asParser.NewlineContext;
import gccas.gcc_asParser.NumericLiteralContext;
import gccas.gcc_asParser.ParamContext;
import gccas.gcc_asParser.ParamListContext;
import gccas.gcc_asParser.PreprocessorContext;
import gccas.gcc_asParser.ProgramContext;

public class TreeListener implements gcc_asListener {

	private final Node root = new Node();

	private Node currentNode = root;

	private int column;

	private int instructionCount;

	public void createStep() {
		// TODO pack potential label, instruction, comment into a step object
		System.out.println(" createStep");

		// TODO after the step is created reset the label instrcution comment objects
	}

	public void dump() {
		root.setValue("root");
		root.setType("<root>");
		root.dump();
	}

	private void descend(final ParserRuleContext ctx) {
		final Node node = new Node();
		descend(node, ctx);
	}

	private void descend(final Node node, final ParserRuleContext ctx) {
		node.setType(ctx.getClass().getSimpleName());
		node.setValue(ctx.getText());
		node.setTreeListener(this);
		currentNode.addNode(node);
		currentNode = node;
	}

	private void ascend() {
		currentNode = currentNode.getParent();
	}

	@Override
	public void visitTerminal(final TerminalNode node) {
		final Node astNode = new Node();
		astNode.setValue(node.getText());
		astNode.setType("Terminal");
		currentNode.addNode(astNode);
	}

	@Override
	public void visitErrorNode(final ErrorNode node) {

	}

	@Override
	public void enterEveryRule(final ParserRuleContext ctx) {
//        System.out.println(ctx.getClass().getName() + " " + ctx.getText());
//		System.out.print("F");
	}

	@Override
	public void exitEveryRule(final ParserRuleContext ctx) {

	}

	@Override
	public void enterProgram(final ProgramContext ctx) {
		descend(ctx);
	}

	@Override
	public void exitProgram(final ProgramContext ctx) {
		ascend();
	}

	@Override
	public void enterLine(final LineContext ctx) {
		instructionCount++;
		System.out.print("I" + instructionCount + " ");

		descend(ctx);
	}

	@Override
	public void exitLine(final LineContext ctx) {
//		System.out.println("---------");
////		lineNumber++;
////		System.out.println(lineNumber + " ");
//
		ascend();
//
////        dump();
////		currentNode.dump();
//
//		System.out.print(currentNode.toString());
		currentNode.getChildren().clear();
//
//		System.out.println();
//		System.out.println("---------");
//
		column = 0;
	}

	@Override
	public void enterComment(final CommentContext ctx) {
		descend(ctx);
	}

	@Override
	public void exitComment(final CommentContext ctx) {
		System.out.print("SINGLECOM: " + currentNode.toString());

		// TODO add a comment object so that it later can be added to the step

		ascend();
	}

	@Override
	public void enterMultilineComment(final MultilineCommentContext ctx) {
		descend(ctx);
	}

	@Override
	public void exitMultilineComment(final MultilineCommentContext ctx) {
		System.out.print("MULTICOM: " + currentNode.toString());

		// TODO add a multiline comments object so that it later can be added to the
		// step

		ascend();
	}

	@Override
	public void enterExpr(final ExprContext ctx) {
		descend(ctx);
	}

	@Override
	public void exitExpr(final ExprContext ctx) {
		ascend();
	}

	@Override
	public void enterLabel(final LabelContext ctx) {
		descend(ctx);
	}

	@Override
	public void exitLabel(final LabelContext ctx) {
		System.out.print("LABEL: " + currentNode.toString());

		// TODO add a label object so that it later can be added to the step

		ascend();
	}

	@Override
	public void enterInstruction(final InstructionContext ctx) {
		final InstructionNode instructionNode = new InstructionNode();
		descend(instructionNode, ctx);
	}

	@Override
	public void exitInstruction(final InstructionContext ctx) {
		System.out.print("INSTRUCTION: " + currentNode.toString());

		// TODO add a instruction object so that it later can be added to the step
		ascend();
	}

	@Override
	public void enterPreprocessor(final PreprocessorContext ctx) {
		final PreprocessorNode preprocessorNode = new PreprocessorNode();
		descend(preprocessorNode, ctx);
	}

	@Override
	public void exitPreprocessor(final PreprocessorContext ctx) {
		ascend();
	}

	@Override
	public void enterDirective(final DirectiveContext ctx) {
		final DirectiveNode directiveNode = new DirectiveNode();
		descend(directiveNode, ctx);
	}

	@Override
	public void exitDirective(final DirectiveContext ctx) {
		ascend();
	}

	@Override
	public void enterParamList(final ParamListContext ctx) {
		final ParameterListNode parameterListNode = new ParameterListNode();
		descend(parameterListNode, ctx);
	}

	@Override
	public void exitParamList(final ParamListContext ctx) {
		ascend();
	}

	@Override
	public void enterParam(final ParamContext ctx) {
		descend(ctx);
	}

	@Override
	public void exitParam(final ParamContext ctx) {
		ascend();
	}

	@Override
	public void enterNewline(final NewlineContext ctx) {
		System.out.print(" enterNewline ");

		// TODO
		// Call the method that creates an Object that describes a debuggable step for a
		// simulator
		createStep();

		descend(ctx);
	}

	@Override
	public void exitNewline(final NewlineContext ctx) {
//		System.out.print("exitNewline " + currentNode.toString());

		// this is only used to output a new line for the current line
		System.out.println();
		ascend();
	}

	@Override
	public void enterNumericLiteral(final NumericLiteralContext ctx) {
		descend(ctx);
	}

	@Override
	public void exitNumericLiteral(final NumericLiteralContext ctx) {
		ascend();
	}

	public int getColumn() {
		return column;
	}

	public void setColumn(final int column) {
		this.column = column;
	}

	public void incrementColumn(final int length) {
		column += length;
	}

}
