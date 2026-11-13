import os
"""Kiem tra am tiet tieng Viet + tu sua (mo phong de kiem thu, va sinh du lieu LISP)."""
import unicodedata as ud
exec(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'gen2.py')).read().split("if __name__=='__main__':")[0])

RHYMES = """a ac ach ai am an ang anh ao ap at au ay
ăc ăm ăn ăng ăp ăt
âc âm ân âng âp ât âu ây
e ec em en eng eo ep et
ê êch êm ên ênh êp êt êu
i ia ich im in inh ip it iu iêc iêm iên iêng iêp iêt iêu
o oa oac oach oai oam oan oang oanh oao oap oat oay oăc oăm oăn oăng oăt oe oen oeo oet oc oi om on ong ooc oong op ot
ô ôc ôi ôm ôn ông ôp ôt
ơ ơi ơm ơn ơp ơt
u ua uân uâng uât uây uc uê uêch uênh ui um un ung uơ uôc uôi uôm uôn uông uôt up ut uy uya uych uyên uyêt uynh uyt uyu
ư ưa ưc ưi ưm ưn ưng ưt ưu ươc ươi ươm ươn ương ươp ươt ươu
y yêm yên yêt yêu""".split()
ONSETS = "ngh ng nh ch gh gi kh ph qu th tr b c d đ g h k l m n p r s t v x".split()
VOW = set(map(ord, "aăâeêioôơuưy"))
STOP = ["p", "t", "c", "ch"]
LOW = {v: k for k, v in UPMAP.items()}
lowc = lambda u: u + 32 if 65 <= u <= 90 else LOW.get(u, u)
upc = lambda u: u - 32 if 97 <= u <= 122 else UPMAP.get(u, u)
R = {tuple(map(ord, r)) for r in RHYMES}
ONS = [tuple(map(ord, o)) for o in ONSETS]

def info(w):
    base, tone, pos, nt = [], 0, -1, 0
    for i, u in enumerate(w):
        b, t = TDEC.get(u, (u, 0))
        base.append(lowc(b))
        if t: tone, pos, nt = t, i, nt + 1
    return base, (tone if nt <= 1 else -1), pos

def onset(b):
    for o in ONS:
        n = len(o)
        if tuple(b[:n]) == o:
            if o in [(103, 105), (113, 117)]:  # gi, qu: chi la phu am dau khi sau la nguyen am
                if len(b) > n and b[n] in VOW: return n
                if o == (103, 105): return 1     # gin, gi
                continue
            return n
    return 0

def valid(w):
    if not any(u >= 128 for u in w) or any(48 <= u <= 57 for u in w): return True
    base, tone, pos = info(w)
    if tone < 0: return False
    k = onset(base); rh = tuple(base[k:])
    if rh not in R: return False
    if any(rh[-len(s):] == tuple(map(ord, s)) for s in STOP) and tone not in (2, 5): return False
    return True

def target(base, k, cur, mode):
    nuc = []
    i = k
    while i < len(base) and base[i] in VOW: nuc.append(i); i += 1
    coda = i < len(base)
    if not nuc: return None
    if len(nuc) == 1: return nuc[0]
    s = [base[j] for j in nuc]
    if 432 in s and 417 in s: return nuc[s.index(417)]
    for d in (259, 226, 234, 244, 417):
        if d in s: return nuc[len(s) - 1 - s[::-1].index(d)]
    if 432 in s: return nuc[s.index(432)]
    if coda: return nuc[-1]
    if len(nuc) == 3: return nuc[1]
    if tuple(s) in [(111, 97), (111, 101), (117, 121)]:
        if mode == 'Cu': return nuc[0]
        if mode == 'Moi': return nuc[1]
        return cur if cur in nuc else nuc[0]
    return nuc[0]

def fixtone(w, mode='Giu'):
    base, tone, pos = info(w)
    if tone <= 0: return w
    k = onset(base)
    if tuple(base[k:]) not in R: return w
    t = target(base, k, pos, mode)
    if t is None or t == pos: return w
    w = list(w)
    w[pos] = TDEC[w[pos]][0]
    w[t] = TCOMP[w[t] * 8 + tone] if w[t] * 8 + tone in TCOMP else w[t]
    return w

def upword(w):
    U = sum(1 for u in w if 65 <= u <= 90) + sum(1 for u in w if u in LOW)
    l = sum(1 for u in w if 97 <= u <= 122)
    vl = sum(1 for u in w if u in UPMAP)
    if l == 0 and vl >= 1 and U >= 2: return [upc(u) for u in w]
    return w

if __name__ == '__main__':
    L = lambda s: [ord(c) for c in s]; S = lambda l: ''.join(map(chr, l))
    for s in ["tìên", "mưòi", "CầU", "ĐƯờNG", "hoà", "hòa", "thuý", "quý", "gì", "gìn", "Nguyễn", "nghiêng",
              "tiếng", "Việt", "khuỷu", "chuyện", "Cafè", "tầng", "BTCT", "xuống", "giữa", "của", "người", "đươc", "mỏng"]:
        w = L(s); f = upword(fixtone(w))
        print(f"{s:10} valid={valid(w)!s:5} -> {S(f):10} valid={valid(f)}")
    # du lieu LISP
    out = []
    out.append("(setq *vn:rhymes* '(\n    " + "\n    ".join("(" + " ".join(map(str, r)) + ")" for r in sorted(R)) + "))")
    out.append("(setq *vn:onsets* '(\n    " + " ".join("(" + " ".join(map(str, o)) + ")" for o in ONS) + "))")
    out.append("(setq *vn:lowmap* '(\n    " + " ".join(f"({a} . {b})" for a, b in sorted(LOW.items())) + "))")
    open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','build','data_spell.lsp'), 'w').write("\n\n".join(out) + "\n")
    print("rhymes", len(R))
