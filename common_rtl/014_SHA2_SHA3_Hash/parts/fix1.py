import re
def sub(fn, generic):
    t = open(fn, encoding='utf-8').read()
    t = re.sub(r'\bN/A\b(?!\s*[-:(]\s*\S)(?! with a reason)', generic, t)
    open(fn, 'w', encoding='utf-8', newline='\n').write(t)
sub('p2.md', 'N/A (no such value for this item)')
sub('p3.md', 'N/A (not applicable to this item)')
# section 22 URLs without angle brackets, numbers for FEAT-010 and FEAT-012
t = open('p3.md', encoding='utf-8').read()
t = re.sub(r'<(https://[^>]+)>', r'\1', t)
open('p3.md', 'w', encoding='utf-8', newline='\n').write(t)
t = open('p1.md', encoding='utf-8').read()
a = 'One detected fault leads to gate, lock, clear and alarm'
b = 'One detected fault leads to gate, lock, clear and alarm within 2 clock cycles of the registered mismatch (OP-011)'
assert a in t
t = t.replace(a, b)
a = 'One `o_irq`, one `o_alarm`'
b = 'One `o_irq` and one `o_alarm` output; 9 event types; 19 registers'
assert a in t
t = t.replace(a, b)
open('p1.md', 'w', encoding='utf-8', newline='\n').write(t)
