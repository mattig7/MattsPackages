# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$
#edited by Matt, Oct 15
EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python2_7 )

inherit git-r3 autotools eutils gnome2 python-single-r1

DESCRIPTION="A personal finance manager."
HOMEPAGE="http://www.gnucash.org/"
EGIT_REPO_URI="https://github.com/Gnucash/gnucash.git"

EGIT_CLONE_TYPE="single"
EGIT_COMMIT="2.6.10"

SRC_URI=""

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE="chipcard debug +doc gnome-keyring hbci mysql ofx postgres python quotes sqlite"

# FIXME: rdepend on dev-libs/qof when upstream fix their mess (see configure.ac)
# libdbi version requirement for sqlite taken from bug #455134
#dependancy on dev-lang/swig can be removed if the origin of the source is not git.
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
	git-r3_fetch
	use python && python-single-r1_pkg_setup
}

src_unpack() {
	git-r3_checkout

}

src_prepare() {
	# Skip test that needs some locales to be present
	sed -i -e '/test_suite_gnc_date/d' src/libqof/qof/test/test-qof.c || die

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	./autogen.sh

	local myconf

	DOCS="doc/README.OFX doc/README.HBCI"

	if use sqlite || use mysql || use postgres ; then
		myconf+=" --enable-dbi"
	else
		myconf+=" --disable-dbi"
	fi

	# guile wrongly exports LDFLAGS as LIBS which breaks modules
	# Filter until a better ebuild is available, bug #202205
	local GUILE_LIBS=""
	local lib
	for lib in $(guile-config link); do
		if [ "${lib#-Wl}" = "$lib" ]; then
			GUILE_LIBS="$GUILE_LIBS $lib"
		fi
	done

	# gtkmm is experimental and shouldn't be enabled, upstream bug #684166
	gnome2_src_configure \
		$(use_enable debug) \
		$(use_enable gnome-keyring password-storage) \
		$(use_enable ofx) \
		$(use_enable hbci aqbanking) \
		$(use_enable python) \
		--disable-doxygen \
		--disable-gtkmm \
		--enable-locale-specific-tax \
		--disable-error-on-warning \
		 GUILE_LIBS="${GUILE_LIBS}" ${myconf}
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	GUILE_WARN_DEPRECATED=no \
	GNC_DOT_DIR="${T}"/.gnucash \
	emake check
}

src_compile() {
	gnome2_src_compile
}

src_install() {
	# Parallel installation fails from time to time, bug #359123
	MAKEOPTS="${MAKEOPTS} -j1" gnome2_src_install GNC_DOC_INSTALL_DIR=/usr/share/doc/${PF}

	rm -rf "${ED}"/usr/share/doc/${PF}/{examples/,COPYING,INSTALL,*win32-bin.txt,projects.html}
	mv "${ED}"/usr/share/doc/${PF} "${T}"/cantuseprepalldocs || die
	dodoc "${T}"/cantuseprepalldocs/*
}
