#!/usr/bin/python

# Part of Latex-Suite
#
# Copyright: Srinath Avadhanula
# Description:
#   This file implements a simple outline creation for latex documents.

import re
import os
import sys

# getFileContents {{{
def getFileContents(argin, ext=''):
    if type(argin) is str:
        fname = argin + ext
    else:
        if argin.group(2) == 'include':
            fname = argin.group(3) + ext
        else:
            fname = argin.group(3)

    contents = open(fname).read()

    # TODO what are all the ways in which a tex file can include another?
    pat = re.compile(r'^\\(@?)(include|input){(.*?)}', re.M)
    contents = re.sub(pat, lambda input: getFileContents(input, ext), contents)

    return ('%%==== FILENAME: %s' % fname) + '\n' + contents

# }}}
# createOutline {{{
def createOutline(contents, prefix):
    """
    Prints a formatted outline of the latex document on the standard
    output. The output is of the form:

    1. Introduction
        1.1 Introduction section
    >       eqn:firsteqn
    :           2 == 2
    >       fig:figure1
    :           Caption for the figure
        1.2 Second section name of introduction

    If ``prefix`` is given, then only labels which start with it are
    listed.
    """

    # This is the hierarchical list of the sectioning of a latex document.
    outline_cmds = ['chapter', 'section', 'subsection', 'subsubsection']
    outline_nums = {}
    for cmd in outline_cmds:
        outline_nums[cmd] = 0


    pres_depth = 0
    fname = ''
    prev_txt = ''
    inside_env = 0
    prev_env = ''

    for line in contents.splitlines():
        # remember which file we are currently "in"
        if re.match('%==== FILENAME: ', line):
            fname = re.search('%==== FILENAME: (.*)', line).group(1)

        # throw away everything after the %
        line = re.sub('%.*', '', line)
        if not line:
            continue

        # throw away leading white-space
        line = line.lstrip()

        # we found a label!
        m = re.search(r'\\label{(%s.*?)}' % prefix, line)
        if m:
            # add the current line (except the \label command) to the text
            # which will be displayed below this label
            prev_txt += re.search(r'(^.*?)\\label{', line).group(1)

            # for the figure environment however, just display the caption.
            # instead of everything since the \begin command.
            if prev_env == 'figure':
                cm = re.search(r'\caption(\[.*?\]\s*)?{(.*?)}', prev_txt)
                if cm:
                    prev_txt = cm.group(2)

            # print a nice formatted text entry like so
            #
            # >        eqn:label
            # :          e^{i\pi} + 1 = 0
            #
            # Use the current "section depth" for the leading indentation.
            print '>%s%s\t\t<%s>' % (' '*(2*pres_depth+6),
                    m.group(1), fname)
            print ':%s%s' % (' '*(2*pres_depth+8), prev_txt)
            prev_txt = ''

        # We found a TOC command, i.e one of \chapter, \section etc.
        # We need to increase the numbering for the level which we just
        # encoutered and reset all the nested levels to zero. Thus if we
        # encounter a \section, the section number increments and the
        # subsection numbers etc reset to 0.
        ntot = len(outline_cmds)
        sec_txt = ''
        for i in range(ntot):
            m = re.search(r'\\' + outline_cmds[i] + '{(.*?)}', line)
            if m:
                outline_nums[outline_cmds[i]] += 1
                for j in range(i+1, ntot):
                    outline_nums[outline_cmds[j]] = 0

                # At the same time we form a string like
                #
                #     3.2.4 The section name
                #
                sec_txt = ''
                for k in range(0, i+1):
                    sec_txt += '%d.' % outline_nums[outline_cmds[k]]

                sec_txt += (' ' + m.group(1))
                pres_depth = i

                print '%s%s\t<<<%d' % (' '*2*pres_depth, sec_txt, pres_depth+1)
                break

        # If we just encoutered the start or end of an environment or a
        # label, then do not remember this line. 
        # NOTE: This assumes that there is no equation text on the same
        # line as the \begin or \end command. The text on the same line as
        # the \label was already handled.
        if re.search(r'\\begin{(equation|eqnarray|align|figure)', line):
            prev_txt = ''
            prev_env = re.search(r'\\begin{(.*?)}', line).group(1)
            inside_env = 1

        elif re.search(r'\\label', line):
            prev_txt = ''

        elif re.search(r'\\end{(equation|eqnarray|align|figure)', line):
            inside_env = 0
            prev_env = ''

        else:
            # If we are inside an environment, then the text displayed with
            # the label is the complete text within the environment,
            # otherwise its just the previous line.
            if inside_env:
                prev_txt += line
            else:
                prev_txt = line


# }}}

if __name__ == "__main__":
    fname = sys.argv[1]
    if len(sys.argv) > 2:
        prefix = sys.argv[2]
    else:
        prefix = ''

    [head, tail] = os.path.split(fname)
    if head:
        os.chdir(head)

    [root, ext] = os.path.splitext(tail)
    contents = getFileContents(root, ext)

    createOutline(contents, prefix)

# vim: fdm=marker
