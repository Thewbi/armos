package asm.gccas;

import org.antlr.v4.runtime.misc.NotNull;

import gccas.gcc_asBaseListener;
import gccas.gcc_asParser;

@SuppressWarnings("deprecation")
public class OutputListener extends gcc_asBaseListener {

	@Override
	public void enterComment(@NotNull final gcc_asParser.CommentContext ctx) {
//		System.out.println("COMMENT: " + ctx.getText());
	}

	@Override
	public void exitComment(@NotNull final gcc_asParser.CommentContext ctx) {
//		System.out.println("COMMENT: " + ctx.getText());
//		System.out.print("COMMENT: " + ctx.getText());
		System.out.print(ctx.getText());
	}

	@Override
	public void exitMultiline_comment(final gcc_asParser.Multiline_commentContext ctx) {
//		System.out.println("MULTI_COMMENT: " + ctx.getText());
	}

	@Override
	public void exitNewline(final gcc_asParser.NewlineContext ctx) {
//		System.out.println("NEWLINE: " + ctx.getText());
		System.out.println("");
	}

//	@Override
//	public void enterDirective(final gcc_asParser.DirectiveContext ctx) {
//		System.out.print(ctx.getText());
//	}

	@Override
	public void exitDirective(final gcc_asParser.DirectiveContext ctx) {
		System.out.print(ctx.getText());
	}

	@Override
	public void enterPreprocessor(final gcc_asParser.PreprocessorContext ctx) {
		System.out.print(ctx.getText());
	}

	@Override
	public void exitLabel(final gcc_asParser.LabelContext ctx) {
		System.out.print(ctx.getText());
	}

//	@Override
//	public void enterInstruction(final gcc_asParser.InstructionContext ctx) {
//		System.out.println("INSTRUCTION LINE: " + ctx.getText());
//	}

	@Override
	public void exitInstruction(final gcc_asParser.InstructionContext ctx) {
//		System.out.println("INSTRUCTION LINE: " + ctx.getText());

		String line = ctx.getText();
		line = line.trim();

		final String[] split = line.split(" ");

		System.out.print(split[0]);
	}

	@Override
	public void exitLine(final gcc_asParser.LineContext ctx) {
//		System.out.println("EXIT LINE: " + ctx.getText());
//		System.out.print("EXIT LINE: " + ctx.getText());
//		System.out.print(ctx.getText());
	}

}
