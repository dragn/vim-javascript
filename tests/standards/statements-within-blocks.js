while (node) {
    if (node.nodeType !== kTextNode) {
        return node;
    }

    node = node.nextSibling;
}
