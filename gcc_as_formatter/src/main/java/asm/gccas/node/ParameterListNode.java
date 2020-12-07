package asm.gccas.node;

import org.apache.commons.collections4.CollectionUtils;

public class ParameterListNode extends Node {

    private String separator = ",";

    @Override
    public String toString() {
        if (CollectionUtils.isEmpty(getChildren())) {
            return "";
        }

        clearWhiteSpace();

        final StringBuilder stringBuilder = new StringBuilder();
        int index = 0;
        for (final Node node : getChildren()) {

            if ("ParamContext".equalsIgnoreCase(node.getType())) {

                stringBuilder.append(node.toString());
                if (index < getChildren().size() - 1) {
                    stringBuilder.append(separator).append(" ");
                }
            }

            index++;
        }

        return stringBuilder.toString();
    }

    public String getSeparator() {
        return separator;
    }

    public void setSeparator(final String separator) {
        this.separator = separator;
    }

}
