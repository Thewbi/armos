package asm.gccas.node;

import org.apache.commons.collections4.CollectionUtils;

public class PreprocessorNode extends Node {

    @Override
    public String toString() {
        if (CollectionUtils.isEmpty(getChildren())) {
            return "";
        }

        clearWhiteSpace();

//        dump();

        final StringBuilder stringBuilder = new StringBuilder();

        // before preprocessor instruction

        final String preprocessorInstruction = getChildren().get(0).getValue() + getChildren().get(1).getValue();
        stringBuilder.append(preprocessorInstruction);

        // between preprocessor instruction and parameters
        stringBuilder.append(" ");

//        int index = 0;
        for (int i = 2; i < getChildren().size(); i++) {

            final Node node = getChildren().get(i);

            if ("ParamListContext".equalsIgnoreCase(node.getType())) {
                final ParameterListNode parameterListNode = (ParameterListNode) node;
                parameterListNode.setSeparator("");
                stringBuilder.append(parameterListNode.toString());
            } else {
                stringBuilder.append(node.toString());
            }

//            stringBuilder.append(node.toString());
//                if (index < getChildren().size() - 1) {
//                    stringBuilder.append(", ");
//                }
//            }

//            index++;
        }

        return stringBuilder.toString();
    }
}
