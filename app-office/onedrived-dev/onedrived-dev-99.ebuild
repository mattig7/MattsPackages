# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Written by Matt G, Jan 18
#
EAPI=6

inherit distutils-r1

DESCRIPTION="A Microsoft OneDrive client for Linux, written in Python3."
HOMEPAGE="https://github.com/xybu/onedrived-dev"

SRC_URI="https://github.com/xybu/onedrived-dev.git

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd"
IUSE=""


#The specific upstream requirement is "python3-dbus", but hopefully this works.
DEPEND="dev-lang/python sys-fs/inotify-tools dev-python/dbus-python"
RDEPEND=${DEPEND}


