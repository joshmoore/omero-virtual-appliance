#!/bin/bash

set -e -u -x

PGPASSWORD=${PGPASSWORD:-"omero"}

DL_LOC="http://hudson.openmicroscopy.org.uk/job/OMERO-trunk-qa-builds/lastSuccessfulBuild/artifact/"
DL_ARCHIVE="OMERO.server-4.3.0-DEV-bfe035dd.zip"
DL_FOLDER=${DL_ARCHIVE%.zip}

DB_VERSION="OMERO4.3"
DB_REVISION="0"
OMERO_PATH="/home/omero/OMERO.server"
OMERO_BIN=$OMERO_PATH/bin

#	echo "Grabbing OMERO.server src"
#	if test -e OMERO.server; then
#		pushd OMERO.server
#		if test -e dist; then
#			dist/bin/omero admin stop
#		fi
#		git pull git://git.openmicroscopy.org/ome.git
#		./build.py clean
#		popd
#	else
#		git clone git://git.openmicroscopy.org/ome.git OMERO.server
#	fi
#	    pushd OMERO.server
#	    python build.py
#	    popd

	echo "Grabbing QA Build of OMERO.server"
	wget $DL_LOC$DL_ARCHIVE
	unzip $DL_ARCHIVE
	mv $DL_FOLDER OMERO.server
    
mkdir OMERO.data
$OMERO_BIN/omero config set omero.data.dir /home/omero/OMERO.data

$OMERO_BIN/omero config set omero.db.name 'omero'
$OMERO_BIN/omero config set omero.db.user 'omero'
$OMERO_BIN/omero config set omero.db.pass 'omero'

$OMERO_BIN/omero db script -f db.sql $DB_VERSION $DB_REVISION $PGPASSWORD

psql -h localhost -U omero omero < db.sql