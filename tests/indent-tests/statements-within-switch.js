switch (className) {
    case ccc.LOG:
        try {
           process(text);
        } catch (ignore1) {
            log(ignore1);
        }

        break;
    case ccc.INFO:
        try {
            console.info(text);
        } catch (ignore2) {
            log(ignore2);
        }

        break;
}
