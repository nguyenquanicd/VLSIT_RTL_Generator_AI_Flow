"""Wraps comment-only lines longer than 100 characters (rule CMT-05) at a space, keeping the comment prefix.
Usage: python wrap_comments.py file.sv [file2.sv ...]"""
import re
import sys

LIM = 100
for path in sys.argv[1:]:
    out = []
    n = 0
    for line in open(path, encoding='utf-8').read().split('\n'):
        m = re.match(r'^(\s*(?://|\*)\s*)(\S.*)$', line)
        if len(line) > LIM and m:
            pre = m.group(1)
            rest = line
            while len(rest) > LIM:
                cut = rest.rfind(' ', len(pre) + 1, LIM)
                if cut <= len(pre):
                    break
                out.append(rest[:cut])
                rest = pre + rest[cut + 1:]
                n += 1
            out.append(rest)
        else:
            out.append(line)
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
    print(path, n)
