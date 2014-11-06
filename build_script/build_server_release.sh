#!/bin/bash

BUILD_NUMBER=$1
BUILD_NAME=graylog2-server-$BUILD_NUMBER
BUILD_DIR=builds/$BUILD_NAME
BUILD_DATE=`date`
LOGFILE=`pwd`/logs/$BUILD_NAME

# decide whether to use gtar or tar
command -v gtar >/dev/null && TAR="gtar" || TAR="tar"

# Check if required version parameter is given
if [ -z $BUILD_NUMBER ]; then
  echo "ERROR: Missing parameter. (build number)"
  exit 1
fi

# Create directories
mkdir -p logs
mkdir -p builds
mkdir -p $BUILD_DIR

# Create logfile
touch $LOGFILE
date >> $LOGFILE

echo "PACKAGING SOURCES"

cd ..
mvn clean
mvn package
cd build_script

echo "BUILDING $BUILD_NAME"

# Add build date to release.
echo $BUILD_DATE > $BUILD_DIR/build_date

echo "Copying files ..."

# Copy files.
cp -R ../graylog2-server/target/graylog2-server.jar ../README.markdown ../COPYING $BUILD_DIR

# Copy example config files
cp ../misc/graylog2.conf $BUILD_DIR/graylog2.conf.example

# Copy control script
mkdir -p $BUILD_DIR/bin
cp -R copy/bin/graylog2ctl $BUILD_DIR/bin
cp copy/bin/graylog2-es-timestamp-fixup $BUILD_DIR/bin

# Create empty plugin directory.
mkdir -p $BUILD_DIR/plugin

mkdir -p $BUILD_DIR/log

cd builds/

# tar it
echo "Building Tarball ..."
$TAR cfz $BUILD_NAME.tar.gz $BUILD_NAME
rm -rf ./$BUILD_NAME
mv $BUILD_NAME.tar.gz $BUILD_NAME.tgz

echo "DONE! Created Graylog2 Server release $BUILD_NAME on $BUILD_DATE"