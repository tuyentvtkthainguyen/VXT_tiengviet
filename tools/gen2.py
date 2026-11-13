import os
"""Sinh du lieu cho VXT_TCVN2UNI.lsp va chay thu thuat toan (ban Python mo phong)."""
import unicodedata as ud

# ---------------- TCVN3 ----------------
T = {0xA1:'Ă',0xA2:'Â',0xA3:'Ê',0xA4:'Ô',0xA5:'Ơ',0xA6:'Ư',0xA7:'Đ',0xA8:'ă',0xA9:'â',0xAA:'ê',0xAB:'ô',0xAC:'ơ',0xAD:'ư',0xAE:'đ',
0xB5:'à',0xB6:'ả',0xB7:'ã',0xB8:'á',0xB9:'ạ',0xBB:'ằ',0xBC:'ẳ',0xBD:'ẵ',0xBE:'ắ',0xC6:'ặ',
0xC7:'ầ',0xC8:'ẩ',0xC9:'ẫ',0xCA:'ấ',0xCB:'ậ',0xCC:'è',0xCE:'ẻ',0xCF:'ẽ',0xD0:'é',0xD1:'ẹ',
0xD2:'ề',0xD3:'ể',0xD4:'ễ',0xD5:'ế',0xD6:'ệ',0xD7:'ì',0xD8:'ỉ',0xDC:'ĩ',0xDD:'í',0xDE:'ị',
0xDF:'ò',0xE1:'ỏ',0xE2:'õ',0xE3:'ó',0xE4:'ọ',0xE5:'ồ',0xE6:'ổ',0xE7:'ỗ',0xE8:'ố',0xE9:'ộ',
0xEA:'ờ',0xEB:'ở',0xEC:'ỡ',0xED:'ớ',0xEE:'ợ',0xEF:'ù',0xF1:'ủ',0xF2:'ũ',0xF3:'ú',0xF4:'ụ',
0xF5:'ừ',0xF6:'ử',0xF7:'ữ',0xF8:'ứ',0xF9:'ự',0xFA:'ỳ',0xFB:'ỷ',0xFC:'ỹ',0xFD:'ý',0xFE:'ỵ'}
TBL = {b:(ord(v),ord(v.upper())) for b,v in T.items()}

def cpdiff(cp):
    d={}
    for b in range(128,256):
        try: c=bytes([b]).decode(cp)
        except UnicodeDecodeError: continue
        if ord(c)!=b: d[b]=ord(c)
    return d
CP1252=cpdiff('cp1252'); CP1258=cpdiff('cp1258')
U2B={}
for d in (CP1252,CP1258):
    for b,u in d.items():
        assert U2B.get(u,b)==b
        U2B[u]=b

# ---------------- dau thanh ----------------
TONES={1:'̀',2:'́',3:'̉',4:'̃',5:'̣'}
BASES='aăâeêioôơuưyAĂÂEÊIOÔƠUƯY'
TDEC={}; TCOMP={}
for b in BASES:
    for t,m in TONES.items():
        c=ud.normalize('NFC',b+m); assert len(c)==1
        TDEC[ord(c)]=(ord(b),t); TCOMP[ord(b)*8+t]=ord(c)
LETTERS=set(TDEC)|{ord(c) for c in 'ăâêôơưđĂÂÊÔƠƯĐ'}
COMB=[0x300,0x301,0x303,0x309,0x323,0x302,0x306,0x31B]
NFC={}
for b in 'aeiouyAEIOUY'+'ăâêôơưĂÂÊÔƠƯ':
    for m in COMB:
        c=ud.normalize('NFC',b+chr(m))
        if len(c)==1 and ord(c) in LETTERS:
            NFC[ord(b)*1000+(m-700)]=ord(c)
UPMAP={u:ord(chr(u).upper()) for u in LETTERS if chr(u).upper()!=chr(u)}
SYMOK=[0xD7,0xB0,0xB1,0xB2,0xB3,0xD8,0xA0,0xBA,
       0x2205,0x2300,0x2264,0x2265,0x2248,0x2030,0x2018,0x2019,0x201C,0x201D,0x2013,0x2014,0x2026,0x2022,0x20AC]

# ---------------- VNI-Windows ----------------
# (byte, mod, tone) mod 0=khong, 1=mu, 2=trang
VMARK={}
for lo,up,mod,t in [(0xF8,0xD8,0,1),(0xF9,0xD9,0,2),(0xFB,0xDB,0,3),(0xF5,0xD5,0,4),(0xEF,0xCF,0,5),
                    (0xE2,0xC2,1,0),(0xE0,0xC0,1,1),(0xE1,0xC1,1,2),(0xE5,0xC5,1,3),(0xE3,0xC3,1,4),(0xE4,0xC4,1,5),
                    (0xEA,0xCA,2,0),(0xE8,0xC8,2,1),(0xE9,0xC9,2,2),(0xFA,0xDA,2,3),(0xFC,0xDC,2,4),(0xEB,0xCB,2,5)]:
    VMARK[lo]=(mod,t); VMARK[up]=(mod,t)
VSINGLE={0xEC:'ì',0xED:'í',0xE6:'ỉ',0xF3:'ĩ',0xF2:'ị',0xF1:'đ',0xF4:'ơ',0xF6:'ư',0xEE:'ỵ',
         0xCC:'Ì',0xCD:'Í',0xC6:'Ỉ',0xD3:'Ĩ',0xD2:'Ị',0xD1:'Đ',0xD4:'Ơ',0xD6:'Ư',0xCE:'Ỵ'}
VSINGLE={b:ord(c) for b,c in VSINGLE.items()}
VNILM=[0xF9,0xF5,0xE2,0xEA,0xE0,0xE1,0xE3,0xE8,0xE9,0xFA,0xD9,0xD5,0xC2,0xCA,0xC0,0xC1,0xC3,0xC8,0xC9,0xDA]

# ---------------- tu dien mac dinh ----------------
DICT=[("sử lý","xử lý"),("xắp xếp","sắp xếp"),("sắp sếp","sắp xếp"),("xác xuất","xác suất"),
("sát xuất","xác suất"),("xuất xắc","xuất sắc"),("suất sắc","xuất sắc"),("chuẩn đoán","chẩn đoán"),
("bổ xung","bổ sung"),("chia sẽ","chia sẻ"),("dữ gìn","giữ gìn"),("xum họp","sum họp"),
("kiễm tra","kiểm tra"),("kiễm soát","kiểm soát"),("sây dựng","xây dựng"),("tường sây","tường xây"),
("gạch sây","gạch xây"),("cốt thếp","cốt thép"),("cao đọ","cao độ"),("bản vẻ","bản vẽ"),
("chi tiếc","chi tiết"),("ghi trú","ghi chú"),("kích thướt","kích thước"),("tiêu chuẫn","tiêu chuẩn"),
("xi-măng","xi măng"),("bê-tông","bê tông"),("thoát nướt","thoát nước"),("ống thoác","ống thoát"),
("sử dụng sai","sử dụng sai"),("nghiệm thâu","nghiệm thu"),("lan can sắt","lan can sắt"),
("đổ bê tông lót","đổ bê tông lót"),("trát vửa","trát vữa"),("vửa xi măng","vữa xi măng"),
("dằm bo","dầm bo"),("giằn tường","giằng tường"),("móng bằng","móng băng")]
DICT=[(a,b) for a,b in DICT if a!=b]

# ======================= mo phong thuat toan =======================
def u2b(u): return u if u<256 else U2B.get(u)
def garb(l): return sum(1 for u in l if 128<=u<880 and u not in LETTERS and u not in SYMOK and u not in COMB)
def beyond(l): return sum(1 for u in l if u>=256 and u in LETTERS)
def vniev(l):
    n=0;p=None
    for u in l:
        if p is not None and u in VNILM and (p in (97,101,65,69) or (p in (121,89) and u not in (234,202)) or (p in (111,79) and u in (249,245,226,217,213,194))): n+=1
        p=u
    return n
dig=lambda x: x is not None and 48<=x<=57
def dtcvn(l,k):
    out=[];prev=None
    for i,u in enumerate(l):
        nx=l[i+1] if i+1<len(l) else None
        b=u2b(u)
        if b is None: r=u
        elif b<128: r=u-32 if (k=='H' and 97<=u<=122) else u
        elif b in (215,216) and (dig(prev) or dig(nx)): r=u
        elif b in TBL: r=TBL[b][1] if k=='H' else TBL[b][0]
        else: r=u
        out.append(r); prev=u
    return out
def vnibase(b):
    if b is None: return None
    if b in (97,101,111,117,121,65,69,79,85,89): return b
    return {244:417,246:432,212:416,214:431}.get(b)
def vnicomp(base,mod,t):
    bb = base if mod==0 else ({97:226,65:194,101:234,69:202,111:244,79:212}.get(base) if mod==1 else {97:259,65:258}.get(base))
    if bb is None: return None
    if t==0: return bb if mod else None
    return TCOMP.get(bb*8+t)
def dvni(l):
    out=[];i=0
    while i<len(l):
        u=l[i]; b=u2b(u); base=vnibase(b); r=None
        if base and i+1<len(l):
            m=VMARK.get(u2b(l[i+1]))
            if m: r=vnicomp(base,*m)
        if r: out.append(r); i+=2
        else: out.append(u if b is None else VSINGLE.get(b,u)); i+=1
    return out
def detect(l):
    g0=garb(l)
    if g0>0:
        tt=dtcvn(l,'N'); vv=dvni(l); gt,gv=garb(tt),garb(vv)
        if gv<gt or (gv==gt and len(vv)<len(tt)):
            return ('V',vv) if gv<g0 else (None,l)
        return ('N',tt) if gt<g0 else (None,l)
    if beyond(l)==0 and vniev(l)>0:
        vv=dvni(l)
        if garb(vv)==0 and len(vv)<len(l): return ('V',vv)
    return (None,l)
def tonefix(word,mode):
    n=len(word)
    if n<2: return word
    l1,l2=word[-2],word[-1]; p=word[-3] if n>2 else None
    d1=TDEC.get(l1,(l1,0)); d2=TDEC.get(l2,(l2,0))
    lw=lambda u: u+32 if 65<=u<=90 else u
    b1,b2=lw(d1[0]),lw(d2[0])
    if ((b1==111 and b2 in (97,101)) or (b1==117 and b2==121 and p not in (113,81))) and ((d1[1]>0)!=(d2[1]>0)):
        if mode=='Cu' and d2[1]>0: l1,l2=TCOMP[d1[0]*8+d2[1]],d2[0]
        elif mode=='Moi' and d1[1]>0: l2,l1=TCOMP[d2[0]*8+d1[1]],d1[0]
    return word[:-2]+[l1,l2]
def wordp(u): return 65<=u<=90 or 97<=u<=122 or 48<=u<=57 or u in LETTERS or u in COMB
def tonerun(l,mode):
    out=[];w=[]
    for u in l+[-1]:
        if u!=-1 and wordp(u): w.append(u)
        else:
            if w: out+=tonefix(w,mode); w=[]
            if u!=-1: out.append(u)
    return out
def nfc(l):
    out=[]
    for u in l:
        if out and u in COMB and out[-1]*1000+(u-700) in NFC: out[-1]=NFC[out[-1]*1000+(u-700)]
        else: out.append(u)
    return out

if __name__=='__main__':
    L=lambda s:[ord(c) for c in s]
    S=lambda l:''.join(map(chr,l))
    tests=["Th¸i Nguyªn","MÆt b»ng tÇng 1","Cèt thÐp dÇm D1 Ø16","KÝch th­íc 200×300","§­êng d©y ®iÖn",
           "Vieät Nam","Thaùi Nguyeân","Coäng hoøa xaõ hoäi chuû nghóa","Ñoäc laäp - Töï do - Haïnh phuùc",
           "Thái Nguyên","Hoà Bình","Khoá học","Mặt bằng","quân đội","Nguyễn Văn A","Ø10 a200","Hello world",
           "200×300","Café","Toà nhà"]
    for s in tests:
        k,r=detect(L(s)); print(f"{s!r:45} -> {k} {S(r)!r}")
    print(S(nfc(L(ud.normalize('NFD','Mặt bằng tầng một')))))
    print(S(tonerun(L("hòa thúy quý Hoà khỏe Thuỷ lợi"),'Moi')), '|', S(tonerun(L("hoà thuý quý Hoà khoẻ Thuỷ"),'Cu')))
    # cp1258 mo phong: TCVN3 bytes doc qua cp1258
    s=bytes([0xA7,0xAD,0xEA,0x6E,0x67,0x20,0xD0,0xE3]).decode('cp1258')
    print(repr(s), detect(L(s))[0], S(detect(L(s))[1]))

    # --------------- xuat du lieu LISP ---------------
    def lst(items, per=8):
        items=list(items); out=[]
        for i in range(0,len(items),per): out.append(" ".join(items[i:i+per]))
        return "\n    ".join(out)
    P=lambda d: lst(f"({a} . {b})" for a,b in sorted(d.items()))
    data=[]
    data.append("(setq *vn:tbl* '(\n    "+lst([f"({b} {lo} {up})" for b,(lo,up) in sorted(TBL.items())],6)+"))")
    data.append("(setq *vn:cp1252* '(\n    "+P(CP1252)+"))")
    data.append("(setq *vn:cp1258* '(\n    "+P(CP1258)+"))")
    data.append("(setq *vn:u2b* '(\n    "+P(U2B)+"))")
    data.append("(setq *vn:letters* '(\n    "+lst(map(str,sorted(LETTERS)),16)+"))")
    data.append("(setq *vn:symok* '("+" ".join(map(str,SYMOK))+"))")
    data.append("(setq *vn:comb* '("+" ".join(map(str,COMB))+"))")
    data.append("(setq *vn:tdec* '(\n    "+lst([f"({c} {b} {t})" for c,(b,t) in sorted(TDEC.items())],6)+"))")
    data.append("(setq *vn:tcomp* '(\n    "+P(TCOMP)+"))")
    data.append("(setq *vn:nfcmap* '(\n    "+P(NFC)+"))")
    data.append("(setq *vn:upmap* '(\n    "+P(UPMAP)+"))")
    data.append("(setq *vn:vnimark* '(\n    "+lst([f"({b} {m} {t})" for b,(m,t) in sorted(VMARK.items())],6)+"))")
    data.append("(setq *vn:vnisingle* '(\n    "+P(VSINGLE)+"))")
    data.append("(setq *vn:vnilm* '("+" ".join(map(str,VNILM))+"))")
    data.append("(setq *vn:dict0* '(\n    "+"\n    ".join(
        "(("+" ".join(str(ord(c)) for c in a)+") ("+" ".join(str(ord(c)) for c in b)+"))" for a,b in DICT)+"))")
    open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','build','data.lsp'),'w').write("\n\n".join(data)+"\n")
    with open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','build','VXT_CHINHTA.txt'),'w',encoding='utf-8-sig',newline='\r\n') as f:
        f.write("; Tu dien sua chinh ta cho VXT_TCVN2UNI - luu dang UTF-8\n")
        f.write("; Moi dong:  chu sai|chu dung   (dong bat dau bang ; la ghi chu)\n")
        f.write("; Chuong trinh tu sua ca dang viet hoa chu dau (Sử lý -> Xử lý)\n")
        f.write("; Cac cap duoi day da co san trong chuong trinh, them cap moi o cuoi file.\n")
        for a,b in DICT: f.write(f";{a}|{b}\n")
        f.write("trát vửa|trát vữa\n")
    print("data ok", len(TBL), len(LETTERS), len(NFC), len(DICT))
