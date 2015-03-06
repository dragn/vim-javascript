var assert  = require('assert'),
    exec    = require('child_process').execSync,
    path    = require('path'),
    fs      = require('fs'),
    diff    = require('ansidiff'),
    util    = require('util'),
    color   = require('colors');

var STANDARDS_PATH  = 'standards',
    COMMANDS        = [
        'set indentexpr=GetJavascriptIndent()',
        'exe \'norm gg=G\'',
        '%print',
        'q!'
    ].join('\n'),
    SETUP_SCRIPT    = 'test-setup.vim',
    INDENT_SCRIPT   = '../indent/javascript.vim';

function callVim(file, str) {
    var cmd = util.format(
        'vim -E -S %s -S %s -c "%s" %s',
        SETUP_SCRIPT,
        INDENT_SCRIPT,
        COMMANDS,
        file
    );
    console.log(cmd);
    return exec(cmd, { input : str, timeout: 5000, encoding: 'utf-8' });
}

function checkStandard(file) {
    var str = fs.readFileSync(file, 'utf-8'),
        result = callVim(file, str);

    if (str != result) {
        console.log(('  ✗ failed ' + file).red);
        console.log(diff.lines(str, result));
        //assert(false, 'Strings are not equal');
    } else {
        console.log(('  ✓ success ' + file).green);
    }
}

fs.readdir(STANDARDS_PATH, function(err, files) {
    err && console.error('error reading directory "standards"', err);

    console.log('\nChecking indent standards\n'.white);
    files.forEach(function(file) {
        checkStandard(path.join(STANDARDS_PATH, file));
    });
    console.log();
});

