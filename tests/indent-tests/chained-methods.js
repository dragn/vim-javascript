program
    .command('today')
    .description('If no option given, list the goals for today.' +
        ' Otherwise executes the option within the context of today.')
    .action(function() {
            command.handleToday.call(program);
        });
