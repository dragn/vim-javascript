program
    .command('today') //<-- single indent. 
    .description('If no option given, list the goals for today.' +
        ' Otherwise executes the option within the context of today.’)//<-- single indent. 
    .action(function() {
        command.handleToday.call(program);
    });
