# Copyright 2022 gordonb3 <gordon@bosvangennip.nl>
# Distributed under the terms of the GNU General Public License v2
#
# $Header$

EAPI="7"

inherit systemd


MY_PN="${PN/-bin}"
MY_PV="${PVR/_*}"
MY_PF="${MY_PN}-${MY_PV}"
S="${WORKDIR}/${MY_PF}-noCPAN"

elog "MY_PF=${MY_PF}"
elog "S=${S}"
SRC_URI="https://downloads.lms-community.org/LyrionMusicServer_v${PVR}/${MY_PF}-noCPAN.tgz"
HOMEPAGE="https://lyrion.org"

KEYWORDS="~amd64"
DESCRIPTION="Lyrion Music Server (streaming audio server)"
LICENSE="${MY_PN}"
RESTRICT="bindist mirror"
SLOT="0"
IUSE="systemd mp3 alac wavpack flac ogg aac mac freetype dlna"

EXTRALANGS="he"
for LANG in ${EXTRALANGS}; do
	IUSE="$IUSE l10n_${LANG}"
done

# Installation dependencies.
DEPEND="
	acct-user/${MY_PN}
	acct-group/${MY_PN}
	!media-sound/squeezecenter
	!media-sound/squeezeboxserver
	!media-sound/${MY_PN}-bin
	!media-sound/logitechmediaserver
	app-arch/unzip
	dev-lang/nasm
"

# Runtime dependencies.
# Um alle Dependencies zu finden kann man sich wie folgt behelfen.
# Im Github Repository findet man diese an der Folgenden Stelle:
# https://github.com/LMS-Community/slimserver/tree/<Branch>/<Tag>/CPAN/arch/<Aktuelle Perl Version auf dem Zielsystem>/
# Als Beispiel fuer den lyrionmusicserver in der Version 9.0
# und die Perl Version auf dem Zielsystem in der Version 5.40 lautet die URL:
# https://github.com/LMS-Community/slimserver/tree/public/9.0/CPAN/5.40
# Dort dann in den Unterverzeichnissen alle die Compiliert werden:
# Audio/Scan / Class/XSAccessor / DBD/SQLite / DBI / Digest/SHA1
# EV / Encode/Detect HTML/Parser / IO/AIO / IO/Interface / Image/Scale
# JSON/XS / Linux/Inotify2 / MP3/Cut/Gapless / Sub/Name / Template/Stash/XS
# XML/Parser/Expat / YAML/XS/LibYAML Linux  hier bis
# dev-perl/JSON-XS und dann der Rest im Ordner x86_64-linux-thread-multi/auto
# beginnend ab dev-perl/Digest-SHA1
# Es muessen sich alle in dem auto Ordner befindlichen Perl Pakete
# hier im ebuild auch als Runtime Dependencies wiederfinden
RDEPEND="
	|| ( >=dev-lang/perl-5.38.2-r3[perl_features_ithreads] <dev-lang/perl-5.38.2-r3[ithreads] )
	virtual/logger
	dev-db/sqlite
	>=dev-perl/Data-UUID-1.226
	=dev-perl/Audio-Scan-1.10
	>=dev-perl/Class-XSAccessor-1.190.0
	dev-perl/CGI
	dev-perl/Class-C3-XS
	dev-perl/DBD-SQLite
	dev-perl/DBI
	dev-perl/Digest-SHA1
	dev-perl/EV
	dev-perl/Encode-Detect
	dev-perl/HTML-Parser
	dev-perl/IO-AIO
	dev-perl/IO-Interface
	dev-perl/Image-Scale[gif,jpeg,png]
	dev-perl/JSON-XS
	dev-perl/Linux-Inotify2
	dev-perl/MP3-Cut-Gapless
	dev-perl/Sub-Name
	dev-perl/Template-Toolkit[gd]
	dev-perl/XML-Parser
	dev-perl/YAML-LibYAML
	l10n_he? ( dev-perl/Locale-Hebrew )
	mp3? ( media-sound/lame
		media-sound/mpg123[int-quality]
	)
	wavpack? ( media-sound/wavpack )
	flac? (
		media-libs/flac
		media-sound/sox[flac]
	)
	ogg? ( media-sound/sox[ogg] )
	aac? ( media-libs/slim-faad )
	alac? ( media-libs/slim-faad )
	mac? ( media-sound/mac )
	freetype? ( dev-perl/Font-FreeType )
	dlna? ( dev-perl/Media-Scan )
"

RUN_UID=${MY_PN}
RUN_GID=${MY_PN}

# Installation target locations
BINDIR="/opt/${MY_PN}"
DATADIR="/var/lib/${MY_PN}"
CACHEDIR="${DATADIR}/cache"
USRPLUGINSDIR="${DATADIR}/Plugins"
SVRPLUGINSDIR="${CACHEDIR}/InstalledPlugins"
CLIENTPLAYLISTSDIR="${DATADIR}/ClientPlaylists"
PREFSDIR="${DATADIR}/preferences"
LOGDIR="/var/log/${MY_PN}"
SVRPREFS="${PREFSDIR}/server.prefs"

# Old Squeezebox Server file locations
SBS_PREFSDIR="/etc/squeezeboxserver/prefs"
SBS_SVRPREFS="${SBS_PREFSDIR}/server.prefs"
SBS_VARLIBDIR="/var/lib/squeezeboxserver"
SBS_SVRPLUGINSDIR="${SBS_VARLIBDIR}/cache/InstalledPlugins"
SBS_USRPLUGINSDIR="${SBS_VARLIBDIR}/Plugins"

# Original preferences location from the Squeezebox overlay
R1_PREFSDIR="/etc/${MY_PN}"

PATCHES=(
	"${FILESDIR}/LMS-9.0.2_replace_UUID-Tiny_with_Data-UUID.patch"
	"${FILESDIR}/LMS-9.0.2_perl-recent.patch"
	"${FILESDIR}/LMS-9.0.2_remove_softlink_target_check.patch"
	"${FILESDIR}/LMS-9.0.2_move_client_playlist_path.patch"
)


# Use of DynaLoader causes conflicts because it prefers the system
# perl folders over the local CPAN folder. Following is a list of
# folders and files that we always want to remove from the LMS
# distributed CPAN modules because they are pulled in by our listed
# dependencies.
OBSOLETEDIRS=(
	"Audio"
	"Class/XSAccessor"
	"DBD"
	"DBI/Const"
	"DBI/DBD"
	"DBI/ProfileDumper"
	"Encode/Detect"
	"Image"
	"IO/Interface"
	"Locale"
	"Media"
	"MP3"
	"Sub"
	"Template/Namespace"
	"Template/Stash"
	"UUID"
	"XML/Parser"
	"YAML/XS"
	"arch"
	"common"
)

OBSOLETEFILES=(
	"Class/C3/XS.pm"
	"Class/XSAccessor.pm"
	"DBI/Profile.pm"
	"DBI/ProfileData.pm"
	"DBI/ProfileDumper.pm"
	"DBI/ProfileSubs.pm"
	"DBI/DBD.pm"
	"Digest/SHA1.pm"
	"JSON/XS/Boolean.pm"
	"JSON/XS.pm"
	"HTML/Entities.pm"
	"HTML/Filter.pm"
	"HTML/HeadParser.pm"
	"HTML/LinkExtor.pm"
	"HTML/Parser.pm"
	"HTML/PullParser.pm"
	"HTML/TokeParser.pm"
	"IO/AIO.pm"
	"IO/Interface.pm"
	"Linux/Inotify2.pm"
	"Template/Plugin/Assert.pm"
	"Template/Plugin/CGI.pm"
	"Template/Plugin/Datafile.pm"
	"Template/Plugin/Date.pm"
	"Template/Plugin/Directory.pm"
	"Template/Plugin/Dumper.pm"
	"Template/Plugin/File.pm"
	"Template/Plugin/Filter.pm"
	"Template/Plugin/Format.pm"
	"Template/Plugin/HTML.pm"
	"Template/Plugin/Image.pm"
	"Template/Plugin/Iterator.pm"
	"Template/Plugin/Math.pm"
	"Template/Plugin/Pod.pm"
	"Template/Plugin/Procedural.pm"
	"Template/Plugin/String.pm"
	"Template/Plugin/Scalar.pm"
	"Template/Plugin/Table.pm"
	"Template/Plugin/URL.pm"
	"Template/Plugin/View.pm"
	"Template/Plugin/Wrap.pm"
	"Template/Base.pm"
	"Template/Config.pm"
	"Template/Constants.pm"
	"Template/Context.pm"
	"Template/Directive.pm"
	"Template/Document.pm"
	"Template/Exception.pm"
	"Template/Filters.pm"
	"Template/Grammar.pm"
	"Template/Iterator.pm"
	"Template/Parser.pm"
	"Template/Plugin.pm"
	"Template/Plugins.pm"
	"Template/Service.pm"
	"Template/Stash.pm"
	"Template/Test.pm"
	"Template/View.pm"
	"Template/VMethods.pm"
	"XML/Parser.pm"
	"YAML/Dumper/Syck.pm"
	"YAML/Loader/Syck.pm"
	"YAML/XS.pm"
	"DBI.pm"
	"EV.pm"
	"Template.pm"
)

src_prepare() {
	default

	# fix default user name to run as
	elog "Die RUN_UID Variable fuer sed lautet: ${RUN_UID}"
	sed -e "s/squeezeboxserver/${RUN_UID}/" -i slimserver.pl

	# merge the secondary lib folder into CPAN, keeping track of the various locations
	# for CPAN modules is hard enough already without it.
	elog "Merging lib and CPAN folders together"
	cp -aR lib/* CPAN/
	rm -rf lib
	sed -e "/catdir(\$libPath,'lib'),/d" -i Slim/bootstrap.pm

	# Delete files that our dependencies have placed in the system's Perl vendor path
	elog "Remove CPAN modules that conflict with arch specific modules in the system vendor path"
	for DIR in ${OBSOLETEDIRS[@]} ; do
		rm -rf CPAN/${DIR}
	done
	for FILE in ${OBSOLETEFILES[@]} ; do
		rm -f CPAN/${FILE}
	done
}

src_install() {
	# Everything in our package into the /opt hierarchy
	elog "Installing package files"
	dodir "${BINDIR}"
	cp -aR ${S}/* "${ED}/${BINDIR}" || die "Unable to install package files"
	rm ${ED}/${BINDIR}/{Changelog*,License*,README.md,SOCKS.txt}

	# The custom OS module for Gentoo - provides OS-specific path details
	elog "Import custom paths to match Gentoo specifications"
	cp "${FILESDIR}/gentoo-filepaths.pm" "${ED}/${BINDIR}/Slim/Utils/OS/Custom.pm" || die "Unable to install Gentoo custom OS module"
	fperms 644 "${BINDIR}/Slim/Utils/OS/Custom.pm"

	# Install my own convert.conf file instead of the default one
	elog "In den nachfolgenden Schritten wird eine eigene convert.conf Datei installiert"
	elog "Bennene die Datei ${ED}${BINDIR}/convert.conf in ${ED}${BINDIR}/convert.conf.orig um"
	mv "${ED}${BINDIR}/convert.conf" "${ED}${BINDIR}/convert.conf.orig"
	elog "Ich fuege nun meine eigene convert.conf Datei hinzu"
	elog "Kopiere die Datei ${FILESDIR}/${MY_PF}.convert.conf nach ${ED}${BINDIR}/convert.conf"
	cp -a "${FILESDIR}/${MY_PF}.convert.conf" "${ED}${BINDIR}/convert.conf"

	# Documentation
	dodoc Changelog*.html
	dodoc License*.txt
	dodoc "${FILESDIR}/Gentoo-plugins-README.txt"

	# This may seem a weird construct, but it saves me from receiving QA messages on OpenRC systems
	if use systemd ; then
		# Install unit file (systemd)
		cat "${FILESDIR}/${MY_PN}.service" | sed "s/^#Env/Env/" > "${S}/../${MY_PN}.service"
		systemd_dounit "${S}/../${MY_PN}.service"
	else
		# Install init script (OpenRC)
		newinitd "${FILESDIR}/${MY_PN}.init.d" "${MY_PN}"
	fi
	newconfd "${FILESDIR}/${MY_PN}.conf.d" "${MY_PN}"

	# prepare data and log file locations
	elog "Set up log and data file locations"
	for TARGETDIR in ${LOGDIR} ${DATADIR} ${PREFSDIR} ${CACHEDIR} ${USRPLUGINSDIR} ${CLIENTPLAYLISTSDIR}; do
		keepdir ${TARGETDIR}
		fowners ${RUN_UID}:${RUN_GID} "${TARGETDIR}"
		fperms 770 "${TARGETDIR}"
	done
	for LOGFILE in server scanner perfmon; do
		touch "${ED}/${LOGDIR}/${LOGFILE}.log"
		fowners ${RUN_UID}:${RUN_GID} "${LOGDIR}/${LOGFILE}.log"
	done

	# Install logrotate support
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${MY_PN}.logrotate.d" "${MY_PN}"
}

lms_starting_instr() {
	elog "Lyrion Music Server can be started with the following command:"
	if use systemd ; then
		elog "\tsystemctl start ${MY_PN}"
	else
		elog "\t/etc/init.d/${MY_PN} start"
	fi
	elog ""
	elog "Lyrion Music Server can be automatically started on each boot"
	elog "with the following command:"
	if use systemd ; then
		elog "\tsystemctl enable ${MY_PN}"
	else
		elog "\trc-update add ${MY_PN} default"
	fi
	elog ""
	elog "You might want to examine and modify the following configuration"
	elog "file before starting Lyrion Music Server:"
	elog "\t/etc/conf.d/${MY_PN}"
	elog ""

	# Discover the port number from the preferences, but if it isn't there
	# then report the standard one.
	httpport=$(gawk '$1 == "httpport:" { print $2 }' "${ROOT}${SVRPREFS}" 2>/dev/null)
	elog "You may access and configure the Lyrion Music Server by browsing to:"
	elog "\thttp://localhost:${httpport:-9000}/"
	elog ""
}

pkg_postinst() {

	# Point user to database configuration step, if an old installation
	# of SBS is found.
	if [ -f "${SBS_SVRPREFS}" ]; then
		elog "If this is a new installation of teh Lyrion Music Server and you"
		elog "previously used Squeezebox Server (media-sound/squeezeboxserver)"
		elog "then you may migrate your previous preferences and plugins by"
		elog "running the following command (note that this will overwrite any"
		elog "current preferences and plugins):"
		elog "\temerge --config =${CATEGORY}/${PF}"
		elog ""
	fi

	# Tell user where they should put any manually-installed plugins.
	elog "Manually installed plugins should be placed in the following"
	elog "directory:"
	elog "\t${USRPLUGINSDIR}"
	elog ""

	# Bug: LMS should not write to /etc
	# Move existing preferences from /etc to /var/lib
	if [ ! -f "${PREFSDIR}/server.prefs" ]; then
		if [ -d "${R1_PREFSDIR}" ]; then
			cp -r "${R1_PREFSDIR}"/* "${PREFSDIR}" || die "Failed to copy preferences"
			rm -r "${R1_PREFSDIR}"
			chown -R ${RUN_UID}.${RUN_GID} "${PREFSDIR}"
		fi
	fi

	# Show some instructions on starting and accessing the server.
	lms_starting_instr
}

lms_remove_db_prefs() {
	MY_PREFS=$1

	einfo "Correcting database connection configuration:"
	einfo "\t${MY_PREFS}"
	TMPPREFS="${T}"/lmsserver-prefs-$$
	touch "${EROOT}${MY_PREFS}"
	sed -e '/^dbusername:/d' -e '/^dbpassword:/d' -e '/^dbsource:/d' < "${EROOT}${MY_PREFS}" > "${TMPPREFS}"
	mv "${TMPPREFS}" "${EROOT}${MY_PREFS}"
	chown ${RUN_UID}:${RUN_GID} "${EROOT}${MY_PREFS}"
	chmod 660 "${EROOT}${MY_PREFS}"
}

lms_clean_oldfiles() {
	einfo "locating "
	MY_PERL_VENDORPATH=$(LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" perl -V | grep vendorarch | sed "s/^.*vendorarch=//" | sed "s/ .*$//g")
	cd ${MY_PERL_VENDORPATH}
	find -type f | sed "s/^\.\///" | grep -v "/DBIx/" | while read file; do 
		if [ -f ${EROOT}${BINDIR}/CPAN/${file} ]; then
			rm -v ${EROOT}${BINDIR}/CPAN/${file}
		fi
	done
	cd - &>/dev/null

	# delete empty directories in LMS path
	cd ${EROOT}${BINDIR}
	MY_SEARCHDEPTH=5
	while [  ${MY_SEARCHDEPTH} -gt 0 ]; do
		find -mindepth ${MY_SEARCHDEPTH} -maxdepth ${MY_SEARCHDEPTH} -type d -empty -exec rmdir -v {} \;
		MY_SEARCHDEPTH=$((MY_SEARCHDEPTH-1))
	done
	cd - &>/dev/null
}

pkg_config() {
	einfo "Press ENTER to migrate any preferences from a previous installation of"
	einfo "Squeezebox Server (media-sound/squeezeboxserver) to this installation"
	einfo "of Lyrion Music Server."
	einfo ""
	einfo "Note that this will remove any current preferences and plugins and"
	einfo "therefore you should take a backup if you wish to preseve any files"
	einfo "from this current Lyrion Music Server installation."
	einfo ""
	einfo "Alternatively, press Control-C to abort now..."
	read

	# Preferences.
	einfo "Migrating previous Squeezebox Server configuration:"
	if [ -f "${SBS_SVRPREFS}" ]; then
		[ -d "${EROOT}${PREFSDIR}" ] && rm -rf "${EROOT}${PREFSDIR}"
		einfo "\tPreferences (${SBS_PREFSDIR})"
		cp -r "${EROOT}${SBS_PREFSDIR}" "${EROOT}${PREFSDIR}"
		chown -R ${RUN_UID}:${RUN_GID} "${EROOT}${PREFSDIR}"
		chmod -R u+w,g+w "${EROOT}${PREFSDIR}"
		chmod 770 "${EROOT}${PREFSDIR}"
	fi

	# Plugins installed through the built-in extension manager.
	if [ -d "${EROOT}${SBS_SVRPLUGINSDIR}" ]; then
		einfo "\tServer plugins (${SBS_SVRPLUGINSDIR})"
		[ -d "${EROOT}${SVRPLUGINSDIR}" ] && rm -rf "${EROOT}${SVRPLUGINSDIR}"
		cp -r "${EROOT}${SBS_SVRPLUGINSDIR}" "${EROOT}${SVRPLUGINSDIR}"
		chown -R ${RUN_UID}:${RUN_GID} "${EROOT}${SVRPLUGINSDIR}"
		chmod -R u+w,g+w "${EROOT}${SVRPLUGINSDIR}"
		chmod 770 "${EROOT}${SVRPLUGINSDIR}"
	fi

	# Plugins manually installed by the user.
	if [ -d "${EROOT}${SBS_USRPLUGINSDIR}" ]; then
		einfo "\tUser plugins (${SBS_USRPLUGINSDIR})"
		[ -d "${EROOT}${USRPLUGINSDIR}" ] && rm -rf "${EROOT}${USRPLUGINSDIR}"
		cp -r "${EROOT}${SBS_USRPLUGINSDIR}" "${EROOT}${USRPLUGINSDIR}"
		chown -R ${RUN_UID}:${RUN_GID} "${EROOT}${USRPLUGINSDIR}"
		chmod -R u+w,g+w "${EROOT}${USRPLUGINSDIR}"
		chmod 770 "${EROOT}${USRPLUGINSDIR}"
	fi

	# Remove the existing MySQL preferences from Squeezebox Server (if any).
	lms_remove_db_prefs "${SVRPREFS}"

	# Scan system for possible version conflicts
	lms_clean_oldfiles

	# Phew - all done. Give some tips on what to do now.
	einfo "Done."
	einfo ""
}
