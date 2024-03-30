# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# The Project is hosted on github.com, so we will use the git-3 Helper
# and the perl-module Helper to compile the checked out files from
# the git Repository
inherit git-r3 perl-module

DESCRIPTION="Fast C metadata and tag reader for all common audio file formats"
HOMEPAGE="https://github.com/LMS-Community/Audio-Scan"


EGIT_REPO_URI="https://github.com/LMS-Community/Audio-Scan.git"
SRC_URI=""
EGIT_COMMIT="c9c7227441a873d7fafc7a5251c52f108398fa11"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
        virtual/perl-ExtUtils-MakeMaker
"

PERL_RM_FILES=(
        "t/02pod.t"
        "t/03podcoverage.t"
        "t/04critic.t"
)

src_compile() {
        mymake=(
                "OPTIMIZE=${CFLAGS}"
        )
        perl-module_src_compile
}
