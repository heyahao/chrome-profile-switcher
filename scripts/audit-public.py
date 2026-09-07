#!/usr/bin/env python3
"""Scan public source or extracted distribution. Reports filenames, never matching values."""
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else '.').resolve()
ignored = {'.git', '.build', 'release', '__pycache__'}
patterns = [
    rb'/Users/[A-Za-z0-9_.-]+/',
    rb'[A-Za-z0-9_.+-]+@[A-Za-z0-9_.-]+\.local\b',
    rb'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----',
    rb'gh[pousr]_[A-Za-z0-9]{25,}',
    rb'github_pat_[A-Za-z0-9_]{30,}',
    rb'sk-[A-Za-z0-9_-]{30,}',
    rb'AKIA[0-9A-Z]{16}',
]
bad_extensions = {'.sqlite', '.db', '.log', '.pem', '.key', '.p12', '.pfx', '.icns'}
failures = []
count = 0
for path in sorted(root.rglob('*')):
    relative = path.relative_to(root)
    if any(part in ignored for part in relative.parts):
        continue
    if path.is_symlink():
        failures.append((str(relative), 'symlink not allowed in public package'))
        continue
    if not path.is_file():
        continue
    count += 1
    if path.suffix in bad_extensions or path.name.startswith('.env') or path.name in {'.DS_Store', 'Manico.sqlite'}:
        failures.append((str(relative), 'forbidden asset'))
    data = path.read_bytes()
    if any(re.search(pattern, data) for pattern in patterns):
        failures.append((str(relative), 'private path or credential pattern'))
for path, reason in failures:
    print(f'FAIL {path}: {reason}')
if failures:
    sys.exit(1)
print(f'PASS public-content scan: {count} files (pattern scan is not a guarantee of no secrets)')
