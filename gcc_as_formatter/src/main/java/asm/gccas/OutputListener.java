package asm.gccas;

import org.antlr.v4.runtime.misc.NotNull;
import org.apache.commons.lang3.StringUtils;

import gccas.gcc_asBaseListener;
import gccas.gcc_asParser;
import gccas.gcc_asParser.InstructionContext;

@SuppressWarnings("deprecation")
public class OutputListener extends gcc_asBaseListener {

    private static final int MNEMONIC_INDENT = 4;

    private static final int PARAMETERS_INDENT = 20;

    int column = 0;

    String parameters = "";

    @Override
    public void enterComment(@NotNull final gcc_asParser.CommentContext ctx) {
    }

    @Override
    public void exitComment(@NotNull final gcc_asParser.CommentContext ctx) {
        System.out.print(ctx.getText());
    }

    @Override
    public void exitNewline(final gcc_asParser.NewlineContext ctx) {
        System.out.println("");
    }

    @Override
    public void exitDirective(final gcc_asParser.DirectiveContext ctx) {
        final String text = ctx.getText();
        System.out.print(text);

        column += text.length();

        parameters = "";
    }

    @Override
    public void enterPreprocessor(final gcc_asParser.PreprocessorContext ctx) {
        System.out.print(ctx.getText());

        parameters = "";
    }

    @Override
    public void exitLabel(final gcc_asParser.LabelContext ctx) {
        System.out.print(ctx.getText());

        parameters = "";
    }

//	@Override
//	public void enterInstruction(final gcc_asParser.InstructionContext ctx) {
//		System.out.println("INSTRUCTION LINE: " + ctx.getText());
//	}

    @Override
    public void exitInstruction(final gcc_asParser.InstructionContext ctx) {
//      final String text = getCompleteText(ctx);
//      System.out.println("INSTRUCTION LINE: " + text);

        // output mnemonic
        final String mnemonic = getMnemonic(ctx);
        final int indentMnemonic = MNEMONIC_INDENT - column;
        System.out.print(StringUtils.repeat(' ', indentMnemonic) + mnemonic);
        column += mnemonic.length();

        if (StringUtils.isNotBlank(parameters)) {
            System.out.print(parameters);
            parameters = "";
        }

//        // output parameters
//        final String parameters = getParameters(ctx);
//        final int indentParameters = PARAMETERS_INDENT - column;
//        System.out.print(StringUtils.repeat(' ', indentParameters) + parameters);
//        column += parameters.length();
    }

    private String getParameters(final InstructionContext ctx) {
        String line = ctx.getText();
        line = line.trim();
        final String[] split = line.split(" ");

        if (line.startsWith("orr")) {
            System.out.println("and");
        }

        final StringBuffer stringBuffer = new StringBuffer();

        int parametersAppended = 0;
        for (int i = 1; i < split.length; i++) {

            if (StringUtils.isBlank(split[i])) {
                continue;
            }

            if (parametersAppended > 0) {
                stringBuffer.append(", ");
            }

            final String parameter = trimParameter(split[i]);
            stringBuffer.append(parameter);

            parametersAppended++;
        }

        return stringBuffer.toString();
    }

    private String trimParameter(final String untrimmedParameter) {

        if (StringUtils.isBlank(untrimmedParameter)) {
            return untrimmedParameter;
        }

        final String trimmed = untrimmedParameter.trim();
        if (trimmed.endsWith(",")) {
            return trimmed.substring(0, trimmed.length() - 1);
        }

        return trimmed;
    }

    private String getMnemonic(final gcc_asParser.InstructionContext ctx) {
        String line = ctx.getText();
        line = line.trim();
        final String[] split = line.split(" ");

        return split[0];
    }

    @Override
    public void exitParam(final gcc_asParser.ParamContext ctx) {
        final String line = ctx.getText();
//        System.out.print(line);
//        System.out.print(", ");

        if (StringUtils.isNotBlank(parameters)) {
            parameters += ",";
        }

        parameters += " " + line;
    }

    private String getCompleteText(final gcc_asParser.InstructionContext ctx) {
        return ctx.getText();
    }

    @Override
    public void exitLine(final gcc_asParser.LineContext ctx) {
//		System.out.println("EXIT LINE: " + ctx.getText());
//		System.out.print("EXIT LINE: " + ctx.getText());
//		System.out.print(ctx.getText());

        // reset
        column = 0;
    }

}
