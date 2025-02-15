# Copyright 2021 Gordon Bos
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="A user for the Lyrion Music Server"
ACCT_USER_ID=110
ACCT_USER_GROUPS=( lyrionmusicserver )

acct-user_add_deps
