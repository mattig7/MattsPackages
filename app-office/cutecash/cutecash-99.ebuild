# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$
#edited by Matt, Dec 15
EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python2_7 )

inherit git-r3 cmake-utils eutils gnome2 python-single-r1

DESCRIPTION="A personal finance manager."
HOMEPAGE="http://www.gnucash.org/"
EGIT_REPO_URI="https://github.com/mattig7/gnucash.git"
EGIT_BRANCH="master"

SRC_URI=""

CMAKE_VERBOSE="ON"


SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="chipcard debug +doc gnome-keyring hbci mysql ofx postgres python quotes sqlite"

# FIXME: rdepend on dev-libs/qof when upstream fix their mess (see configure.ac)
# libdbi version requirement for sqlite taken from bug #455134
#dependancy on dev-lang/swig can be removed if the origin of the source is not git.
# FIXME: Insert dependency on cmake to ensure that this works for everyone.
RDEPEND="
	>=dev-libs/glib-2.32.0:2
	>=x11-libs/gtk+-2.24:2
	>=dev-scheme/guile-1.8.3:12[deprecated,regex]
	gnome-base/libgnomecanvas
	>=x11-libs/goffice-0.7.0:0.8[gnome]
	>=dev-libs/libxml2-2.5.10:2
	dev-libs/libxslt
	>=dev-libs/boost-1.50.0
	>=dev-lang/swig-2.0.10
	>=net-libs/webkit-gtk-1.2:2
	dev-scheme/guile-www
	>=dev-libs/popt-1.5
	>=sys-libs/zlib-1.1.4
	x11-libs/pango
	>=dev-util/cmake-2.6.0
	gnome-keyring? ( >=app-crypt/libsecret-0.18 )
	ofx? ( >=dev-libs/libofx-0.9.1 )
	hbci? ( >=net-libs/aqbanking-5[gtk,ofx?]
		sys-libs/gwenhywfar[gtk]
		chipcard? ( sys-libs/libchipcard )
	)
	python? ( ${PYTHON_DEPS} )
	quotes? ( dev-perl/DateManip
		>=dev-perl/Finance-Quote-1.11
		dev-perl/HTML-TableExtract )
	sqlite? ( >=dev-db/libdbi-0.9.0
		>=dev-db/libdbi-drivers-0.9.0[sqlite] )
	postgres? ( dev-db/libdbi dev-db/libdbi-drivers[postgres] )
	mysql? ( dev-db/libdbi dev-db/libdbi-drivers[mysql] )
"
# Removed from DEPEND
#	virtual/pkgconfig
#	dev-util/intltool
#	gnome-base/gnome-common
#	sys-devel/libtool
DEPEND="${RDEPEND}"
PDEPEND="doc? ( >=app-doc/gnucash-docs-2.2.0 )"

pkg_setup() {

	use python && python-single-r1_pkg_setup
}

src_unpack() {
	git-r3_fetch
	git-r3_checkout
}

src_prepare() {
	# Skip test that needs some locales to be present
	sed -i -e '/test_suite_gnc_date/d' src/libqof/qof/test/test-qof.c || die

	cmake-utils_src_prepare

}

src_configure() {

# See CMakeLists.text in the root directly of the sources for the options used
# Gnome keyring and python weren't present in the CMakeLists file so I don't think they will work.
	local mycmakeargs=(
		$(cmake-utils_use mysql WITH_SQL)
		$(cmake-utils_use hbci WITH_AQBANKING)
		-D WITH_GNUCASH=ON
		-D WITH_CUTECASH=ON
		$(cmake-utils_use ofx WITH_OFX)
		-D WITH_BINRELOC=ON
		$(cmake-utils_use debug ENABLE_DEBUG)
		-D ENABLE_REGISTER2=OFF
		$(cmake-utils_use gnome-keyring enable-password-storage)
		$(cmake-utils_use python enable python)
		
	)

	cmake-utils_src_configure
}

src_compile() {

	cmake-utils_src_compile

}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	GUILE_WARN_DEPRECATED=no \
	GNC_DOT_DIR="${T}"/.gnucash \
	cmake-utils_src_test
}

src_install() {
	# Parallel installation fails from time to time, bug #359123
	MAKEOPTS="${MAKEOPTS} -j1" 
	
	cmake-utils_src_install 
	
	GNC_DOC_INSTALL_DIR=/usr/share/doc/${PF}

	rm -rf "${ED}"/usr/share/doc/${PF}/{examples/,COPYING,INSTALL,*win32-bin.txt,projects.html}
	mv "${ED}"/usr/share/doc/${PF} "${T}"/cantuseprepalldocs || die
	dodoc "${T}"/cantuseprepalldocs/*
}
