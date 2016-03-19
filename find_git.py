#!/usr/bin/env python

import collections
import glob
import os
import sys

Entry = collections.namedtuple('Entry',
                               'rel_path site repository project label')


def GetEntries():
    pattern = os.environ["__GIT_ROOT"] + "/*/*/*/*"
    paths = glob.glob(pattern)
    entries = []
    for path in paths:
        rel_path = path[(len(os.environ["__GIT_ROOT"]) + 1):]
        components = path.split("/")
        site = components[-4]
        repository = components[-3]
        project = components[-2]
        label = components[-1]
        entry = Entry(rel_path, site, repository, project, label)
        entries.append(entry)
    return entries

def FilterEntries(entries, terms):
    matched_entries = []
    for entry in entries:
        is_matched = True
        for term in terms:
            is_matched &= (term in (entry.site,
                                    entry.repository,
                                    entry.project,
                                    entry.label))
        if is_matched:
            matched_entries.append(entry)
    return matched_entries

def main():
    entries = GetEntries()
    matched_entries = FilterEntries(entries, sys.argv[1:])
    for e in matched_entries:
        print e.rel_path

main()
