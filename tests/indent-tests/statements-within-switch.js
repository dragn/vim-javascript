switch (className) {
    case ccc.LOG:
        try {
            process(text);
        } catch (ignore1) {
            log(ignore1);
        }

        switch(insideSwitch) {
            case 123:
                statement;
                break;
            default:
                statement;
                break;
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

someStatementAfterSwitch;
