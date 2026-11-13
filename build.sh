#!/bin/sh
# Build lai toan bo: du lieu bang ma -> VXT_TCVN2UNI.lsp, menu Ribbon .cuix, bo cai dat .exe
set -e
cd "$(dirname "$0")"
mkdir -p build
python3 tools/gen2.py            # build/data.lsp, build/VXT_CHINHTA.txt
python3 tools/spell.py           # build/data_spell.lsp
python3 - <<'PY'
s = open('tools/main.lsp').read().replace(';;;@@DATA@@',
    ';;; ------------------------------------------------ du lieu bang ma -----\n'
    + open('build/data.lsp').read() + '\n' + open('build/data_spell.lsp').read())
assert all(ord(c) < 128 for c in s)
open('autocad/VXT_TCVN2UNI.lsp', 'w', newline='\r\n').write(s)
PY
python3 tools/build_cuix.py      # build/VXT_TIENGVIET.cuix, .mnl (can Pillow)
cp build/VXT_TIENGVIET.cuix build/VXT_TIENGVIET.mnl autocad/
mkdir -p setup/files && cp autocad/* setup/files/
(cd setup && GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags "-H windowsgui -s -w" -o ../release/VXT_TiengViet_Setup.exe .)
echo "Xong: autocad/ va release/VXT_TiengViet_Setup.exe"
