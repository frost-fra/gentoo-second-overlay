# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header$

/var/log/lyrionmusicserver/scanner.log /var/log/lyrionmusicserver/server.log /var/log/lyrionmusicserver/perfmon.log {
	missingok
	notifempty
	copytruncate
	rotate 5
	size 100k
	su lyrionmusicserver lyrionmusicserver
}
