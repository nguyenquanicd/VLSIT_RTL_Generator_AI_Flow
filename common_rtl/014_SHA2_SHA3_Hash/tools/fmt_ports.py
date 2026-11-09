"""Aligns the port list of a module into the four columns of rule R-030 / FIL-05
(direction, type, width, name). Usage: python fmt_ports.py file.sv [file2.sv ...]"""
import re
import sys

PORT = re.compile(r'^\s*(input|output)\s+(wire|logic)\s*((?:\[[^\]]*\]\s*)*)(\w+)\s*(,?)\s*$')


def fmt(path):
    lines = open(path, encoding='utf-8').read().split('\n')
    # locate the port block: from the line that is ') (' to the first line that is ');'
    try:
        start = next(i for i, l in enumerate(lines) if l.strip() == ') (')
    except StopIteration:
        return False
    end = next(i for i in range(start + 1, len(lines)) if lines[i].strip() == ');')
    parsed = []
    for i in range(start + 1, end):
        m = PORT.match(lines[i])
        if m:
            parsed.append((i, m.group(1), m.group(2), m.group(3).strip(), m.group(4), m.group(5)))
    if not parsed:
        return False
    wmax = max(len(p[3]) for p in parsed)
    last = parsed[-1][0]
    for i, d, t, w, n, c in parsed:
        comma = ',' if i != last else ''
        col = (w.ljust(wmax) + ' ') if wmax else ''
        lines[i] = '  ' + d.ljust(6) + ' ' + t.ljust(5) + ' ' + col + n + comma
    # R-030: direction column, type column, width column each one space apart; keep the blank width field
    open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines))
    return True


if __name__ == '__main__':
    for p in sys.argv[1:]:
        print(p, 'formatted' if fmt(p) else 'no port block')
