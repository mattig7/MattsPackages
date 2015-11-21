# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Nixnote - A clone of Evernote for Linux"
HOMEPAGE="http://sourceforge.net/projects/nevernote/"
#SRC_URI="https://github.com/baumgarr/Nixnote2/archive/v2.0-beta4.tar.gz -> Nixnote2-2.0-beta4.tar.gz"

SRC_URI="http://sourceforge.net/projects/nevernote/files/NixNote2%20-%20Beta%204/nixnote2-2.0-beta4_amd64.tar.gz/download"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="app-text/poppler
dev-qt/qtwebkit:4
dev-qt/qtcore:4
dev-qt/qtgui:4
dev-qt/qtsql:4
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/Nixnote2-2.0-beta4"

src_prepare() {
	/usr/lib64/qt4/bin/qmake -o Makefile NixNote2.pro
}

src_install() {
	mkdir -p ${D}/usr/share/nixnote2

	cp -r \
	certs \
  	help \
   	images \
   	java \
 	qss \
  	translations \
	${D}/usr/share/nixnote2

	cp \
	changelog.txt \
	license.html \
	shortcuts.txt \
	${D}/usr/share/nixnote2
	
	mkdir -p ${D}/usr/bin
	cp nixnote2 ${D}/usr/bin/

	mkdir -p ${D}/usr/share/applications
	cp nixnote2.desktop ${D}/usr/share/applications/
}
