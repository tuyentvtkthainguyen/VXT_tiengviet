"""Tao VXT_TIENGVIET.cuix (partial CUIX co tab Ribbon) tu cac phan rong trong cuix_template/."""
import os, zipfile, uuid, datetime
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
T = os.path.join(HERE, "cuix_template")
OUT = os.path.join(HERE, "..", "build")
os.makedirs(OUT, exist_ok=True)
FONT = os.environ.get("VXT_FONT", "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf")

# ---------------- icon ----------------
def icon(name, txt, bg, sub=None):
    for sz in (16, 32):
        S = sz * 8
        im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        d.rounded_rectangle([S*0.04, S*0.04, S*0.96, S*0.96], radius=S*0.18, fill=bg)
        f = ImageFont.truetype(FONT, int(S * (0.50 if len(txt) <= 2 else 0.38)))
        bb = d.textbbox((0, 0), txt, font=f)
        x = (S - (bb[2]-bb[0]))/2 - bb[0]; y = (S - (bb[3]-bb[1]))/2 - bb[1]
        if sub and sz == 32:
            y -= S*0.10
        d.text((x, y), txt, font=f, fill="white")
        if sub and sz == 32:
            f2 = ImageFont.truetype(FONT, int(S*0.20))
            bb = d.textbbox((0, 0), sub, font=f2)
            d.text(((S-(bb[2]-bb[0]))/2 - bb[0], S*0.70), sub, font=f2, fill=(255, 255, 255, 230))
        im.resize((sz, sz), Image.LANCZOS).save(os.path.join(OUT, f"{name}_{sz}px.png"))

ICONS = [
    ("vxt_tb",   "Ă",  (25, 118, 210), "ALL"),
    ("vxt_chon", "Ă",  (0, 150, 136), "SEL"),
    ("vxt_tm",   "Ă",  (230, 145, 0), "DIR"),
    ("vxt_ep",   "ÉP", (198, 40, 40), None),
    ("vxt_cd",   "⚙",  (84, 110, 122), None),
    ("vxt_td",   "Aa", (106, 27, 154), None),
    ("vxt_hd",   "?",  (46, 125, 50), None),
    ("vxt_kt",   "✓",  (0, 121, 107), "ABC"),
]
for n, t, c, s in ICONS:
    icon(n, t, c, s)

# ---------------- lenh ----------------
# (uid, ten, lenh, icon, mo ta)
CMDS = [
    ("MMU_VXT_A0001", "Toàn bộ bản vẽ", "^C^CTCVN2UNI_TB", "vxt_tb",
     "Chuyển mọi chữ TCVN3/VNI trong bản vẽ (Text, Mtext, Dim, Block, Table...) sang Unicode, đổi font lỗi/thiếu sang Arial"),
    ("MMU_VXT_A0002", "Chọn đối tượng", "^C^CTCVN2UNI_CHON", "vxt_chon",
     "Chỉ chuyển các đối tượng chữ được chọn"),
    ("MMU_VXT_A0003", "Cả thư mục", "^C^CTCVN2UNI_THUMUC", "vxt_tm",
     "Chuyển hàng loạt mọi file DWG trong một thư mục, sao lưu bản gốc vào _BanGoc_VXT"),
    ("MMU_VXT_A0004", "Ép chuyển", "^C^CTCVNEP", "vxt_ep",
     "Ép chuyển đối tượng chọn theo bảng mã TCVN3 / TCVN3 hoa / VNI"),
    ("MMU_VXT_A0005", "Cài đặt", "^C^CTCVNCAIDAT", "vxt_cd",
     "Font đích, nhận diện lỗi font, sửa chính tả, kiểu đặt dấu"),
    ("MMU_VXT_A0006", "Từ điển chính tả", "^C^CTCVNTUDIEN", "vxt_td",
     "Mở file VXT_CHINHTA.txt để thêm cặp chữ sai|chữ đúng"),
    ("MMU_VXT_A0007", "Hướng dẫn", "^C^CTCVNHUONGDAN", "vxt_hd",
     "Danh sách lệnh và hướng dẫn sử dụng"),
    ("MMU_VXT_A0008", "Kiểm tra chính tả", "^C^CTCVNKIEMTRA", "vxt_kt",
     "Kiểm tra chữ sai luật ghép vần tiếng Việt và chọn sẵn các đối tượng nghi sai (không sửa gì)"),
]
REV = '<ModifiedRev MajorVersion="24" MinorVersion="1" UserVersion="1" />'
HDR = open(os.path.join(T, "Header.cui"), encoding="utf-8").read().split("<CustSection")[0]

def esc(s): return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")

mg = [HDR + '<MenuGroup xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" Name="VXT_TIENGVIET">',
      '  <MacroGroup Name="VXT">']
for i, (uid, name, cmd, ic, desc) in enumerate(CMDS):
    mg.append(f'''    <MenuMacro UID="{uid}">
      <Macro type="Any">
        <Revision MajorVersion="16" MinorVersion="2" UserVersion="1" />
        {REV}
        <Name xlate="true" UID="XLS_VXT_N{i:03d}">{esc(name)}</Name>
        <Command>{cmd}</Command>
        <HelpString xlate="true" UID="XLS_VXT_H{i:03d}">{esc(desc)}</HelpString>
        <SmallImage Name="{ic}_16px.png" />
        <LargeImage Name="{ic}_32px.png" />
        <CLICommand xlate="true" UID="XLS_VXT_C{i:03d}">{esc(name)}</CLICommand>
      </Macro>
    </MenuMacro>''')
mg += ['  </MacroGroup>', '</MenuGroup>']
MENUGROUP = "\n".join(mg) + "\n"

def btn(uid, i, style):
    c = CMDS[i]
    return (f'<RibbonCommandButton UID="{uid}" Id="AcRibbonCommandButton" Text="{esc(c[1])}" '
            f'ButtonStyle="{style}" MenuMacroID="{c[0]}" KeyTip="">'
            f'<TooltipTitle xlate="true" UID="XLS_VXT_T{uid[-4:]}">{esc(c[1])}</TooltipTitle>{REV}</RibbonCommandButton>')

RIB = HDR + f'''<RibbonRoot>
  <RibbonPanelSourceCollection xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <RibbonPanelSource UID="RBNU_VXT_P0001" Text="Chuyển TCVN3 / VNI → Unicode + chính tả" HiddenInEditor="false">
      {REV}
      <Name xlate="true" UID="XLS_VXT_P0001">Chuyển TCVN3 / VNI → Unicode + chính tả</Name>
      <RibbonRow UID="RBNU_VXT_R0001">
        {REV}
        {btn("RBNU_VXT_B0001", 0, "LargeWithText")}
        {btn("RBNU_VXT_B0002", 1, "LargeWithText")}
        {btn("RBNU_VXT_B0003", 2, "LargeWithText")}
        {btn("RBNU_VXT_B0008", 7, "LargeWithText")}
      </RibbonRow>
    </RibbonPanelSource>
    <RibbonPanelSource UID="RBNU_VXT_P0002" Text="Công cụ" HiddenInEditor="false">
      {REV}
      <Name xlate="true" UID="XLS_VXT_P0002">Công cụ</Name>
      <RibbonRow UID="RBNU_VXT_R0002">
        {REV}
        <RibbonRowPanel UID="RBNU_VXT_RP001" ResizeStyle="None" ResizePriority="100" TopJustify="True">
          {REV}
          <RibbonRow UID="RBNU_VXT_R0003">{REV}{btn("RBNU_VXT_B0004", 3, "SmallWithText")}</RibbonRow>
          <RibbonRow UID="RBNU_VXT_R0004">{REV}{btn("RBNU_VXT_B0005", 4, "SmallWithText")}</RibbonRow>
          <RibbonRow UID="RBNU_VXT_R0005">{REV}{btn("RBNU_VXT_B0006", 5, "SmallWithText")}</RibbonRow>
        </RibbonRowPanel>
        {btn("RBNU_VXT_B0007", 6, "LargeWithText")}
      </RibbonRow>
    </RibbonPanelSource>
  </RibbonPanelSourceCollection>
  <RibbonTabSourceCollection>
    <RibbonTabSource Text="VXT Tiếng Việt" UID="RBNU_VXT_TAB01">
      {REV}
      <Name xlate="true" UID="XLS_VXT_TAB01">VXT Tiếng Việt</Name>
      <RibbonPanelSourceReference UID="RBNU_VXT_PR001" PanelId="RBNU_VXT_P0001" ResizeStyle="Default">{REV}</RibbonPanelSourceReference>
      <RibbonPanelSourceReference UID="RBNU_VXT_PR002" PanelId="RBNU_VXT_P0002" ResizeStyle="Default">{REV}</RibbonPanelSourceReference>
    </RibbonTabSource>
  </RibbonTabSourceCollection>
</RibbonRoot>
'''

# ---------------- dong goi ----------------
cui_parts = ["Header.cui", "WorkspaceRoot.cui", "MenuGroup.cui", "AcceleratorRoot.cui", "OverrideRoot.cui",
             "MouseButtonRoot.cui", "PopMenuRoot.cui", "ToolbarRoot.cui", "DoubleClickRoot.cui",
             "QuickPropertiesRoot.cui", "RolloverTooltipRoot.cui", "RibbonRoot.cui", "QuickAccessToolbarRoot.cui",
             "ToolPanelRoot.cui", "PanelSetRoot.cui", "ScreenMenuRoot.cui", "ImageMenuRoot.cui",
             "TabletMenuRoot.cui", "DigitizerButtonRoot.cui", "LSPFiles.cui"]
content = {}
for p in cui_parts:
    if p not in ("MenuGroup.cui", "RibbonRoot.cui"):
        content[p] = open(os.path.join(T, p), "rb").read()
content["MenuGroup.cui"] = MENUGROUP.encode("utf-8")
content["RibbonRoot.cui"] = RIB.encode("utf-8")
pngs = sorted(f for f in os.listdir(OUT) if f.endswith(".png"))
for p in pngs:
    content[p] = open(os.path.join(OUT, p), "rb").read()

rid = lambda: "R" + uuid.uuid4().hex[:16]
rels = ['﻿<?xml version="1.0" encoding="utf-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">']
for p in cui_parts:
    rels.append(f'<Relationship Type="CUI" Target="/{p}" Id="{rid()}" />')
for p in pngs:
    rels.append(f'<Relationship Type="Image" Target="/{p}" Id="{rid()}" />')
rels.append("</Relationships>")

now = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S.0000000+07:00")
info = ['﻿<?xml version="1.0" encoding="utf-8"?>', "<MenuPackageParts>"]
for p in cui_parts:
    info.append(f'  <PartData PartData_Name="/{p}" PartData_Modified="{now}" />')
info.append(f'  <PartData PartData_Name="/VirtualMNRRoot" PartData_Modified="{now}" />')
for p in pngs + ["Menu_Package_Info.xml"]:
    info.append(f'  <PartData PartData_Name="/{p}" PartData_Modified="{now}" />')
info.append("</MenuPackageParts>")

path = os.path.join(OUT, "VXT_TIENGVIET.cuix")
with zipfile.ZipFile(path, "w") as z:
    for p in cui_parts:
        z.writestr(zipfile.ZipInfo(p), content[p], zipfile.ZIP_DEFLATED)
    z.writestr("_rels/.rels", "".join(rels).encode("utf-8"), zipfile.ZIP_STORED)
    for p in pngs:
        z.writestr(p, content[p], zipfile.ZIP_DEFLATED)
    z.writestr("Menu_Package_Info.xml", "\n".join(info).encode("utf-8"), zipfile.ZIP_DEFLATED)
    z.writestr("[Content_Types].xml", open(os.path.join(T, "[Content_Types].xml"), "rb").read(), zipfile.ZIP_DEFLATED)

# kiem tra XML hop le
import xml.dom.minidom
for p in ("MenuGroup.cui", "RibbonRoot.cui"):
    xml.dom.minidom.parseString(content[p])
with open(os.path.join(OUT, "VXT_TIENGVIET.mnl"), "w", newline="\r\n") as f:
    f.write(";;; Tu dong nap khi AutoCAD nap menu VXT_TIENGVIET.cuix\n"
            "(if (not c:TCVN2UNI)\n  (if (setq vxt:f (findfile \"VXT_TCVN2UNI.lsp\")) (load vxt:f)))\n(princ)\n")
print("ok", path, os.path.getsize(path), pngs)
