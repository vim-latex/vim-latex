import glob
import os
import re
import string


import vim


def catFile(filename):
    """ assigns a local variable retval to the contents of a file """
    try:
        fp = open(filename)
        lines = fp.read()
        fp.close()
    except FileNotFoundError:
        lines = ''

    # escape double quotes and backslashes before quoting the string so
    # everything passes throught.
    vim.command("""let retval = "%s" """ % re.sub(r'"|\\', r'\\\g<0>', lines))
    return lines


def isPresentInFile(regexp, filename):
    """ check if regexp is present in the file """
    try:
        fp = open(filename)
        fcontents = fp.read()
        fp.close()
        if re.search(regexp, fcontents):
            vim.command('let retval = 1')
            return 1
        else:
            vim.command('let retval = 0')
            return None
    except FileNotFoundError:
        vim.command('let retval = 0')
        return None


def deleteFile(filepattern):
    """ deletes a file if present

       If the file does not exist, check if its a filepattern rather than a
       filename. If its a pattern, then deletes all files matching the pattern.
    """
    try:
        if os.path.isfile(filepattern):
            os.remove(filepattern)
        else:
            if glob.glob(filepattern):
                for filename in glob.glob(filepattern):
                    os.remove(filename)
            else:
                vim.command('let retval = -1')
    except:
        vim.command('let retval = -1')

# vim:ff=unix:noet:ts=4:sw=4:nowrap
