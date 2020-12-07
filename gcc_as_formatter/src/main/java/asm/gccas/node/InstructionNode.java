package asm.gccas.node;

import org.apache.commons.collections4.CollectionUtils;

public class InstructionNode extends Node {

    @Override
    public String toString() {

        if (CollectionUtils.isEmpty(getChildren())) {
            return "";
        }

        clearWhiteSpace();

        final StringBuilder stringBuilder = new StringBuilder();

        // before instruction
        stringBuilder.append(indent(MNEMONIC_INDENT - getTreeListener().getColumn()));
        getTreeListener().setColumn(MNEMONIC_INDENT);

        final Node instructionNode = getChildren().get(0);
        String temp = instructionNode.toString();
        stringBuilder.append(temp);
        getTreeListener().incrementColumn(temp.length());

        // between instruction and parameters

        int paramIndent = PARAMETERS_INDENT - getTreeListener().getColumn();
        if (paramIndent <= 0) {
            paramIndent = 1;
        }
        stringBuilder.append(indent(paramIndent));
        getTreeListener().setColumn(paramIndent);

        // parameter list
        for (int i = 1; i < getChildren().size(); i++) {

            temp = getChildren().get(i).toString();
            stringBuilder.append(temp);
            getTreeListener().incrementColumn(temp.length());
        }

        return stringBuilder.toString();
    }

}
