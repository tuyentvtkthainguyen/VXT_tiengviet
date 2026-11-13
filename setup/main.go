// VXT Tieng Viet - bo cai dat cho AutoCAD (Windows).
// Chep chuong trinh vao Documents\VXT_Tools va dang ky vao moi profile AutoCAD:
// Support File Search Path, Trusted Paths, Startup Suite.
// Khong ket noi mang, khong thu thap du lieu.
package main

import (
	"embed"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"unsafe"
)

//go:embed files/*
var files embed.FS

var (
	user32   = syscall.NewLazyDLL("user32.dll")
	advapi32 = syscall.NewLazyDLL("advapi32.dll")
	shell32  = syscall.NewLazyDLL("shell32.dll")

	procMessageBox      = user32.NewProc("MessageBoxW")
	procRegOpenKeyEx    = advapi32.NewProc("RegOpenKeyExW")
	procRegCreateKeyEx  = advapi32.NewProc("RegCreateKeyExW")
	procRegEnumKeyEx    = advapi32.NewProc("RegEnumKeyExW")
	procRegQueryValueEx = advapi32.NewProc("RegQueryValueExW")
	procRegSetValueEx   = advapi32.NewProc("RegSetValueExW")
	procRegCloseKey     = advapi32.NewProc("RegCloseKey")
	procSHGetFolderPath = shell32.NewProc("SHGetFolderPathW")
)

const (
	hkcu          = 0x80000001
	keyAll        = 0xF003F
	keyRead       = 0x20019
	regSZ         = 1
	regExpandSZ   = 2
	mbOK          = 0x0
	mbOKCancel    = 0x1
	mbRetryCancel = 0x5
	mbIconInfo    = 0x40
	mbIconWarn    = 0x30
	mbIconErr     = 0x10
	idOK          = 1
	idRetry       = 4
	csidlPersonal = 5
	title         = "VXT Tiếng Việt cho AutoCAD - Cài đặt"
)

func u16(s string) *uint16 { p, _ := syscall.UTF16PtrFromString(s); return p }

func msg(text string, flags uintptr) int {
	r, _, _ := procMessageBox.Call(0, uintptr(unsafe.Pointer(u16(text))), uintptr(unsafe.Pointer(u16(title))), flags)
	return int(r)
}

// ---------------- registry ----------------
type hkey uintptr

func openKey(root hkey, path string, access uint32) (hkey, bool) {
	var k hkey
	r, _, _ := procRegOpenKeyEx.Call(uintptr(root), uintptr(unsafe.Pointer(u16(path))), 0, uintptr(access), uintptr(unsafe.Pointer(&k)))
	return k, r == 0
}

func createKey(root hkey, path string) (hkey, bool) {
	var k hkey
	var disp uint32
	r, _, _ := procRegCreateKeyEx.Call(uintptr(root), uintptr(unsafe.Pointer(u16(path))), 0, 0, 0, keyAll, 0,
		uintptr(unsafe.Pointer(&k)), uintptr(unsafe.Pointer(&disp)))
	return k, r == 0
}

func closeKey(k hkey) { procRegCloseKey.Call(uintptr(k)) }

func subKeys(k hkey) []string {
	var out []string
	for i := 0; ; i++ {
		buf := make([]uint16, 512)
		n := uint32(len(buf))
		r, _, _ := procRegEnumKeyEx.Call(uintptr(k), uintptr(i), uintptr(unsafe.Pointer(&buf[0])), uintptr(unsafe.Pointer(&n)), 0, 0, 0, 0)
		if r != 0 {
			break
		}
		out = append(out, syscall.UTF16ToString(buf[:n]))
	}
	return out
}

func getStr(k hkey, name string) (string, uint32, bool) {
	var typ, size uint32
	r, _, _ := procRegQueryValueEx.Call(uintptr(k), uintptr(unsafe.Pointer(u16(name))), 0, uintptr(unsafe.Pointer(&typ)), 0, uintptr(unsafe.Pointer(&size)))
	if r != 0 || (typ != regSZ && typ != regExpandSZ) {
		return "", 0, false
	}
	if size == 0 {
		return "", typ, true
	}
	buf := make([]uint16, size/2+1)
	r, _, _ = procRegQueryValueEx.Call(uintptr(k), uintptr(unsafe.Pointer(u16(name))), 0, uintptr(unsafe.Pointer(&typ)), uintptr(unsafe.Pointer(&buf[0])), uintptr(unsafe.Pointer(&size)))
	if r != 0 {
		return "", 0, false
	}
	return syscall.UTF16ToString(buf), typ, true
}

func setStr(k hkey, name, val string, typ uint32) bool {
	if typ == 0 {
		typ = regSZ
	}
	b, _ := syscall.UTF16FromString(val)
	r, _, _ := procRegSetValueEx.Call(uintptr(k), uintptr(unsafe.Pointer(u16(name))), 0, uintptr(typ),
		uintptr(unsafe.Pointer(&b[0])), uintptr(len(b)*2))
	return r == 0
}

// them thu muc vao chuoi duong dan phan cach bang ';' neu chua co
func addToList(list, dir string) (string, bool) {
	for _, p := range strings.Split(list, ";") {
		if strings.EqualFold(strings.TrimRight(strings.TrimSpace(p), `\`), strings.TrimRight(dir, `\`)) {
			return list, false
		}
	}
	if strings.TrimSpace(list) == "" {
		return dir, true
	}
	return strings.TrimRight(list, ";") + ";" + dir, true
}

// ---------------- cai dat ----------------
func documentsDir() string {
	buf := make([]uint16, 520)
	r, _, _ := procSHGetFolderPath.Call(0, csidlPersonal, 0, 0, uintptr(unsafe.Pointer(&buf[0])))
	if r == 0 {
		if d := syscall.UTF16ToString(buf); d != "" {
			return d
		}
	}
	return filepath.Join(os.Getenv("USERPROFILE"), "Documents")
}

func acadRunning() bool {
	cmd := exec.Command("tasklist", "/FI", "IMAGENAME eq acad.exe", "/NH")
	cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
	out, err := cmd.Output()
	return err == nil && strings.Contains(strings.ToLower(string(out)), "acad.exe")
}

func copyFiles(dir string) error {
	if err := os.MkdirAll(dir, 0755); err != nil {
		return err
	}
	ents, _ := files.ReadDir("files")
	for _, e := range ents {
		dst := filepath.Join(dir, e.Name())
		// giu tu dien nguoi dung da sua
		if strings.EqualFold(e.Name(), "VXT_CHINHTA.txt") {
			if _, err := os.Stat(dst); err == nil {
				continue
			}
		}
		data, _ := files.ReadFile("files/" + e.Name())
		if err := os.WriteFile(dst, data, 0644); err != nil {
			return fmt.Errorf("%s: %v", e.Name(), err)
		}
	}
	return nil
}

// dang ky vao 1 profile AutoCAD. tra ve true neu thanh cong
func setupProfile(profKey, dir, lsp string) bool {
	ok := true
	// 1. Support File Search Path
	if k, good := openKey(hkcu, profKey+`\General`, keyAll); good {
		cur, typ, _ := getStr(k, "ACAD")
		if nv, ch := addToList(cur, dir); ch {
			ok = setStr(k, "ACAD", nv, typ) && ok
		}
		closeKey(k)
	} else {
		ok = false
	}
	// 2. Trusted Paths (de AutoCAD khong hoi khi nap file)
	if k, good := openKey(hkcu, profKey+`\Variables`, keyAll); good {
		cur, typ, _ := getStr(k, "TRUSTEDPATHS")
		if nv, ch := addToList(cur, dir); ch {
			setStr(k, "TRUSTEDPATHS", nv, typ)
		}
		closeKey(k)
	}
	// 3. Startup Suite
	if k, good := createKey(hkcu, profKey+`\Dialogs\Appload\Startup`); good {
		numS, _, _ := getStr(k, "NumStartup")
		n, _ := strconv.Atoi(strings.TrimSpace(numS))
		found := false
		for i := 1; i <= n; i++ {
			v, _, _ := getStr(k, strconv.Itoa(i)+"Startup")
			if strings.EqualFold(filepath.Base(v), "VXT_TCVN2UNI.lsp") {
				found = true
				if !strings.EqualFold(v, lsp) {
					setStr(k, strconv.Itoa(i)+"Startup", lsp, regSZ)
				}
			}
		}
		if !found {
			n++
			ok = setStr(k, strconv.Itoa(n)+"Startup", lsp, regSZ) && setStr(k, "NumStartup", strconv.Itoa(n), regSZ) && ok
		}
		closeKey(k)
	} else {
		ok = false
	}
	return ok
}

func main() {
	dir := filepath.Join(documentsDir(), "VXT_Tools")
	lsp := filepath.Join(dir, "VXT_TCVN2UNI.lsp")

	if msg("Cài đặt bộ công cụ VXT Tiếng Việt cho AutoCAD:\n\n"+
		"• Chuyển chữ TCVN3 / VNI sang Unicode (Text, Mtext, Dim, Block, Table)\n"+
		"• Đổi font lỗi / thiếu sang Arial, tự sửa chính tả\n"+
		"• Tab Ribbon \"VXT Tiếng Việt\" để bấm nút\n\n"+
		"Thư mục cài đặt:\n"+dir+"\n\nBấm OK để cài đặt.", mbOKCancel|mbIconInfo) != idOK {
		return
	}

	for acadRunning() {
		if msg("AutoCAD đang mở.\n\nHãy lưu bản vẽ và ĐÓNG HẾT AutoCAD rồi bấm Retry.\n"+
			"(AutoCAD ghi đè cài đặt khi thoát nên phải đóng trước khi cài.)", mbRetryCancel|mbIconWarn) != idRetry {
			return
		}
	}

	if err := copyFiles(dir); err != nil {
		msg("Không chép được file:\n"+err.Error(), mbOK|mbIconErr)
		return
	}

	var done, failed []string
	if root, ok := openKey(hkcu, `Software\Autodesk\AutoCAD`, keyRead); ok {
		for _, rel := range subKeys(root) { // R24.3 ...
			rk, ok := openKey(root, rel, keyRead)
			if !ok {
				continue
			}
			for _, prod := range subKeys(rk) { // ACAD-7101:409 ...
				base := `Software\Autodesk\AutoCAD\` + rel + `\` + prod + `\Profiles`
				pk, ok := openKey(hkcu, base, keyRead)
				if !ok {
					continue
				}
				for _, prof := range subKeys(pk) {
					name := rel + " / " + prod + " / " + prof
					if setupProfile(base+`\`+prof, dir, lsp) {
						done = append(done, name)
					} else {
						failed = append(failed, name)
					}
				}
				closeKey(pk)
			}
			closeKey(rk)
		}
		closeKey(root)
	}

	if len(done) == 0 {
		msg("Đã chép chương trình vào:\n"+dir+"\n\nNhưng không tìm thấy AutoCAD nào trên máy để đăng ký.\n"+
			"Hãy mở AutoCAD ít nhất 1 lần rồi chạy lại file cài đặt.", mbOK|mbIconWarn)
		return
	}
	text := "Cài đặt xong!\n\nĐã đăng ký vào " + strconv.Itoa(len(done)) + " cấu hình AutoCAD:\n• " + strings.Join(done, "\n• ")
	if len(failed) > 0 {
		text += "\n\nKhông đăng ký được:\n• " + strings.Join(failed, "\n• ")
	}
	text += "\n\nMở AutoCAD: tab Ribbon \"VXT Tiếng Việt\" sẽ tự hiện.\n" +
		"Nếu chưa thấy, gõ lệnh TCVNHUONGDAN.\n\n" +
		"Gỡ: xoá thư mục " + dir + ", gõ CUIUNLOAD chọn VXT_TIENGVIET, và bỏ file khỏi Startup Suite (APPLOAD)."
	msg(text, mbOK|mbIconInfo)
}
