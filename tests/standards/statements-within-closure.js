me.eventHandler.preventDefault = window.event ? function() {
    window.event.returnValue = false;

    return false;
} : function(e) {
    if (!e) {
        return;
    }

    if (e.preventDefault) {
        e.preventDefault();
    }

    return false;
};

me.eventHandler.preventDefault(evt);
