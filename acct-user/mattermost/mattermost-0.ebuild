# Copyright 2021 Gordon Bos
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="A user for Logitech Media Server"
ACCT_USER_ID=248
ACCT_USER_GROUPS=( mattermost )

acct-user_add_deps
