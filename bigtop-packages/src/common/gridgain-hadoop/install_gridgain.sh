#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

usage() {
  echo "
usage: $0 <options>
  Required not-so-options:
     --build-dir=DIR             path to gridgain dist.dir
     --prefix=PREFIX             path to install into

  Optional options:
     --doc-dir=DIR               path to install docs into [/usr/share/doc/gridgain]
     --lib-dir=DIR               path to install gridgain home [/usr/lib/gridgain]
     --installed-lib-dir=DIR     path where lib-dir will end up on target system
     --bin-dir=DIR               path to install bins [/usr/bin]
     --examples-dir=DIR          path to install examples [doc-dir/examples]
     ... [ see source for more similar options ]
  "
  exit 1
}

OPTS=$(getopt \
  -n $0 \
  -o '' \
  -l 'prefix:' \
  -l 'doc-dir:' \
  -l 'lib-dir:' \
  -l 'installed-lib-dir:' \
  -l 'bin-dir:' \
  -l 'examples-dir:' \
  -l 'conf-dir:' \
  -l 'build-dir:' -- "$@")

if [ $? != 0 ] ; then
    usage
fi

eval set -- "$OPTS"
while true ; do
    case "$1" in
        --prefix)
        PREFIX=$2 ; shift 2
        ;;
        --build-dir)
        BUILD_DIR=$2 ; shift 2
        ;;
        --doc-dir)
        DOC_DIR=$2 ; shift 2
        ;;
        --lib-dir)
        LIB_DIR=$2 ; shift 2
        ;;
        --installed-lib-dir)
        INSTALLED_LIB_DIR=$2 ; shift 2
        ;;
        --bin-dir)
        BIN_DIR=$2 ; shift 2
        ;;
        --examples-dir)
        EXAMPLES_DIR=$2 ; shift 2
        ;;
        --conf-dir)
        CONF_DIR=$2 ; shift 2
        ;;
        --)
        shift ; break
        ;;
        *)
        echo "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
done

for var in PREFIX BUILD_DIR ; do
  if [ -z "$(eval "echo \$$var")" ]; then
    echo Missing param: $var
    usage
  fi
done

MAN_DIR=${MAN_DIR:-/usr/share/man/man1}
DOC_DIR=${DOC_DIR:-/usr/share/doc/gridgain-hadoop}
LIB_DIR=${LIB_DIR:-/usr/lib/gridgain-hadoop}
BIN_DIR=${BIN_DIR:-/usr/lib/gridgain-hadoop/bin}
ETC_DIR=${ETC_DIR:-/etc/gridgain-hadoop}
CONF_DIR=${CONF_DIR:-${ETC_DIR}/conf.dist}

install -d -m 0755 $PREFIX/$LIB_DIR
install -d -m 0755 $PREFIX/$LIB_DIR/libs
install -d -m 0755 $PREFIX/$DOC_DIR
install -d -m 0755 $PREFIX/$BIN_DIR
install -d -m 0755 $PREFIX/$BIN_DIR/include
install -d -m 0755 $PREFIX/$ETC_DIR
install -d -m 0755 $PREFIX/$CONF_DIR
install -d -m 0755 $PREFIX/$MAN_DIR

unzip -x $BUILD_DIR/gridgain-hadoop-os-*.zip

UNZIP_DIR=gridgain-hadoop-os-*
cp -a $UNZIP_DIR/libs/gridgain*.jar $PREFIX/$LIB_DIR/libs
cp -a $UNZIP_DIR/libs/gridgain-hadoop/*.jar $PREFIX/$LIB_DIR/libs
cp -ar $UNZIP_DIR/libs/gridgain-spring $PREFIX/$LIB_DIR/libs
cp -ar $UNZIP_DIR/libs/gridgain-log4j $PREFIX/$LIB_DIR/libs
cp -ar $UNZIP_DIR/libs/gridgain-ggfs $PREFIX/$LIB_DIR/libs
cp -ar $UNZIP_DIR/libs/licenses $PREFIX/$LIB_DIR/libs
cp -a $UNZIP_DIR/libs/readme.txt $PREFIX/$LIB_DIR/libs
cp -ra $UNZIP_DIR/docs/* $PREFIX/$DOC_DIR

cp -a $UNZIP_DIR/config/* $PREFIX/$CONF_DIR
cp -ra $UNZIP_DIR/bin/* $PREFIX/$BIN_DIR

ln -s $ETC_DIR/conf $PREFIX/$LIB_DIR/config

# Make a symlink of gridgain.jar to gridgain-version.jar
pushd `pwd`
cd $PREFIX/$LIB_DIR/libs
for i in `ls gridgain*jar | grep -v tests.jar`
do
    ln -s $i `echo $i | sed -n 's/\(.*\)\(-[0-9].*\)\(.jar\)/\1\3/p'`
done
popd

wrapper=$PREFIX/usr/bin/gridgain-hadoop
mkdir -p `dirname $wrapper`
cat > $wrapper <<EOF
#!/bin/bash

BIGTOP_DEFAULTS_DIR=\${BIGTOP_DEFAULTS_DIR-/etc/default}
[ -n "\${BIGTOP_DEFAULTS_DIR}" -a -r \${BIGTOP_DEFAULTS_DIR}/gridgain-hadoop ] && . \${BIGTOP_DEFAULTS_DIR}/gridgain-hadoop

# Autodetect JAVA_HOME if not defined
. /usr/lib/bigtop-utils/bigtop-detect-javahome

export GRIDGAIN_CLASSPATH=\$HADOOP_HOME/*:\$HADOOP_HOME/lib/*:\$GRIDGAIN_CLASSPATH

exec /usr/lib/gridgain-hadoop/bin/include/service.sh "\$@"
EOF
chmod 755 $wrapper

install -d -m 0755 $PREFIX/usr/bin
