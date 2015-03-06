me.getNextById = function(target, id) {
    target = $(target);

    if (!target) {
        return null;
    }

    var node = target.nextSibling;

    if (!node) {
        return null;
    }

    var kTextNode = me.nodeType.TEXT;

    while (node) {
        if (node.id && node.id == id) {
            return node;
        }

        // Get the next node.
        node = node.nextSibling;
    }

    return null;
};
