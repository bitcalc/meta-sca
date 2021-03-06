SUMMARY = "NPM: textlint-rule-alex"
DESCRIPTION = "textlint rule for alex"
HOMEPAGE = "https://github.com/textlint-rule/textlint-rule-alex"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=bc9a2bae21f2f74984d4a43e24285986"

DEPENDS = "npm-alex-native \
           npm-textlint-rule-helper-native"

SRC_URI = "https://registry.npmjs.org/textlint-rule-alex/-/textlint-rule-alex-3.0.0.tgz"
SRC_URI[md5sum] = "7e16ec08c32065dd124c6bf1268a96d8"
SRC_URI[sha256sum] = "7874489b3c5f563fbf87fa9743698b27543a3a50504789e285033d3b9b22ae44"

NPM_PKGNAME = "textlint-rule-alex"

inherit npmhelper
inherit native
