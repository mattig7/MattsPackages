# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/openproj-bin/openproj-bin-1.4.ebuild,v 1.1 2010/12/01 13:37:38 vapier Exp $



EAPI="5"

JAVA_PKG_IUSE="doc source"
EANT_BUILD_XML="./openproj_build/build.xml"
WANT_ANT_TASKS="ant-contrib"

inherit eutils java-pkg-2 java-ant-2

MY_PN="${PN}"
MY_P="${MY_PN}-${PV}-src"

DESCRIPTION="Free open source desktop alternative to Microsoft Project"
HOMEPAGE="http://www.projectlibre.org/"

SRC_URI="mirror://sourceforge/${PN}/${PV}/${MY_P}.tar.gz"

LICENSE="CPAL-1.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5"

#S=${WORKDIR}/${MY_P}

JAVA_ANT_REWRITE_CLASSPATH="true"
EANT_BUILD_TARGET="dist"





