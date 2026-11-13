;;; ==========================================================================
;;; VXT_TCVN2UNI.lsp  v4  -  Sua loi font chu tieng Viet trong AutoCAD
;;; Tac gia: Vu Xuan Tuyen (VXT)
;;;
;;; LENH
;;;   TCVN2UNI        Chuyen ban ve dang mo (Toan bo / Chon doi tuong)
;;;   TCVN2UNI_THUMUC Chuyen hang loat moi file DWG trong 1 thu muc
;;;                   (sao luu ban goc vao thu muc con _BanGoc_VXT)
;;;   TCVNCAIDAT      Cai dat: font dich, nhan dien loi font, sua chinh ta
;;;   TCVNEP          Ep chuyen doi tuong chon theo bang ma chi dinh
;;;
;;; CHUC NANG
;;;  - Chu dung font TCVN3 (.VnTime, .VnArial, .VnTimeH...) -> Unicode
;;;  - Chu dung font VNI (VNI-Times...) -> Unicode
;;;  - Tu nhan dien chu bi loi font (ma TCVN3 / VNI nam trong font khac)
;;;  - Kieu chu thieu font tren may, font SHX co chu tieng Viet -> Arial
;;;  - Sua chinh ta: ghep dau to hop, tu dien loi thuong gap
;;;    (file VXT_CHINHTA.txt), thong nhat kieu dat dau (tuy chon)
;;;  - TEXT, MTEXT, ATTDEF, ATTRIB, DIMENSION, MULTILEADER, TABLE, ca trong Block
;;;
;;; Chuong trinh chay hoan toan tren may, khong ket noi mang,
;;; khong thu thap du lieu.
;;; ==========================================================================

(vl-load-com)

;;; ------------------------------------------------ du lieu bang ma -----
(setq *vn:tbl* '(
    (161 258 258) (162 194 194) (163 202 202) (164 212 212) (165 416 416) (166 431 431)
    (167 272 272) (168 259 258) (169 226 194) (170 234 202) (171 244 212) (172 417 416)
    (173 432 431) (174 273 272) (181 224 192) (182 7843 7842) (183 227 195) (184 225 193)
    (185 7841 7840) (187 7857 7856) (188 7859 7858) (189 7861 7860) (190 7855 7854) (198 7863 7862)
    (199 7847 7846) (200 7849 7848) (201 7851 7850) (202 7845 7844) (203 7853 7852) (204 232 200)
    (206 7867 7866) (207 7869 7868) (208 233 201) (209 7865 7864) (210 7873 7872) (211 7875 7874)
    (212 7877 7876) (213 7871 7870) (214 7879 7878) (215 236 204) (216 7881 7880) (220 297 296)
    (221 237 205) (222 7883 7882) (223 242 210) (225 7887 7886) (226 245 213) (227 243 211)
    (228 7885 7884) (229 7891 7890) (230 7893 7892) (231 7895 7894) (232 7889 7888) (233 7897 7896)
    (234 7901 7900) (235 7903 7902) (236 7905 7904) (237 7899 7898) (238 7907 7906) (239 249 217)
    (241 7911 7910) (242 361 360) (243 250 218) (244 7909 7908) (245 7915 7914) (246 7917 7916)
    (247 7919 7918) (248 7913 7912) (249 7921 7920) (250 7923 7922) (251 7927 7926) (252 7929 7928)
    (253 253 221) (254 7925 7924)))

(setq *vn:cp1252* '(
    (128 . 8364) (130 . 8218) (131 . 402) (132 . 8222) (133 . 8230) (134 . 8224) (135 . 8225) (136 . 710)
    (137 . 8240) (138 . 352) (139 . 8249) (140 . 338) (142 . 381) (145 . 8216) (146 . 8217) (147 . 8220)
    (148 . 8221) (149 . 8226) (150 . 8211) (151 . 8212) (152 . 732) (153 . 8482) (154 . 353) (155 . 8250)
    (156 . 339) (158 . 382) (159 . 376)))

(setq *vn:cp1258* '(
    (128 . 8364) (130 . 8218) (131 . 402) (132 . 8222) (133 . 8230) (134 . 8224) (135 . 8225) (136 . 710)
    (137 . 8240) (139 . 8249) (140 . 338) (145 . 8216) (146 . 8217) (147 . 8220) (148 . 8221) (149 . 8226)
    (150 . 8211) (151 . 8212) (152 . 732) (153 . 8482) (155 . 8250) (156 . 339) (159 . 376) (195 . 258)
    (204 . 768) (208 . 272) (210 . 777) (213 . 416) (221 . 431) (222 . 771) (227 . 259) (236 . 769)
    (240 . 273) (242 . 803) (245 . 417) (253 . 432) (254 . 8363)))

(setq *vn:u2b* '(
    (258 . 195) (259 . 227) (272 . 208) (273 . 240) (338 . 140) (339 . 156) (352 . 138) (353 . 154)
    (376 . 159) (381 . 142) (382 . 158) (402 . 131) (416 . 213) (417 . 245) (431 . 221) (432 . 253)
    (710 . 136) (732 . 152) (768 . 204) (769 . 236) (771 . 222) (777 . 210) (803 . 242) (8211 . 150)
    (8212 . 151) (8216 . 145) (8217 . 146) (8218 . 130) (8220 . 147) (8221 . 148) (8222 . 132) (8224 . 134)
    (8225 . 135) (8226 . 149) (8230 . 133) (8240 . 137) (8249 . 139) (8250 . 155) (8363 . 254) (8364 . 128)
    (8482 . 153)))

(setq *vn:letters* '(
    192 193 194 195 200 201 202 204 205 210 211 212 213 217 218 221
    224 225 226 227 232 233 234 236 237 242 243 244 245 249 250 253
    258 259 272 273 296 297 360 361 416 417 431 432 7840 7841 7842 7843
    7844 7845 7846 7847 7848 7849 7850 7851 7852 7853 7854 7855 7856 7857 7858 7859
    7860 7861 7862 7863 7864 7865 7866 7867 7868 7869 7870 7871 7872 7873 7874 7875
    7876 7877 7878 7879 7880 7881 7882 7883 7884 7885 7886 7887 7888 7889 7890 7891
    7892 7893 7894 7895 7896 7897 7898 7899 7900 7901 7902 7903 7904 7905 7906 7907
    7908 7909 7910 7911 7912 7913 7914 7915 7916 7917 7918 7919 7920 7921 7922 7923
    7924 7925 7926 7927 7928 7929))

(setq *vn:symok* '(215 176 177 178 179 216 160 186 8709 8960 8804 8805 8776 8240 8216 8217 8220 8221 8211 8212 8230 8226 8364))

(setq *vn:comb* '(768 769 771 777 803 770 774 795))

(setq *vn:tdec* '(
    (192 65 1) (193 65 2) (195 65 4) (200 69 1) (201 69 2) (204 73 1)
    (205 73 2) (210 79 1) (211 79 2) (213 79 4) (217 85 1) (218 85 2)
    (221 89 2) (224 97 1) (225 97 2) (227 97 4) (232 101 1) (233 101 2)
    (236 105 1) (237 105 2) (242 111 1) (243 111 2) (245 111 4) (249 117 1)
    (250 117 2) (253 121 2) (296 73 4) (297 105 4) (360 85 4) (361 117 4)
    (7840 65 5) (7841 97 5) (7842 65 3) (7843 97 3) (7844 194 2) (7845 226 2)
    (7846 194 1) (7847 226 1) (7848 194 3) (7849 226 3) (7850 194 4) (7851 226 4)
    (7852 194 5) (7853 226 5) (7854 258 2) (7855 259 2) (7856 258 1) (7857 259 1)
    (7858 258 3) (7859 259 3) (7860 258 4) (7861 259 4) (7862 258 5) (7863 259 5)
    (7864 69 5) (7865 101 5) (7866 69 3) (7867 101 3) (7868 69 4) (7869 101 4)
    (7870 202 2) (7871 234 2) (7872 202 1) (7873 234 1) (7874 202 3) (7875 234 3)
    (7876 202 4) (7877 234 4) (7878 202 5) (7879 234 5) (7880 73 3) (7881 105 3)
    (7882 73 5) (7883 105 5) (7884 79 5) (7885 111 5) (7886 79 3) (7887 111 3)
    (7888 212 2) (7889 244 2) (7890 212 1) (7891 244 1) (7892 212 3) (7893 244 3)
    (7894 212 4) (7895 244 4) (7896 212 5) (7897 244 5) (7898 416 2) (7899 417 2)
    (7900 416 1) (7901 417 1) (7902 416 3) (7903 417 3) (7904 416 4) (7905 417 4)
    (7906 416 5) (7907 417 5) (7908 85 5) (7909 117 5) (7910 85 3) (7911 117 3)
    (7912 431 2) (7913 432 2) (7914 431 1) (7915 432 1) (7916 431 3) (7917 432 3)
    (7918 431 4) (7919 432 4) (7920 431 5) (7921 432 5) (7922 89 1) (7923 121 1)
    (7924 89 5) (7925 121 5) (7926 89 3) (7927 121 3) (7928 89 4) (7929 121 4)))

(setq *vn:tcomp* '(
    (521 . 192) (522 . 193) (523 . 7842) (524 . 195) (525 . 7840) (553 . 200) (554 . 201) (555 . 7866)
    (556 . 7868) (557 . 7864) (585 . 204) (586 . 205) (587 . 7880) (588 . 296) (589 . 7882) (633 . 210)
    (634 . 211) (635 . 7886) (636 . 213) (637 . 7884) (681 . 217) (682 . 218) (683 . 7910) (684 . 360)
    (685 . 7908) (713 . 7922) (714 . 221) (715 . 7926) (716 . 7928) (717 . 7924) (777 . 224) (778 . 225)
    (779 . 7843) (780 . 227) (781 . 7841) (809 . 232) (810 . 233) (811 . 7867) (812 . 7869) (813 . 7865)
    (841 . 236) (842 . 237) (843 . 7881) (844 . 297) (845 . 7883) (889 . 242) (890 . 243) (891 . 7887)
    (892 . 245) (893 . 7885) (937 . 249) (938 . 250) (939 . 7911) (940 . 361) (941 . 7909) (969 . 7923)
    (970 . 253) (971 . 7927) (972 . 7929) (973 . 7925) (1553 . 7846) (1554 . 7844) (1555 . 7848) (1556 . 7850)
    (1557 . 7852) (1617 . 7872) (1618 . 7870) (1619 . 7874) (1620 . 7876) (1621 . 7878) (1697 . 7890) (1698 . 7888)
    (1699 . 7892) (1700 . 7894) (1701 . 7896) (1809 . 7847) (1810 . 7845) (1811 . 7849) (1812 . 7851) (1813 . 7853)
    (1873 . 7873) (1874 . 7871) (1875 . 7875) (1876 . 7877) (1877 . 7879) (1953 . 7891) (1954 . 7889) (1955 . 7893)
    (1956 . 7895) (1957 . 7897) (2065 . 7856) (2066 . 7854) (2067 . 7858) (2068 . 7860) (2069 . 7862) (2073 . 7857)
    (2074 . 7855) (2075 . 7859) (2076 . 7861) (2077 . 7863) (3329 . 7900) (3330 . 7898) (3331 . 7902) (3332 . 7904)
    (3333 . 7906) (3337 . 7901) (3338 . 7899) (3339 . 7903) (3340 . 7905) (3341 . 7907) (3449 . 7914) (3450 . 7912)
    (3451 . 7916) (3452 . 7918) (3453 . 7920) (3457 . 7915) (3458 . 7913) (3459 . 7917) (3460 . 7919) (3461 . 7921)))

(setq *vn:nfcmap* '(
    (65068 . 192) (65069 . 193) (65070 . 194) (65071 . 195) (65074 . 258) (65077 . 7842) (65103 . 7840) (69068 . 200)
    (69069 . 201) (69070 . 202) (69071 . 7868) (69077 . 7866) (69103 . 7864) (73068 . 204) (73069 . 205) (73071 . 296)
    (73077 . 7880) (73103 . 7882) (79068 . 210) (79069 . 211) (79070 . 212) (79071 . 213) (79077 . 7886) (79095 . 416)
    (79103 . 7884) (85068 . 217) (85069 . 218) (85071 . 360) (85077 . 7910) (85095 . 431) (85103 . 7908) (89068 . 7922)
    (89069 . 221) (89071 . 7928) (89077 . 7926) (89103 . 7924) (97068 . 224) (97069 . 225) (97070 . 226) (97071 . 227)
    (97074 . 259) (97077 . 7843) (97103 . 7841) (101068 . 232) (101069 . 233) (101070 . 234) (101071 . 7869) (101077 . 7867)
    (101103 . 7865) (105068 . 236) (105069 . 237) (105071 . 297) (105077 . 7881) (105103 . 7883) (111068 . 242) (111069 . 243)
    (111070 . 244) (111071 . 245) (111077 . 7887) (111095 . 417) (111103 . 7885) (117068 . 249) (117069 . 250) (117071 . 361)
    (117077 . 7911) (117095 . 432) (117103 . 7909) (121068 . 7923) (121069 . 253) (121071 . 7929) (121077 . 7927) (121103 . 7925)
    (194068 . 7846) (194069 . 7844) (194071 . 7850) (194077 . 7848) (194103 . 7852) (202068 . 7872) (202069 . 7870) (202071 . 7876)
    (202077 . 7874) (202103 . 7878) (212068 . 7890) (212069 . 7888) (212071 . 7894) (212077 . 7892) (212103 . 7896) (226068 . 7847)
    (226069 . 7845) (226071 . 7851) (226077 . 7849) (226103 . 7853) (234068 . 7873) (234069 . 7871) (234071 . 7877) (234077 . 7875)
    (234103 . 7879) (244068 . 7891) (244069 . 7889) (244071 . 7895) (244077 . 7893) (244103 . 7897) (258068 . 7856) (258069 . 7854)
    (258071 . 7860) (258077 . 7858) (258103 . 7862) (259068 . 7857) (259069 . 7855) (259071 . 7861) (259077 . 7859) (259103 . 7863)
    (416068 . 7900) (416069 . 7898) (416071 . 7904) (416077 . 7902) (416103 . 7906) (417068 . 7901) (417069 . 7899) (417071 . 7905)
    (417077 . 7903) (417103 . 7907) (431068 . 7914) (431069 . 7912) (431071 . 7918) (431077 . 7916) (431103 . 7920) (432068 . 7915)
    (432069 . 7913) (432071 . 7919) (432077 . 7917) (432103 . 7921)))

(setq *vn:upmap* '(
    (224 . 192) (225 . 193) (226 . 194) (227 . 195) (232 . 200) (233 . 201) (234 . 202) (236 . 204)
    (237 . 205) (242 . 210) (243 . 211) (244 . 212) (245 . 213) (249 . 217) (250 . 218) (253 . 221)
    (259 . 258) (273 . 272) (297 . 296) (361 . 360) (417 . 416) (432 . 431) (7841 . 7840) (7843 . 7842)
    (7845 . 7844) (7847 . 7846) (7849 . 7848) (7851 . 7850) (7853 . 7852) (7855 . 7854) (7857 . 7856) (7859 . 7858)
    (7861 . 7860) (7863 . 7862) (7865 . 7864) (7867 . 7866) (7869 . 7868) (7871 . 7870) (7873 . 7872) (7875 . 7874)
    (7877 . 7876) (7879 . 7878) (7881 . 7880) (7883 . 7882) (7885 . 7884) (7887 . 7886) (7889 . 7888) (7891 . 7890)
    (7893 . 7892) (7895 . 7894) (7897 . 7896) (7899 . 7898) (7901 . 7900) (7903 . 7902) (7905 . 7904) (7907 . 7906)
    (7909 . 7908) (7911 . 7910) (7913 . 7912) (7915 . 7914) (7917 . 7916) (7919 . 7918) (7921 . 7920) (7923 . 7922)
    (7925 . 7924) (7927 . 7926) (7929 . 7928)))

(setq *vn:vnimark* '(
    (192 1 1) (193 1 2) (194 1 0) (195 1 4) (196 1 5) (197 1 3)
    (200 2 1) (201 2 2) (202 2 0) (203 2 5) (207 0 5) (213 0 4)
    (216 0 1) (217 0 2) (218 2 3) (219 0 3) (220 2 4) (224 1 1)
    (225 1 2) (226 1 0) (227 1 4) (228 1 5) (229 1 3) (232 2 1)
    (233 2 2) (234 2 0) (235 2 5) (239 0 5) (245 0 4) (248 0 1)
    (249 0 2) (250 2 3) (251 0 3) (252 2 4)))

(setq *vn:vnisingle* '(
    (198 . 7880) (204 . 204) (205 . 205) (206 . 7924) (209 . 272) (210 . 7882) (211 . 296) (212 . 416)
    (214 . 431) (230 . 7881) (236 . 236) (237 . 237) (238 . 7925) (241 . 273) (242 . 7883) (243 . 297)
    (244 . 417) (246 . 432)))

(setq *vn:vnilm* '(249 245 226 234 224 225 227 232 233 250 217 213 194 202 192 193 195 200 201 218))

(setq *vn:dict0* '(
    ((115 7917 32 108 253) (120 7917 32 108 253))
    ((120 7855 112 32 120 7871 112) (115 7855 112 32 120 7871 112))
    ((115 7855 112 32 115 7871 112) (115 7855 112 32 120 7871 112))
    ((120 225 99 32 120 117 7845 116) (120 225 99 32 115 117 7845 116))
    ((115 225 116 32 120 117 7845 116) (120 225 99 32 115 117 7845 116))
    ((120 117 7845 116 32 120 7855 99) (120 117 7845 116 32 115 7855 99))
    ((115 117 7845 116 32 115 7855 99) (120 117 7845 116 32 115 7855 99))
    ((99 104 117 7849 110 32 273 111 225 110) (99 104 7849 110 32 273 111 225 110))
    ((98 7893 32 120 117 110 103) (98 7893 32 115 117 110 103))
    ((99 104 105 97 32 115 7869) (99 104 105 97 32 115 7867))
    ((100 7919 32 103 236 110) (103 105 7919 32 103 236 110))
    ((120 117 109 32 104 7885 112) (115 117 109 32 104 7885 112))
    ((107 105 7877 109 32 116 114 97) (107 105 7875 109 32 116 114 97))
    ((107 105 7877 109 32 115 111 225 116) (107 105 7875 109 32 115 111 225 116))
    ((115 226 121 32 100 7921 110 103) (120 226 121 32 100 7921 110 103))
    ((116 432 7901 110 103 32 115 226 121) (116 432 7901 110 103 32 120 226 121))
    ((103 7841 99 104 32 115 226 121) (103 7841 99 104 32 120 226 121))
    ((99 7889 116 32 116 104 7871 112) (99 7889 116 32 116 104 233 112))
    ((99 97 111 32 273 7885) (99 97 111 32 273 7897))
    ((98 7843 110 32 118 7867) (98 7843 110 32 118 7869))
    ((99 104 105 32 116 105 7871 99) (99 104 105 32 116 105 7871 116))
    ((103 104 105 32 116 114 250) (103 104 105 32 99 104 250))
    ((107 237 99 104 32 116 104 432 7899 116) (107 237 99 104 32 116 104 432 7899 99))
    ((116 105 234 117 32 99 104 117 7851 110) (116 105 234 117 32 99 104 117 7849 110))
    ((120 105 45 109 259 110 103) (120 105 32 109 259 110 103))
    ((98 234 45 116 244 110 103) (98 234 32 116 244 110 103))
    ((116 104 111 225 116 32 110 432 7899 116) (116 104 111 225 116 32 110 432 7899 99))
    ((7889 110 103 32 116 104 111 225 99) (7889 110 103 32 116 104 111 225 116))
    ((110 103 104 105 7879 109 32 116 104 226 117) (110 103 104 105 7879 109 32 116 104 117))
    ((116 114 225 116 32 118 7917 97) (116 114 225 116 32 118 7919 97))
    ((118 7917 97 32 120 105 32 109 259 110 103) (118 7919 97 32 120 105 32 109 259 110 103))
    ((100 7857 109 32 98 111) (100 7847 109 32 98 111))
    ((103 105 7857 110 32 116 432 7901 110 103) (103 105 7857 110 103 32 116 432 7901 110 103))
    ((109 243 110 103 32 98 7857 110 103) (109 243 110 103 32 98 259 110 103))))

(setq *vn:rhymes* '(
    (97)
    (97 99)
    (97 99 104)
    (97 105)
    (97 109)
    (97 110)
    (97 110 103)
    (97 110 104)
    (97 111)
    (97 112)
    (97 116)
    (97 117)
    (97 121)
    (101)
    (101 99)
    (101 109)
    (101 110)
    (101 110 103)
    (101 111)
    (101 112)
    (101 116)
    (105)
    (105 97)
    (105 99 104)
    (105 109)
    (105 110)
    (105 110 104)
    (105 112)
    (105 116)
    (105 117)
    (105 234 99)
    (105 234 109)
    (105 234 110)
    (105 234 110 103)
    (105 234 112)
    (105 234 116)
    (105 234 117)
    (111)
    (111 97)
    (111 97 99)
    (111 97 99 104)
    (111 97 105)
    (111 97 109)
    (111 97 110)
    (111 97 110 103)
    (111 97 110 104)
    (111 97 111)
    (111 97 112)
    (111 97 116)
    (111 97 121)
    (111 99)
    (111 101)
    (111 101 110)
    (111 101 111)
    (111 101 116)
    (111 105)
    (111 109)
    (111 110)
    (111 110 103)
    (111 111 99)
    (111 111 110 103)
    (111 112)
    (111 116)
    (111 259 99)
    (111 259 109)
    (111 259 110)
    (111 259 110 103)
    (111 259 116)
    (117)
    (117 97)
    (117 99)
    (117 105)
    (117 109)
    (117 110)
    (117 110 103)
    (117 112)
    (117 116)
    (117 121)
    (117 121 97)
    (117 121 99 104)
    (117 121 110 104)
    (117 121 116)
    (117 121 117)
    (117 121 234 110)
    (117 121 234 116)
    (117 226 110)
    (117 226 110 103)
    (117 226 116)
    (117 226 121)
    (117 234)
    (117 234 99 104)
    (117 234 110 104)
    (117 244 99)
    (117 244 105)
    (117 244 109)
    (117 244 110)
    (117 244 110 103)
    (117 244 116)
    (117 417)
    (121)
    (121 234 109)
    (121 234 110)
    (121 234 116)
    (121 234 117)
    (226 99)
    (226 109)
    (226 110)
    (226 110 103)
    (226 112)
    (226 116)
    (226 117)
    (226 121)
    (234)
    (234 99 104)
    (234 109)
    (234 110)
    (234 110 104)
    (234 112)
    (234 116)
    (234 117)
    (244)
    (244 99)
    (244 105)
    (244 109)
    (244 110)
    (244 110 103)
    (244 112)
    (244 116)
    (259 99)
    (259 109)
    (259 110)
    (259 110 103)
    (259 112)
    (259 116)
    (417)
    (417 105)
    (417 109)
    (417 110)
    (417 112)
    (417 116)
    (432)
    (432 97)
    (432 99)
    (432 105)
    (432 109)
    (432 110)
    (432 110 103)
    (432 116)
    (432 117)
    (432 417 99)
    (432 417 105)
    (432 417 109)
    (432 417 110)
    (432 417 110 103)
    (432 417 112)
    (432 417 116)
    (432 417 117)))

(setq *vn:onsets* '(
    (110 103 104) (110 103) (110 104) (99 104) (103 104) (103 105) (107 104) (112 104) (113 117) (116 104) (116 114) (98) (99) (100) (273) (103) (104) (107) (108) (109) (110) (112) (114) (115) (116) (118) (120)))

(setq *vn:lowmap* '(
    (192 . 224) (193 . 225) (194 . 226) (195 . 227) (200 . 232) (201 . 233) (202 . 234) (204 . 236) (205 . 237) (210 . 242) (211 . 243) (212 . 244) (213 . 245) (217 . 249) (218 . 250) (221 . 253) (258 . 259) (272 . 273) (296 . 297) (360 . 361) (416 . 417) (431 . 432) (7840 . 7841) (7842 . 7843) (7844 . 7845) (7846 . 7847) (7848 . 7849) (7850 . 7851) (7852 . 7853) (7854 . 7855) (7856 . 7857) (7858 . 7859) (7860 . 7861) (7862 . 7863) (7864 . 7865) (7866 . 7867) (7868 . 7869) (7870 . 7871) (7872 . 7873) (7874 . 7875) (7876 . 7877) (7878 . 7879) (7880 . 7881) (7882 . 7883) (7884 . 7885) (7886 . 7887) (7888 . 7889) (7890 . 7891) (7892 . 7893) (7894 . 7895) (7896 . 7897) (7898 . 7899) (7900 . 7901) (7902 . 7903) (7904 . 7905) (7906 . 7907) (7908 . 7909) (7910 . 7911) (7912 . 7913) (7914 . 7915) (7916 . 7917) (7918 . 7919) (7920 . 7921) (7922 . 7923) (7924 . 7925) (7926 . 7927) (7928 . 7929)))


;;; ============================================================ CAI DAT ====
(defun vn:getset ()
  (setq *vn:font*   (cond ((getenv "VXT_TCVN_FONT")) (T "Arial"))
        *vn:detect* (/= (getenv "VXT_TCVN_DETECT") "0")
        *vn:spell*  (/= (getenv "VXT_TCVN_SPELL") "0")
        *vn:tonest* (cond ((getenv "VXT_TCVN_TONE")) (T "Giu"))
        *vn:allar*  (= (getenv "VXT_TCVN_ALLARIAL") "1")))

(defun vn:saveset ()
  (setenv "VXT_TCVN_FONT" *vn:font*)
  (setenv "VXT_TCVN_DETECT" (if *vn:detect* "1" "0"))
  (setenv "VXT_TCVN_SPELL" (if *vn:spell* "1" "0"))
  (setenv "VXT_TCVN_TONE" *vn:tonest*)
  (setenv "VXT_TCVN_ALLARIAL" (if *vn:allar* "1" "0")))

(defun vn:showset ()
  (princ (strcat
    "\n  Cai dat: Font dich=" *vn:font*
    " | Nhan dien loi font=" (if *vn:detect* "Co" "Khong")
    " | Sua chinh ta=" (if *vn:spell* "Co" "Khong")
    " | Kieu dau=" (cond ((= *vn:tonest* "Cu") "Cu (hoa, thuy)")
                         ((= *vn:tonest* "Moi") "Moi (hoa`, thuy')")
                         (T "Giu nguyen"))
    " | Moi kieu chu ve Arial=" (if *vn:allar* "Co" "Khong"))))

(defun c:TCVNCAIDAT (/ kw k)
  (vn:getset)
  (while
    (progn
      (vn:showset)
      (initget "Font Nhandien Chinhta Kieudau Arialtatca Xong")
      (setq kw (getkword
        "\nThay doi [Font/Nhandien/Chinhta/Kieudau/Arialtatca/Xong] <Xong>: "))
      (and kw (/= kw "Xong")))
    (cond
      ((= kw "Font")
       (initget "Arial Times Tudong")
       (setq k (getkword
         "\nFont cho chu TCVN3/VNI [Arial/Times new roman/Tudong (.VnArial->Arial, con lai->Times)] <Arial>: "))
       (setq *vn:font* (if k k "Arial")))
      ((= kw "Nhandien") (setq *vn:detect* (not *vn:detect*)))
      ((= kw "Chinhta") (setq *vn:spell* (not *vn:spell*)))
      ((= kw "Kieudau")
       (initget "Giu Cu Moi")
       (setq k (getkword
         "\nKieu dat dau oa/oe/uy [Giu nguyen/Cu (hoa thuy dau o chu dau)/Moi (dau o chu sau)] <Giu>: "))
       (setq *vn:tonest* (if k k "Giu")))
      ((= kw "Arialtatca") (setq *vn:allar* (not *vn:allar*)))))
  (vn:saveset)
  (princ "\nDa luu cai dat.")
  (princ))

;;; ============================================================ TIEN ICH ===
(defun vn:hex4 (n / s h)
  (setq s "")
  (repeat 4
    (setq h (rem n 16)
          s (strcat (substr "0123456789ABCDEF" (1+ h) 1) s)
          n (/ n 16)))
  s)

(defun vn:hexd (c)
  (cond ((null c) nil)
        ((and (>= c 48) (<= c 57)) (- c 48))
        ((and (>= c 65) (<= c 70)) (- c 55))
        ((and (>= c 97) (<= c 102)) (- c 87))))

;;; danh sach ma bat dau bang \U+XXXX -> ma Unicode
(defun vn:esc (l / a b c d)
  (if (and (= (car l) 92) (member (cadr l) '(85 117)) (= (caddr l) 43)
           (setq a (vn:hexd (nth 3 l))) (setq b (vn:hexd (nth 4 l)))
           (setq c (vn:hexd (nth 5 l))) (setq d (vn:hexd (nth 6 l))))
    (+ (* a 4096) (* b 256) (* c 16) d)))

(defun vn:drop (l n) (repeat n (setq l (cdr l))) l)
(defun vn:take (l n / r)
  (while (and l (> n 0)) (setq r (cons (car l) r) l (cdr l) n (1- n)))
  (reverse r))

(defun vn:u2b (u)
  (cond ((null u) nil) ((< u 256) u) ((cdr (assoc u *vn:u2b*)))))

;;; ma ky tu doc tu chuoi -> Unicode
(defun vn:c2u (c)
  (if (< c 0) (setq c (+ c 256)))
  (cond (*vn:uni* c)
        ((< c 128) c)
        ((cdr (assoc c *vn:cpmap*)))
        (T c)))

(defun vn:s2cp (s / l out u)
  (setq l (vl-string->list s))
  (while l
    (if (setq u (vn:esc l))
      (setq out (cons u out) l (vn:drop l 7))
      (setq out (cons (vn:c2u (car l)) out) l (cdr l))))
  (reverse out))

(defun vn:emit1 (u)
  (cond ((< u 128) (chr u))
        (*vn:uni* (chr u))
        (T (strcat "\\U+" (vn:hex4 u)))))

(defun vn:cp2s (l) (apply 'strcat (mapcar 'vn:emit1 l)))

(defun vn:digp (x) (and x (>= x 48) (<= x 57)))
(defun vn:upa (u) (if (and (>= u 97) (<= u 122)) (- u 32) u))
(defun vn:lowa (u) (if (and (>= u 65) (<= u 90)) (+ u 32) u))
(defun vn:letp (u) (and u (member u *vn:letters*)))
(defun vn:wordp (u)
  (and u (or (and (>= u 65) (<= u 90)) (and (>= u 97) (<= u 122))
             (and (>= u 48) (<= u 57)) (member u *vn:letters*) (member u *vn:comb*))))

;;; so ky tu "rac" (khong phai chu tieng Viet / ky hieu thong dung)
(defun vn:garb (l / n)
  (setq n 0)
  (foreach u l
    (if (and (>= u 128) (< u 880) (not (member u *vn:letters*))
             (not (member u *vn:symok*)) (not (member u *vn:comb*)))
      (setq n (1+ n))))
  n)

;;; so chu tieng Viet Unicode ngoai bang Latin-1 (a(, d-, o+, u+, a. ...)
(defun vn:beyond (l / n)
  (setq n 0)
  (foreach u l (if (and (>= u 256) (member u *vn:letters*)) (setq n (1+ n))))
  n)

;;; dau hieu VNI: nguyen am + ky tu dau VNI
(defun vn:vniev (l / n p)
  (setq n 0 p nil)
  (foreach u l
    (if (and p (member u *vn:vnilm*)
             (or (member p '(97 101 65 69))
                 (and (member p '(121 89)) (not (member u '(234 202))))
                 (and (member p '(111 79)) (member u '(249 245 226 217 213 194)))))
      (setq n (1+ n)))
    (setq p u))
  n)

;;; ============================================================ GIAI MA ====
(defun vn:dtcvn (l k / out u b e prev nx)
  (while l
    (setq u (car l) nx (cadr l) l (cdr l) b (vn:u2b u))
    (setq out (cons
                (cond ((null b) u)
                      ((< b 128) (if (= k "H") (vn:upa u) u))
                      ((and (member b '(215 216)) (or (vn:digp prev) (vn:digp nx))) u)
                      ((setq e (assoc b *vn:tbl*)) (if (= k "H") (caddr e) (cadr e)))
                      (T u))
                out)
          prev u))
  (reverse out))

(defun vn:tcomp (b tn) (cdr (assoc (+ (* b 8) tn) *vn:tcomp*)))

(defun vn:vnibase (b)
  (cond ((null b) nil)
        ((member b '(97 101 111 117 121 65 69 79 85 89)) b)
        ((= b 244) 417) ((= b 246) 432) ((= b 212) 416) ((= b 214) 431)))

(defun vn:vnicomp (base md tn / bb)
  (setq bb (cond ((= md 0) base)
                 ((= md 1) (cdr (assoc base '((97 . 226) (65 . 194) (101 . 234)
                                              (69 . 202) (111 . 244) (79 . 212)))))
                 ((= md 2) (cdr (assoc base '((97 . 259) (65 . 258)))))))
  (cond ((null bb) nil)
        ((= tn 0) (if (= md 0) nil bb))
        (T (vn:tcomp bb tn))))

(defun vn:dvni (l / out u b base m r)
  (while l
    (setq u (car l) l (cdr l) b (vn:u2b u) base (vn:vnibase b) r nil)
    (if (and base l (setq m (assoc (vn:u2b (car l)) *vn:vnimark*)))
      (setq r (vn:vnicomp base (cadr m) (caddr m))))
    (if r
      (setq out (cons r out) l (cdr l))
      (setq out (cons (cond ((null b) u) ((cdr (assoc b *vn:vnisingle*))) (T u)) out))))
  (reverse out))

;;; ============================================================ CHINH TA ===
(defun vn:nfc (l / out c)
  (foreach u l
    (if (and out (member u *vn:comb*)
             (setq c (cdr (assoc (+ (* (car out) 1000) (- u 700)) *vn:nfcmap*))))
      (setq out (cons c (cdr out)))
      (setq out (cons u out))))
  (reverse out))

(defun vn:upc (u) (cond ((and (>= u 97) (<= u 122)) (- u 32)) ((cdr (assoc u *vn:upmap*))) (T u)))

(defun vn:prefixp (w l)
  (while (and w l (= (car w) (car l))) (setq w (cdr w) l (cdr l)))
  (null w))

(defun vn:replw (l w r / out prev n)
  (setq n (length w) prev nil)
  (while l
    (if (and (not (vn:wordp prev)) (vn:prefixp w l) (not (vn:wordp (nth n l))))
      (setq out (append (reverse r) out) prev (last w) l (vn:drop l n))
      (setq out (cons (car l) out) prev (car l) l (cdr l))))
  (reverse out))

(defun vn:dictrun (l / w r)
  (foreach e *vn:dict*
    (setq w (car e) r (cadr e))
    (if (vn:prefixsome w l) (setq l (vn:replw l w r)))
    (setq w (cons (vn:upc (car w)) (cdr w)) r (cons (vn:upc (car r)) (cdr r)))
    (if (vn:prefixsome w l) (setq l (vn:replw l w r))))
  l)

;;; kiem tra nhanh co chua chuoi w khong
(defun vn:prefixsome (w l / f)
  (while (and l (not f))
    (if (and (= (car l) (car w)) (vn:prefixp w l)) (setq f T))
    (setq l (cdr l)))
  f)

(defun vn:tdec (u / e) (if (setq e (assoc u *vn:tdec*)) (cdr e) (list u 0)))

(defun vn:toneword (w / n l1 l2 p d1 d2 b1 b2 t1 t2 x)
  (setq n (length w))
  (if (>= n 2)
    (progn
      (setq l1 (nth (- n 2) w) l2 (nth (- n 1) w) p (if (> n 2) (nth (- n 3) w))
            d1 (vn:tdec l1) d2 (vn:tdec l2)
            b1 (vn:lowa (car d1)) b2 (vn:lowa (car d2))
            t1 (cadr d1) t2 (cadr d2))
      (if (and (or (and (= b1 111) (member b2 '(97 101)))
                   (and (= b1 117) (= b2 121) (not (member p '(113 81)))))
               (or (and (> t1 0) (= t2 0)) (and (= t1 0) (> t2 0))))
        (cond
          ((and (= *vn:tonest* "Cu") (> t2 0) (setq x (vn:tcomp (car d1) t2)))
           (setq w (append (vn:take w (- n 2)) (list x (car d2)))))
          ((and (= *vn:tonest* "Moi") (> t1 0) (setq x (vn:tcomp (car d2) t1)))
           (setq w (append (vn:take w (- n 2)) (list (car d1) x))))))))
  w)

(defun vn:tonerun (l / out w)
  (foreach u (append l '(-1))
    (if (and (/= u -1) (vn:wordp u))
      (setq w (cons u w))
      (progn
        (if w (setq out (append (reverse (vn:toneword (reverse w))) out) w nil))
        (if (/= u -1) (setq out (cons u out))))))
  (reverse out))

;;; ---------------- kiem tra am tiet + tu sua sau khi chuyen ma -----------
(setq *vn:vow* '(97 259 226 101 234 105 111 244 417 117 432 121))

(defun vn:lowc (u)
  (cond ((and (>= u 65) (<= u 90)) (+ u 32)) ((cdr (assoc u *vn:lowmap*))) (T u)))
(defun vn:isupl (u) (or (and (>= u 65) (<= u 90)) (assoc u *vn:lowmap*)))

(defun vn:setnth (l n v / i)
  (setq i -1)
  (mapcar '(lambda (x) (setq i (1+ i)) (if (= i n) v x)) l))

;;; (base-thuong-khong-dau  dau  vi-tri-dau) ; dau = -1 neu co 2 dau tro len
(defun vn:winfo (w / base tone pos nt i d)
  (setq i 0 tone 0 pos -1 nt 0)
  (foreach u w
    (setq d (vn:tdec u) base (cons (vn:lowc (car d)) base))
    (if (> (cadr d) 0) (setq tone (cadr d) pos i nt (1+ nt)))
    (setq i (1+ i)))
  (list (reverse base) (if (> nt 1) -1 tone) pos))

(defun vn:onset (b / r found n)
  (foreach o *vn:onsets*
    (if (and (not found) (vn:prefixp o b))
      (progn
        (setq n (length o))
        (cond
          ((member o '((103 105) (113 117)))
           (cond ((and (> (length b) n) (member (nth n b) *vn:vow*)) (setq r n found T))
                 ((equal o '(103 105)) (setq r 1 found T))))
          (T (setq r n found T))))))
  (if found r 0))

(defun vn:stopp (rh / n)
  (setq n (length rh))
  (or (member (last rh) '(112 116 99))
      (and (>= n 2) (equal (vn:drop rh (- n 2)) '(99 104)))))

;;; tu co hop le theo luat ghep van tieng Viet khong (tu chi co chu ASCII / co so: bo qua)
(defun vn:validw (w / inf b k rh)
  (if (or (not (vl-some '(lambda (u) (>= u 128)) w)) (vl-some 'vn:digp w))
    T
    (progn
      (setq inf (vn:winfo w) b (car inf))
      (if (< (cadr inf) 0)
        nil
        (progn
          (setq k (vn:onset b) rh (vn:drop b k))
          (and (member rh *vn:rhymes*)
               (or (not (vn:stopp rh)) (member (cadr inf) '(2 5)))))))))

;;; vi tri dat dau dung trong tu
(defun vn:tpos (b k cur / nuc i s coda x r)
  (setq i k)
  (while (and (< i (length b)) (member (nth i b) *vn:vow*))
    (setq nuc (cons i nuc) i (1+ i)))
  (setq nuc (reverse nuc) coda (< i (length b))
        s (mapcar '(lambda (j) (nth j b)) nuc))
  (cond
    ((null nuc) nil)
    ((= (length nuc) 1) (car nuc))
    ((and (member 432 s) (member 417 s)) (nth (vl-position 417 s) nuc))
    ((progn (setq r nil)
            (foreach x (mapcar 'cons s nuc) (if (member (car x) '(259 226 234 244 417)) (setq r (cdr x))))
            r))
    ((member 432 s) (nth (vl-position 432 s) nuc))
    (coda (last nuc))
    ((= (length nuc) 3) (cadr nuc))
    ((member s '((111 97) (111 101) (117 121)))
     (cond ((= *vn:tonest* "Cu") (car nuc))
           ((= *vn:tonest* "Moi") (cadr nuc))
           ((member cur nuc) cur)
           (T (car nuc))))
    (T (car nuc))))

(defun vn:fixtone (w / inf b tone pos k tp x)
  (setq inf (vn:winfo w) b (car inf) tone (cadr inf) pos (caddr inf))
  (if (> tone 0)
    (progn
      (setq k (vn:onset b))
      (if (and (member (vn:drop b k) *vn:rhymes*)
               (setq tp (vn:tpos b k pos)) (/= tp pos)
               (setq x (vn:tcomp (nth tp w) tone)))
        (setq w (vn:setnth (vn:setnth w pos (car (vn:tdec (nth pos w)))) tp x)))))
  w)

;;; sua thieu moc: mu+o`i -> mu+o+`i, d-uo+`ng -> d-u+o+`ng
(defun vn:hornfix (w / b w2 i a c j d bb tn nb)
  (if (vn:validw w)
    w
    (progn
      (setq b (car (vn:winfo w)) w2 w i 0)
      (while (< i (1- (length b)))
        (setq a (nth i b) c (nth (1+ i) b))
        (if (or (and (= a 432) (= c 111)) (and (= a 117) (= c 417)))
          (progn
            (setq j (if (= a 432) (1+ i) i)
                  d (vn:tdec (nth j w2)) bb (car d) tn (cadr d)
                  nb (if (= (vn:lowc bb) 111) (if (vn:isupl bb) 416 417) (if (vn:isupl bb) 431 432)))
            (setq w2 (vn:setnth w2 j (if (> tn 0) (cond ((vn:tcomp nb tn)) (T nb)) nb)))))
        (setq i (1+ i)))
      (if (or (vn:validw w2) (vn:validw (vn:fixtone w2))) w2 w))))

;;; CAU co chu a^` thuong -> viet hoa ca tu (TCVN3 khong go duoc chu hoa co dau)
(defun vn:upword (w / up lo vl)
  (setq up 0 lo 0 vl 0)
  (foreach u w
    (cond ((vn:isupl u) (setq up (1+ up)))
          ((and (>= u 97) (<= u 122)) (setq lo (1+ lo)))
          ((assoc u *vn:upmap*) (setq vl (1+ vl)))))
  (if (and (= lo 0) (>= vl 1) (>= up 2)) (mapcar 'vn:upc w) w))

(defun vn:fixword (w) (vn:upword (vn:fixtone (vn:hornfix w))))

;;; ap ham fn cho tung tu trong danh sach ma ky tu
(defun vn:wordmap (l fn / out w)
  (foreach u (append l '(-1))
    (if (and (/= u -1) (vn:wordp u))
      (setq w (cons u w))
      (progn
        (if w (setq out (append (reverse (apply fn (list (reverse w)))) out) w nil))
        (if (/= u -1) (setq out (cons u out))))))
  (reverse out))

(defun vn:checkw (w)
  (if (not (vn:validw w))
    (progn
      (setq *vn:sushit* T)
      (if (and (< (length *vn:susw*) 200) (not (member w *vn:susw*)))
        (setq *vn:susw* (cons w *vn:susw*)))))
  w)

(defun vn:checkrun (l) (vn:wordmap l 'vn:checkw))

(defun vn:spellrun (l)
  (setq l (vn:nfc l))
  (if *vn:dict* (setq l (vn:dictrun l)))
  (if (member *vn:tonest* '("Cu" "Moi")) (setq l (vn:tonerun l)))
  l)

;;; ============================================================ XU LY CHUOI
;;; runs: ((kind cps) ...)  kind: "N" "H" (TCVN3) "V" (VNI) nil (khac)
(defun vn:step1 (r / k c d)
  (setq k (car r) c (cadr r))
  (cond
    ((member k '("N" "H" "V"))
     (if (and (> (vn:beyond c) 0) (= (vn:garb c) 0))
       (list nil c)                      ; da la Unicode
       (progn
         (setq d (if (= k "V") (vn:dvni c) (vn:dtcvn c k)))
         (if (not (equal d c)) (if (= k "V") (setq *vn:fV* T) (setq *vn:fT* T)))
         (list "X" d))))
    (T r)))

(defun vn:proc (runs / cat g0 tt vv gt gv dec)
  (if *vn:dry*
    (progn (foreach r runs (vn:checkrun (cadr r))) runs)
    (vn:proc2 runs)))

(defun vn:proc2 (runs / cat g0 tt vv gt gv dec)
  (setq runs (mapcar 'vn:step1 runs))
  (if *vn:detect*
    (progn
      (setq cat nil)
      (foreach r runs (if (null (car r)) (setq cat (append cat (cadr r)))))
      (if cat
        (progn
          (setq g0 (vn:garb cat))
          (cond
            ((> g0 0)
             (setq tt (vn:dtcvn cat "N") vv (vn:dvni cat)
                   gt (vn:garb tt) gv (vn:garb vv))
             (if (or (< gv gt) (and (= gv gt) (< (length vv) (length tt))))
               (if (< gv g0) (setq dec "V"))
               (if (< gt g0) (setq dec "N"))))
            ((and (= (vn:beyond cat) 0) (> (vn:vniev cat) 0))
             (setq vv (vn:dvni cat))
             (if (and (= (vn:garb vv) 0) (< (length vv) (length cat))) (setq dec "V"))))
          (if dec
            (progn
              (if (= dec "V") (setq *vn:fV* T) (setq *vn:fT* T))
              (setq runs
                (mapcar '(lambda (r)
                           (if (null (car r))
                             (list "X" (if (= dec "V") (vn:dvni (cadr r)) (vn:dtcvn (cadr r) "N")))
                             r))
                        runs))))))))
  (if *vn:spell*
    (setq runs (mapcar '(lambda (r / d)
                          (setq d (vn:nfc (cadr r)))
                          ;; chu vua chuyen ma: tu sua chu hoa, dau thanh, thieu moc
                          (if (= (car r) "X") (setq d (vn:wordmap d 'vn:fixword)))
                          (setq d (vn:spellrun d))
                          (if (not (equal d (cadr r))) (setq *vn:fS* T))
                          (list (car r) d))
                       runs)))
  ;; kiem tra am tiet: chu vua chuyen ma (hoac moi chu khi kiem tra)
  (foreach r runs
    (if (or *vn:checkall* (= (car r) "X")) (vn:checkrun (cadr r))))
  runs)

;;; MTEXT -> token: (0 codes) = ma dinh dang, (1 kind cps) = chu
(defun vn:mtflush ()
  (if run (setq out (cons (list 1 k (reverse run)) out) run nil)))

(defun vn:mtok (s k / l out run stk c nx tok nm p rest kk)
  (setq l (vl-string->list s))
  (while l
    (setq c (car l))
    (cond
      ((= c 92)
       (setq nx (cadr l))
       (cond
         ((member nx '(102 70))                       ; \f \F
          (vn:mtflush)
          (setq tok nil)
          (while (and l (/= (car l) 59)) (setq tok (cons (car l) tok) l (cdr l)))
          (if l (setq tok (cons 59 tok) l (cdr l)))
          (setq tok (reverse tok) nm nil p (cddr tok))
          (while (and p (not (member (car p) '(124 59)))) (setq nm (cons (car p) nm) p (cdr p)))
          (setq nm (vl-list->string (reverse nm)) rest p kk (vn:fontkind nm))
          (if (and kk (= nx 102))
            (setq tok (append (vl-string->list (strcat "\\f" (vn:target nm kk))) rest)
                  *vn:fchg* T))
          (setq out (cons (list 0 tok) out)
                k   (cond (*vn:force*) ((= nx 70) nil) (T kk))))
         ((member nx '(65 67 99 72 81 84 87 112 83))  ; ma co tham so ;
          (vn:mtflush)
          (setq tok nil)
          (while (and l (/= (car l) 59)) (setq tok (cons (car l) tok) l (cdr l)))
          (if l (setq tok (cons 59 tok) l (cdr l)))
          (setq out (cons (list 0 (reverse tok)) out)))
         ((setq p (vn:esc l))                         ; \U+XXXX
          (setq run (cons p run) l (vn:drop l 7)))
         ((and (= nx 77) (= (caddr l) 43))           ; \M+nXXXX
          (vn:mtflush)
          (setq out (cons (list 0 (vn:take l 8)) out) l (vn:drop l 8)))
         (T
          (vn:mtflush)
          (setq out (cons (list 0 (vn:take l 2)) out) l (vn:drop l 2)))))
      ((= c 123)
       (vn:mtflush)
       (setq stk (cons k stk) out (cons (list 0 (list c)) out) l (cdr l)))
      ((= c 125)
       (vn:mtflush)
       (if stk (setq k (car stk) stk (cdr stk)))
       (setq out (cons (list 0 (list c)) out) l (cdr l)))
      (T (setq run (cons (vn:c2u c) run) l (cdr l)))))
  (vn:mtflush)
  (reverse out))

;;; tra ve chuoi moi, hoac nil neu khong doi
(defun vn:convstr (s k mt / toks runs new out chg r)
  (if (and s (= (type s) 'STR) (/= s ""))
    (progn
      (setq *vn:fchg* nil)
      (if mt
        (setq toks (vn:mtok s k))
        (setq toks (list (list 1 k (vn:s2cp s)))))
      (setq runs nil)
      (foreach x toks (if (= (car x) 1) (setq runs (cons (cdr x) runs))))
      (setq new (vn:proc (reverse runs))
            chg *vn:fchg* out "")
      (foreach x toks
        (if (= (car x) 0)
          (setq out (strcat out (vl-list->string (cadr x))))
          (progn
            (setq r (car new) new (cdr new))
            (if (not (equal (cadr r) (caddr x))) (setq chg T))
            (foreach u (cadr r) (if (and (>= u 128) (vn:letp u)) (setq *vn:hasvn* T)))
            (setq out (strcat out (vn:cp2s (cadr r)))))))
      (if chg out))))

;;; ============================================================ FONT =======
;;; "N" TCVN3 thuong, "H" TCVN3 hoa, "V" VNI, nil khac
(defun vn:fontkind (name / b u p)
  (if (and name (= (type name) 'STR) (/= name ""))
    (progn
      (setq b name)
      (while (setq p (vl-string-search "\\" b)) (setq b (substr b (+ p 2))))
      (while (setq p (vl-string-search "/" b)) (setq b (substr b (+ p 2))))
      (setq u (strcase b))
      (if (wcmatch u "*`.SHX")
        nil
        (progn
          (if (wcmatch u "*`.TTF,*`.TTC,*`.OTF")
            (setq b (substr b 1 (- (strlen b) 4)) u (strcase b)))
          (while (= (substr u 1 1) ".") (setq b (substr b 2) u (substr u 2)))
          (setq u (vl-string-trim " " u))
          (cond ((= u "") nil)
                ((wcmatch u "VNI-*,VNI_*,VNI *") "V")
                ((wcmatch u "VN*") (if (= (substr u (strlen u) 1) "H") "H" "N"))))))))

(defun vn:target (fname kk)
  (cond ((not (member kk '("N" "H" "V"))) "Arial")
        ((= *vn:font* "Arial") "Arial")
        ((= *vn:font* "Times") "Times New Roman")
        ((and fname (wcmatch (strcase fname)
                       "*ARIAL*,*AVANT*,*HELVET*,*UNIVERS*,*SWISS*,*VERDANA*,*TAHOMA*"))
         "Arial")
        (T "Times New Roman")))

(defun vn:fname (f / p)
  (while (setq p (vl-string-search "\\" f)) (setq f (substr f (+ p 2))))
  f)

(defun vn:fontfound (ff / f w)
  (if (or (null ff) (/= (type ff) 'STR) (= ff ""))
    T
    (progn
      (setq f ff)
      (if (not (wcmatch (strcase (vn:fname f)) "*`.???")) (setq f (strcat f ".shx")))
      (or (findfile f)
          (findfile (vn:fname f))
          (and (setq w (getenv "WINDIR"))
               (findfile (strcat w "\\Fonts\\" (vn:fname f))))
          (and (setq w (getenv "LOCALAPPDATA"))
               (findfile (strcat w "\\Microsoft\\Windows\\Fonts\\" (vn:fname f))))))))

;;; *vn:styles*: ((TEN kind font bold italic obj thieu shx) ...)
(defun vn:scanstyles (/ lst tf bo it cs pf ff kind shx miss bf)
  (vlax-for st (vla-get-TextStyles *vn:doc*)
    (setq tf nil bo :vlax-false it :vlax-false)
    (vl-catch-all-apply 'vla-GetFont (list st 'tf 'bo 'it 'cs 'pf))
    (setq ff (vl-catch-all-apply 'vla-get-fontFile (list st)))
    (if (or (vl-catch-all-error-p ff) (/= (type ff) 'STR)) (setq ff ""))
    (setq bf (vl-catch-all-apply 'vla-get-BigFontFile (list st)))
    (if (or (vl-catch-all-error-p bf) (/= (type bf) 'STR)) (setq bf ""))
    (if (/= (type tf) 'STR) (setq tf ""))
    (setq kind (cond ((vn:fontkind tf)) ((vn:fontkind ff)))
          shx  (and (= tf "") (/= ff "")
                    (not (wcmatch (strcase ff) "*`.TTF,*`.TTC,*`.OTF")))
          miss (and (null kind)
                    (or (not (vn:fontfound ff))
                        (and shx (/= bf "") (not (vn:fontfound bf))))))
    (setq lst (cons (list (strcase (vla-get-Name st)) kind
                          (if (/= tf "") tf ff) bo it st miss shx)
                    lst)))
  lst)

(defun vn:sk (sn / e)
  (cond (*vn:force*)
        ((and sn (= (type sn) 'STR) (setq e (assoc (strcase sn) *vn:styles*))) (cadr e))))

(defun vn:stylefont (e)
  (if *vn:allar* "Arial" (vn:target (nth 2 e) (cadr e))))

(defun vn:applyfont (st tg bo it)
  (vl-catch-all-apply 'vla-put-BigFontFile (list st ""))
  (vl-catch-all-apply 'vla-put-fontFile
    (list st (if (= tg "Arial") "arial.ttf" "times.ttf")))
  (vl-catch-all-apply 'vla-SetFont
    (list st tg (if (= bo :vlax-true) :vlax-true :vlax-false)
                (if (= it :vlax-true) :vlax-true :vlax-false)
                0 (if (= tg "Arial") 34 18))))

(defun vn:newstyle (e / st nn ns sts)
  (setq st  (nth 5 e)
        nn  (strcat (vla-get-Name st) "_UNI")
        sts (vla-get-TextStyles *vn:doc*))
  (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-Item (list sts nn)))
    (progn
      (setq ns (vla-Add sts nn))
      (vl-catch-all-apply 'vla-put-Height (list ns (vla-get-Height st)))
      (vl-catch-all-apply 'vla-put-Width (list ns (vla-get-Width st)))
      (vl-catch-all-apply 'vla-put-ObliqueAngle (list ns (vla-get-ObliqueAngle st)))
      (vl-catch-all-apply 'vla-put-TextGenerationFlag
        (list ns (vla-get-TextGenerationFlag st)))
      (vn:applyfont ns (vn:stylefont e) (nth 3 e) (nth 4 e))))
  nn)

;;; kieu chu cua doi tuong co can doi font khong
(defun vn:stylefix (sn / e)
  (if (and sn (= (type sn) 'STR)
           (setq e (assoc (strcase sn) *vn:styles*))
           (or (member (cadr e) '("N" "H" "V")) (nth 6 e)
               (and (nth 7 e) *vn:hasvn*) *vn:allar*))
    (if (= *vn:scope* "Toanbo")
      (progn
        (if (not (member (car e) *vn:chg*)) (setq *vn:chg* (cons (car e) *vn:chg*)))
        nil)
      (vn:newstyle e))))

(defun vn:post (o prop sn / nn)
  (if (and (not *vn:dry*) (setq nn (vn:stylefix sn)))
    (vl-catch-all-apply 'vlax-put-property (list o prop nn))))

(defun vn:finishstyles (/ e)
  (foreach e *vn:styles*
    (if (or (member (cadr e) '("N" "H" "V")) (nth 6 e) *vn:allar*)
      (if (not (member (car e) *vn:chg*)) (setq *vn:chg* (cons (car e) *vn:chg*)))))
  (foreach nm *vn:chg*
    (setq e (assoc nm *vn:styles*))
    (vn:applyfont (nth 5 e) (vn:stylefont e) (nth 3 e) (nth 4 e))
    (setq *vn:nst* (1+ *vn:nst*))
    (princ (strcat "\n  Kieu chu " (vla-get-Name (nth 5 e)) ": "
                   (if (/= (nth 2 e) "") (nth 2 e) "?")
                   (if (nth 6 e) " (thieu font)" "")
                   " -> " (vn:stylefont e)))))

;;; ============================================================ DOI TUONG ==
(defun vn:get (o prop / r)
  (setq r (vl-catch-all-apply 'vlax-get-property (list o prop)))
  (if (or (vl-catch-all-error-p r) (/= (type r) 'STR)) nil r))

(defun vn:set (o prop old new / r)
  (if (and new (/= old new) (not *vn:dry*))
    (progn
      (setq r (vl-catch-all-apply 'vlax-put-property (list o prop new)))
      (if (vl-catch-all-error-p r)
        (setq *vn:err* (1+ *vn:err*))
        (setq *vn:mod* T)))))

(defun vn:do (o prop k mt / old)
  (if (setq old (vn:get o prop))
    (vn:set o prop old (vn:convstr old k mt))))

(defun vn:ismt (o)
  (and (vlax-property-available-p o 'MTextAttribute)
       (= (vla-get-MTextAttribute o) :vlax-true)))

(defun vn:obj (o / on sn k r c nr nc cs old new hit)
  (setq *vn:fT* nil *vn:fV* nil *vn:fS* nil *vn:hasvn* nil *vn:mod* nil *vn:sushit* nil
        on (vla-get-ObjectName o))
  (cond
    ((= on "AcDbText")
     (setq sn (vn:get o 'StyleName) k (vn:sk sn))
     (vn:do o 'TextString k nil)
     (vn:post o 'StyleName sn))
    ((= on "AcDbMText")
     (setq sn (vn:get o 'StyleName) k (vn:sk sn))
     (vn:do o 'TextString k T)
     (vn:post o 'StyleName sn))
    ((member on '("AcDbAttributeDefinition" "AcDbAttribute"))
     (setq sn (vn:get o 'StyleName) k (vn:sk sn))
     (vn:do o 'TextString k (vn:ismt o))
     (if (= on "AcDbAttributeDefinition") (vn:do o 'PromptString k nil))
     (vn:post o 'StyleName sn))
    ((= on "AcDbBlockReference")
     (if (= (vla-get-HasAttributes o) :vlax-true)
       (progn
         (foreach a (vlax-invoke o 'GetAttributes)
           (vn:obj a)
           (if *vn:sushit* (setq hit T)))
         (setq *vn:sushit* hit))))
    ((and (wcmatch on "AcDb*Dimension") (vlax-property-available-p o 'TextOverride))
     (setq sn (vn:get o 'TextStyle) k (vn:sk sn))
     (vn:do o 'TextOverride k T)
     ;; tien to / hau to cua kich thuoc chinh va kich thuoc phu
     (foreach pr '(TextPrefix TextSuffix AltTextPrefix AltTextSuffix)
       (if (vlax-property-available-p o pr) (vn:do o pr k nil)))
     (vn:post o 'TextStyle sn))
    ((= on "AcDbMLeader")
     (if (= (vla-get-ContentType o) 2)
       (progn
         (setq sn (vn:get o 'TextStyleName) k (vn:sk sn))
         (vn:do o 'TextString k T)
         (vn:post o 'TextStyleName sn))))
    ((= on "AcDbTable")
     (setq nr (vla-get-Rows o) nc (vla-get-Columns o) r 0)
     (vl-catch-all-apply 'vla-put-RegenerateTableSuppressed (list o :vlax-true))
     (while (< r nr)
       (setq c 0)
       (while (< c nc)
         (setq *vn:hasvn* nil
               cs  (vl-catch-all-apply 'vla-GetCellTextStyle (list o r c))
               cs  (if (vl-catch-all-error-p cs) nil cs)
               k   (vn:sk cs)
               old (vl-catch-all-apply 'vla-GetText (list o r c)))
         (if (and (= (type old) 'STR) (setq new (vn:convstr old k T)) (not *vn:dry*))
           (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-SetText (list o r c new)))
             (setq *vn:err* (1+ *vn:err*))
             (setq *vn:mod* T)))
         (if (and cs (not *vn:dry*) (setq new (vn:stylefix cs)))
           (vl-catch-all-apply 'vla-SetCellTextStyle (list o r c new)))
         (setq c (1+ c)))
       (setq r (1+ r)))
     (vl-catch-all-apply 'vla-put-RegenerateTableSuppressed (list o :vlax-false))))
  (if (and *vn:sushit* (/= on "AcDbAttribute"))
    (setq *vn:nsus* (1+ *vn:nsus*) *vn:susobj* (cons o *vn:susobj*)))
  (if (and *vn:mod* (/= on "AcDbBlockReference"))
    (progn
      (setq *vn:nobj* (1+ *vn:nobj*))
      (if *vn:fT* (setq *vn:nT* (1+ *vn:nT*)))
      (if *vn:fV* (setq *vn:nV* (1+ *vn:nV*)))
      (if *vn:fS* (setq *vn:nS* (1+ *vn:nS*))))))

(defun vn:runall (/ nm)
  (vlax-for blk (vla-get-Blocks *vn:doc*)
    (setq nm (vla-get-Name blk))
    (if (and (= (vla-get-IsXRef blk) :vlax-false) (not (wcmatch nm "*|*")))
      (vlax-for o blk (vn:obj o)))))

;;; ============================================================ TU DIEN ====
(defun vn:utf8 (bytes / out b u k)
  (while bytes
    (setq b (car bytes) bytes (cdr bytes))
    (cond ((< b 128) (setq u b k 0))
          ((>= b 240) (setq u (logand b 7) k 3))
          ((>= b 224) (setq u (logand b 15) k 2))
          ((>= b 192) (setq u (logand b 31) k 1))
          (T (setq u b k 0)))
    (repeat k
      (if bytes (setq u (+ (* u 64) (logand (car bytes) 63)) bytes (cdr bytes))))
    (setq out (cons u out)))
  (reverse out))

(defun vn:trimcp (l)
  (while (and l (member (car l) '(32 9 65279))) (setq l (cdr l)))
  (setq l (reverse l))
  (while (and l (member (car l) '(32 9 13))) (setq l (cdr l)))
  (reverse l))

(defun vn:dictline (l / a p)
  (setq l (vn:trimcp l))
  (if (and l (not (member (car l) '(59 35))) (setq p (vl-position 124 l)))
    (progn
      (setq a (vn:trimcp (vn:take l p)) l (vn:trimcp (vn:drop l (1+ p))))
      (if (and a l) (setq *vn:dict* (append *vn:dict* (list (list (vn:nfc a) (vn:nfc l)))))))))

(defun vn:loaddict (/ f fh ln bytes c cur)
  (setq *vn:dict* *vn:dict0*)
  (if (setq f (findfile "VXT_CHINHTA.txt"))
    (if *vn:uni*
      (progn
        (setq fh (vl-catch-all-apply 'open (list f "r" "utf8")))
        (if (and fh (not (vl-catch-all-error-p fh)))
          (progn
            (while (setq ln (read-line fh)) (vn:dictline (vl-string->list ln)))
            (close fh))))
      (if (setq fh (open f "r"))
        (progn
          (while (setq c (read-char fh)) (setq bytes (cons c bytes)))
          (close fh)
          (setq cur nil)
          (foreach u (append (vn:utf8 (reverse bytes)) '(10))
            (if (= u 10)
              (progn (vn:dictline (reverse cur)) (setq cur nil))
              (setq cur (cons u cur)))))))))

;;; ============================================================ KHUNG LENH
(defun vn:init (doc)
  (vn:getset)
  (setq *vn:doc*   doc
        *vn:uni*   (= 1 (getvar "LISPSYS"))
        *vn:cpmap* (if (= (strcase (getvar "SYSCODEPAGE")) "ANSI_1258") *vn:cp1258* *vn:cp1252*)
        *vn:nobj* 0 *vn:nT* 0 *vn:nV* 0 *vn:nS* 0 *vn:nst* 0 *vn:err* 0
        *vn:chg* nil *vn:nsus* 0 *vn:susobj* nil *vn:susw* nil *vn:sushit* nil
        *vn:dry* nil *vn:checkall* nil)
  (vn:loaddict))

(defun vn:unlock (/ lst)
  (vlax-for l (vla-get-Layers *vn:doc*)
    (if (= (vla-get-Lock l) :vlax-true)
      (progn (setq lst (cons l lst)) (vl-catch-all-apply 'vla-put-Lock (list l :vlax-false)))))
  lst)

(defun vn:relock (lst)
  (foreach l lst (vl-catch-all-apply 'vla-put-Lock (list l :vlax-true))))

(defun vn:begin ()
  (vla-StartUndoMark *vn:doc*)
  (setq *vn:lock* (vn:unlock)
        *vn:olderr* *error*
        *error* (function (lambda (m)
                  (vn:end)
                  (if (not (wcmatch (strcase m) "*CANCEL*,*QUIT*,*EXIT*,*BREAK*"))
                    (princ (strcat "\nLoi: " m)))
                  (princ)))))

(defun vn:end ()
  (vn:relock *vn:lock*)
  (setq *vn:lock* nil *error* *vn:olderr* *vn:olderr* nil *vn:force* nil)
  (vl-catch-all-apply 'vla-EndUndoMark (list *vn:doc*)))

(defun vn:summary ()
  (strcat "Doi tuong da sua: " (itoa *vn:nobj*)
          " (TCVN3: " (itoa *vn:nT*) ", VNI: " (itoa *vn:nV*)
          ", chinh ta: " (itoa *vn:nS*) "), kieu chu doi font: " (itoa *vn:nst*)
          (if (> *vn:err* 0) (strcat ", loi khong sua duoc: " (itoa *vn:err*)) "")
          (if (> *vn:nsus* 0) (strcat ", nghi con sai: " (itoa *vn:nsus*)) "")))

(defun vn:susreport (/ ss e ow n)
  (if (> *vn:nsus* 0)
    (progn
      (princ (strcat "\nChu nghi con sai chinh ta: " (itoa *vn:nsus*) " doi tuong. Cac tu: "))
      (setq n 0)
      (foreach w (reverse *vn:susw*)
        (if (< n 40) (princ (strcat (vn:cp2s w) "  ")))
        (setq n (1+ n)))
      (if (> n 40) (princ "..."))
      (setq ss (ssadd))
      (foreach o *vn:susobj*
        (setq ow (vl-catch-all-apply 'vla-ObjectIDToObject (list *vn:doc* (vla-get-OwnerID o))))
        (if (and (not (vl-catch-all-error-p ow))
                 (vlax-property-available-p ow 'IsLayout)
                 (= (vla-get-IsLayout ow) :vlax-true)
                 (setq e (vlax-vla-object->ename o)))
          (ssadd e ss)))
      (if (> (sslength ss) 0)
        (progn
          (sssetfirst nil ss)
          (princ (strcat "\nDa chon san " (itoa (sslength ss))
                         " doi tuong nghi sai (dang hien grip) de anh kiem tra. Nhan Esc de bo chon.")))))
    (princ "\nKhong thay chu nao sai luat ghep van tieng Viet."))
  (princ))

(defun vn:ssget ()
  (ssget '((0 . "TEXT,MTEXT,INSERT,ATTDEF,DIMENSION,MULTILEADER,ACAD_TABLE"))))

;;; chu trong Dimension Style (DIMPOST, DIMAPOST) - chi ban ve dang mo
(defun vn:dimstyles (/ d e en st sn k old new grp)
  (setq d (tblnext "DIMSTYLE" T))
  (while d
    (setq en (tblobjname "DIMSTYLE" (cdr (assoc 2 d))))
    (if (and en (setq e (entget en)))
      (progn
        (setq st (cdr (assoc 340 e))
              sn (if (and st (entget st)) (cdr (assoc 2 (entget st))) "Standard")
              k  (vn:sk sn)
              *vn:hasvn* nil *vn:fT* nil *vn:fV* nil *vn:fS* nil)
        (foreach grp '(3 4)
          (if (and (setq old (cdr (assoc grp e)))
                   (setq new (vn:convstr old k nil)))
            (setq e (subst (cons grp new) (assoc grp e) e))))
        (if (and (not *vn:dry*) (not (equal e (entget en))))
          (if (vl-catch-all-error-p (vl-catch-all-apply 'entmod (list e)))
            (setq *vn:err* (1+ *vn:err*))
            (setq *vn:nobj* (1+ *vn:nobj*))))))
    (setq d (tblnext "DIMSTYLE")))
  (princ))

;;; chay chuyen doi tren ban ve dang mo. kw = "Toanbo" | "Chon"
(defun vn:runactive (kw / ss i)
  (setq *vn:force* nil *vn:scope* kw)
  (if (= kw "Chon") (progn (princ "\nChon chu can sua: ") (setq ss (vn:ssget))))
  (if (or (= kw "Toanbo") ss)
    (progn
      (vn:init (vla-get-ActiveDocument (vlax-get-acad-object)))
      (vn:begin)
      (setq *vn:styles* (vn:scanstyles))
      (if (= kw "Toanbo")
        (progn (vn:dimstyles) (vn:runall) (vn:finishstyles))
        (progn
          (setq i 0)
          (repeat (sslength ss)
            (vn:obj (vlax-ename->vla-object (ssname ss i)))
            (setq i (1+ i)))))
      (vn:end)
      (vla-Regen *vn:doc* acAllViewports)
      (princ (strcat "\n" (vn:summary) "\nGo U de hoan tac."))
      (vn:susreport)))
  (princ))

;;; chi kiem tra chinh ta, khong sua gi
(defun c:TCVNKIEMTRA (/ kw ss i)
  (initget "Toanbo Chon")
  (setq kw (getkword "\nKiem tra chinh ta [Toanbo ban ve/Chon doi tuong] <Toanbo>: "))
  (if (null kw) (setq kw "Toanbo"))
  (if (= kw "Chon") (setq ss (vn:ssget)))
  (if (or (= kw "Toanbo") ss)
    (progn
      (vn:init (vla-get-ActiveDocument (vlax-get-acad-object)))
      (setq *vn:dry* T *vn:checkall* T *vn:force* nil *vn:scope* kw
            *vn:styles* (vn:scanstyles))
      (if (= kw "Toanbo")
        (vn:runall)
        (progn (setq i 0)
               (repeat (sslength ss) (vn:obj (vlax-ename->vla-object (ssname ss i))) (setq i (1+ i)))))
      (setq *vn:dry* nil *vn:checkall* nil)
      (vn:susreport)))
  (princ))

(defun c:TCVN2UNI (/ kw)
  (vn:getset)
  (setq kw "CAidat")
  (while (= kw "CAidat")
    (vn:showset)
    (initget "Toanbo Chon CAidat")
    (setq kw (getkword "\nPham vi [Toanbo ban ve/Chon doi tuong/CAidat] <Toanbo>: "))
    (if (null kw) (setq kw "Toanbo"))
    (if (= kw "CAidat") (c:TCVNCAIDAT)))
  (vn:runactive kw))

;;; lenh goi nhanh tu Ribbon (khong hoi)
(defun c:TCVN2UNI_TB () (vn:getset) (vn:showset) (vn:runactive "Toanbo"))
(defun c:TCVN2UNI_CHON () (vn:getset) (vn:showset) (vn:runactive "Chon"))

(defun c:TCVNTUDIEN (/ f)
  (if (setq f (findfile "VXT_CHINHTA.txt"))
    (startapp "notepad.exe" (strcat "\"" f "\""))
    (princ "\nKhong tim thay VXT_CHINHTA.txt (them thu muc chua file vao Support File Search Path)."))
  (princ "\nSua xong nho luu file (UTF-8). Lan chay lenh sau se dung tu dien moi.")
  (princ))

(defun c:TCVNHUONGDAN ()
  (princ (strcat
    "\n=== VXT Tieng Viet - cac lenh ==="
    "\n TCVN2UNI_TB     : sua toan bo ban ve dang mo"
    "\n TCVN2UNI_CHON   : sua cac doi tuong chon"
    "\n TCVN2UNI        : hoi pham vi (Toanbo/Chon/CAidat)"
    "\n TCVN2UNI_THUMUC : sua moi file DWG trong 1 thu muc (sao luu vao _BanGoc_VXT)"
    "\n TCVNEP          : ep chuyen theo bang ma TCVN3 / Hoa / VNI"
    "\n TCVNCAIDAT      : cai dat font dich, nhan dien, chinh ta, kieu dau"
    "\n TCVNTUDIEN      : mo tu dien chinh ta VXT_CHINHTA.txt"
    "\n TCVNKIEMTRA     : kiem tra chinh ta, chon san cac chu nghi sai (khong sua)"
    "\n VXTHOA / VXTTHUONG / VXTCHUDAU / VXTDAUCAU : doi CHU HOA / chu thuong / Viet Hoa Chu Dau / Viet hoa dau cau"
    "\n Go U de hoan tac sau khi sua ban ve dang mo."))
  (vl-catch-all-apply 'command (list "_.BROWSER" "https://claude.ai/artifact/BtaeS2Gb5XSAsFUFLBPbce"))
  (princ))

(defun c:TCVNEP (/ k ss i)
  (initget "Tcvn3 Hoa Vni")
  (setq k (getkword "\nChu goc thuoc bang ma [Tcvn3 (.VnTime)/Hoa (.VnTimeH)/Vni (VNI-Times)] <Tcvn3>: "))
  (princ "\nChon chu can ep chuyen (khong chon chu da dung Unicode): ")
  (if (setq ss (vn:ssget))
    (progn
      (vn:init (vla-get-ActiveDocument (vlax-get-acad-object)))
      (setq *vn:scope* "Chon" *vn:detect* nil)
      (vn:begin)
      (setq *vn:force* (cond ((= k "Hoa") "H") ((= k "Vni") "V") (T "N"))
            *vn:styles* (vn:scanstyles) i 0)
      (repeat (sslength ss)
        (vn:obj (vlax-ename->vla-object (ssname ss i)))
        (setq i (1+ i)))
      (vn:end)
      (vla-Regen *vn:doc* acAllViewports)
      (princ (strcat "\n" (vn:summary) "\nGo U de hoan tac."))))
  (princ))

;;; ------------------------------------------------- chay hang loat --------
(defun c:TCVN2UNI_THUMUC (/ f dir files bak prog acad opened dbx full bf r log n ok lk)
  (vn:getset)
  (vn:showset)
  (princ "\n(Go TCVNCAIDAT neu muon doi cai dat truoc khi chay.)")
  (if (setq f (getfiled "Chon 1 file DWG bat ky trong thu muc can chuyen" (getvar "DWGPREFIX") "dwg" 0))
    (progn
      (setq dir   (vl-filename-directory f)
            files (vl-directory-files dir "*.dwg" 1)
            bak   (strcat dir "\\_BanGoc_VXT")
            acad  (vlax-get-acad-object)
            prog  (strcat "ObjectDBX.AxDbDocument." (substr (getvar "ACADVER") 1 2))
            opened nil n 0 ok 0)
      (vlax-for d (vla-get-Documents acad)
        (setq opened (cons (strcase (vla-get-FullName d)) opened)))
      (vl-mkdir bak)
      (setq log (open (strcat dir "\\VXT_TCVN2UNI_log.txt") "w"))
      (write-line (strcat "VXT_TCVN2UNI - thu muc: " dir) log)
      (foreach fn files
        (setq full (strcat dir "\\" fn) bf (strcat bak "\\" fn) n (1+ n))
        (princ (strcat "\n[" (itoa n) "/" (itoa (length files)) "] " fn " ... "))
        (cond
          ((member (strcase full) opened)
           (princ "dang mo trong AutoCAD - bo qua (dung lenh TCVN2UNI).")
           (write-line (strcat fn ": BO QUA - file dang mo") log))
          ((and (not (findfile bf)) (not (vl-file-copy full bf)))
           (princ "khong sao luu duoc - bo qua.")
           (write-line (strcat fn ": BO QUA - khong sao luu duoc") log))
          (T
           (setq dbx (vl-catch-all-apply 'vla-GetInterfaceObject (list acad prog)))
           (if (vl-catch-all-error-p dbx)
             (progn (princ "khong tao duoc ObjectDBX.")
                    (write-line (strcat fn ": LOI ObjectDBX") log))
             (progn
               (setq r (vl-catch-all-apply 'vla-Open (list dbx full)))
               (if (vl-catch-all-error-p r)
                 (progn (princ "khong mo duoc file.")
                        (write-line (strcat fn ": LOI - khong mo duoc") log))
                 (progn
                   (vn:init dbx)
                   (setq *vn:scope* "Toanbo" *vn:force* nil
                         lk (vn:unlock)
                         *vn:styles* (vn:scanstyles))
                   (vn:runall)
                   (vn:finishstyles)
                   (vn:relock lk)
                   (if (or (> *vn:nobj* 0) (> *vn:nst* 0))
                     (progn
                       (setq r (vl-catch-all-apply 'vla-SaveAs (list dbx full)))
                       (if (vl-catch-all-error-p r)
                         (progn (princ "LOI khi luu.")
                                (write-line (strcat fn ": LOI khi luu - " (vl-catch-all-error-message r)) log))
                         (progn (setq ok (1+ ok))
                                (princ (vn:summary))
                                (write-line (strcat fn ": " (vn:summary)) log)
                                (if *vn:susw*
                                  (write-line (strcat "   tu nghi sai: "
                                    (apply 'strcat (mapcar '(lambda (w) (strcat (vn:cp2s w) "  ")) (reverse *vn:susw*))))
                                    log)))))
                     (progn (princ "khong co gi can sua.")
                            (write-line (strcat fn ": khong co gi can sua") log)))))
               (vl-catch-all-apply 'vlax-release-object (list dbx)))))))
      (close log)
      (princ (strcat "\n\nXong. Da sua " (itoa ok) "/" (itoa n) " file."
                     "\nBan goc: " bak
                     "\nNhat ky: " dir "\\VXT_TCVN2UNI_log.txt"))))
  (princ))

;;; ============================================================ DOI CHU HOA/THUONG
;;; mode: "Hoa" CHU IN HOA | "Thuong" chu thuong | "Chudau" Viet Hoa Chu Dau | "Cau" Viet hoa dau cau
;;; doi kieu chu theo tung tu; tu co chu so (C1, D10, M250) giu nguyen tru khi doi sang HOA
(defun vn:caseword (w mode cap)
  (cond
    ((= mode "Hoa") (mapcar 'vn:upc w))
    ((vl-some 'vn:digp w) w)
    ((and cap (member mode '("Chudau" "Cau"))) (cons (vn:upc (car w)) (mapcar 'vn:lowc (cdr w))))
    (T (mapcar 'vn:lowc w))))

(defun vn:caserun (l mode / out w first)
  (setq first T)
  (foreach u (append l '(-1))
    (if (and (/= u -1) (vn:wordp u))
      (setq w (cons u w))
      (progn
        (if w
          (setq out (append (reverse (vn:caseword (reverse w) mode (or (= mode "Chudau") first))) out)
                w nil first nil))
        (if (/= u -1)
          (progn
            (setq out (cons u out))
            (if (member u '(46 33 63)) (setq first T)))))))
  (reverse out))

;;; doi kieu chu mot chuoi; tra ve chuoi moi hoac nil neu khong doi
(defun vn:casestr (s mt mode / toks out chg r new)
  (if (and s (= (type s) 'STR) (/= s ""))
    (progn
      (setq *vn:force* nil *vn:fchg* nil)
      (setq toks (if mt (vn:mtok s nil) (list (list 1 nil (vn:s2cp s)))) out "")
      (foreach x toks
        (if (= (car x) 0)
          (setq out (strcat out (vl-list->string (cadr x))))
          (progn
            (setq new (vn:caserun (vn:nfc (caddr x)) *vn:case*))
            (if (not (equal new (caddr x))) (setq chg T))
            (setq out (strcat out (vn:cp2s new))))))
      (if (or chg *vn:fchg*) out))))

(defun vn:casedo (o prop mt / old new)
  (if (and (setq old (vn:get o prop)) (setq new (vn:casestr old mt *vn:case*)))
    (vn:set o prop old new)))

(defun vn:caseobj (o / on r c nr nc old new)
  (setq on (vla-get-ObjectName o) *vn:mod* nil)
  (cond
    ((= on "AcDbText") (vn:casedo o 'TextString nil))
    ((= on "AcDbMText") (vn:casedo o 'TextString T))
    ((member on '("AcDbAttributeDefinition" "AcDbAttribute"))
     (vn:casedo o 'TextString (vn:ismt o)))
    ((= on "AcDbBlockReference")
     (if (= (vla-get-HasAttributes o) :vlax-true)
       (foreach a (vlax-invoke o 'GetAttributes) (vn:caseobj a))))
    ((and (wcmatch on "AcDb*Dimension") (vlax-property-available-p o 'TextOverride))
     (vn:casedo o 'TextOverride T)
     (foreach pr '(TextPrefix TextSuffix)
       (if (vlax-property-available-p o pr) (vn:casedo o pr nil))))
    ((= on "AcDbMLeader")
     (if (= (vla-get-ContentType o) 2) (vn:casedo o 'TextString T)))
    ((= on "AcDbTable")
     (setq nr (vla-get-Rows o) nc (vla-get-Columns o) r 0)
     (vl-catch-all-apply 'vla-put-RegenerateTableSuppressed (list o :vlax-true))
     (while (< r nr)
       (setq c 0)
       (while (< c nc)
         (setq old (vl-catch-all-apply 'vla-GetText (list o r c)))
         (if (and (= (type old) 'STR) (setq new (vn:casestr old T *vn:case*)))
           (if (not (vl-catch-all-error-p (vl-catch-all-apply 'vla-SetText (list o r c new))))
             (setq *vn:mod* T)))
         (setq c (1+ c)))
       (setq r (1+ r)))
     (vl-catch-all-apply 'vla-put-RegenerateTableSuppressed (list o :vlax-false))))
  (if (and *vn:mod* (/= on "AcDbBlockReference")) (setq *vn:nobj* (1+ *vn:nobj*))))

(defun vn:caserun-cmd (mode / ss i)
  (princ (strcat "\nDoi chu "
                 (cond ((= mode "Hoa") "IN HOA") ((= mode "Thuong") "thuong")
                       ((= mode "Chudau") "Viet Hoa Chu Dau") (T "Viet hoa dau cau"))
                 ". Chon chu can doi: "))
  (if (setq ss (vn:ssget))
    (progn
      (vn:init (vla-get-ActiveDocument (vlax-get-acad-object)))
      (setq *vn:case* mode *vn:scope* "Chon")
      (vn:begin)
      (setq i 0)
      (repeat (sslength ss)
        (vn:caseobj (vlax-ename->vla-object (ssname ss i)))
        (setq i (1+ i)))
      (vn:end)
      (princ (strcat "\nDa doi " (itoa *vn:nobj*) " doi tuong. Go U de hoan tac."))))
  (princ))

(defun c:VXTHOA () (vn:caserun-cmd "Hoa"))
(defun c:VXTTHUONG () (vn:caserun-cmd "Thuong"))
(defun c:VXTCHUDAU () (vn:caserun-cmd "Chudau"))
(defun c:VXTDAUCAU () (vn:caserun-cmd "Cau"))
(defun c:VXTCASE (/ k)
  (initget "Hoa Thuong Chudau Daucau")
  (setq k (getkword "\nDoi thanh [Hoa/Thuong/Chudau (Viet Hoa Chu Dau)/Daucau (Viet hoa dau cau)] <Hoa>: "))
  (vn:caserun-cmd (cond ((= k "Thuong") "Thuong") ((= k "Chudau") "Chudau") ((= k "Daucau") "Cau") (T "Hoa"))))

;;; tu nap tab Ribbon VXT Tieng Viet neu chua co (sau khi cai bang file Setup)
(defun vn:loadmenu (/ mg f)
  (setq mg (vla-get-MenuGroups (vlax-get-acad-object)))
  (if (and (vl-catch-all-error-p (vl-catch-all-apply 'vla-Item (list mg "VXT_TIENGVIET")))
           (setq f (findfile "VXT_TIENGVIET.cuix")))
    (vl-catch-all-apply 'vla-Load (list mg f))))
(vl-catch-all-apply 'vn:loadmenu nil)

(princ "\nVXT_TCVN2UNI v4 da nap. Tab Ribbon \"VXT Tieng Viet\" hoac go TCVNHUONGDAN de xem lenh.")
(princ)
