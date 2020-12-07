package asm.gccas.node;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.antlr.v4.runtime.RuleContext;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;

import asm.gccas.TreeListener;

public class Node {

    public static final int MNEMONIC_INDENT = 4;

    public static final int PARAMETERS_INDENT = 11;

    private TreeListener treeListener;

    private String type;

    private RuleContext ruleContext;

    private String value;

    private Node parent;

    private final List<Node> children = new ArrayList<>();

    public void addNode(final Node node) {
        children.add(node);
        node.setParent(this);
    }

    public void dump() {

        // indent
        for (int i = 0; i < getHeight(); i++) {
            System.out.print("  ");
        }

        // type
        System.out.print(type);

        // value
        if ("terminal".equalsIgnoreCase(type)) {
            if (StringUtils.isBlank(value)) {
                System.out.print(" <WhiteSpace>");
            } else {
                System.out.print(" '" + value + "'");
            }
        }

        System.out.println();

        // recurse
        for (final Node childNode : children) {
            childNode.dump();
        }

    }

    private int getHeight() {
        if (getParent() != null) {
            return getParent().getHeight() + 1;
        }
        return 0;
    }

    protected String indent(final int count) {
        return StringUtils.repeat(' ', count);
    }

    public String getValue() {
        return value;
    }

    public void setValue(final String value) {
        this.value = value;
    }

    public Node getParent() {
        return parent;
    }

    public void setParent(final Node parent) {
        this.parent = parent;
    }

    public List<Node> getChildren() {
        return children;
    }

    public RuleContext getRuleContext() {
        return ruleContext;
    }

    public void setRuleContext(final RuleContext ruleContext) {
        this.ruleContext = ruleContext;
    }

    public String getType() {
        return type;
    }

    public void setType(final String type) {
        this.type = type;
    }

    public void clearWhiteSpace() {

        if (CollectionUtils.isEmpty(children)) {
            return;
        }

        final List<Node> deleteList = children.stream().filter(n -> {
            final boolean isTerminal = "terminal".equalsIgnoreCase(n.getType());
            return isTerminal && StringUtils.isBlank(n.getValue());
        }).collect(Collectors.toList());

        children.removeAll(deleteList);

        children.forEach(n -> n.clearWhiteSpace());
    }

    @Override
    public String toString() {
        if ("terminal".equalsIgnoreCase(getType())) {
            return value;
        }

        if (CollectionUtils.isEmpty(getChildren())) {
            return "";
        }

        final StringBuilder stringBuilder = new StringBuilder();
        for (final Node node : getChildren()) {
            stringBuilder.append(node.toString());
        }

        return stringBuilder.toString();
    }

    public TreeListener getTreeListener() {
        return treeListener;
    }

    public void setTreeListener(final TreeListener treeListener) {
        this.treeListener = treeListener;
    }

}
