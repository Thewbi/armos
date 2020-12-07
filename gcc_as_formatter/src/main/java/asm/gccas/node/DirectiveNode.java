package asm.gccas.node;

import org.apache.commons.collections4.CollectionUtils;

public class DirectiveNode extends Node {

    @Override
    public String toString() {
        if (CollectionUtils.isEmpty(getChildren())) {
            return "";
        }

        clearWhiteSpace();
//        dump();

        final StringBuilder stringBuilder = new StringBuilder();

        // before assembler directive

        final String preprocessorInstruction = getChildren().get(0).getValue() + getChildren().get(1).getValue();
        stringBuilder.append(preprocessorInstruction);

        // between assembler and parameters
        stringBuilder.append(" ");

        for (int i = 2; i < getChildren().size(); i++) {

            final Node node = getChildren().get(i);

            if ("ParamListContext".equalsIgnoreCase(node.getType())) {
                final ParameterListNode parameterListNode = (ParameterListNode) node;
                stringBuilder.append(parameterListNode.toString());
            } else {
                stringBuilder.append(node.toString());
            }
        }

        return stringBuilder.toString();
    }
}
