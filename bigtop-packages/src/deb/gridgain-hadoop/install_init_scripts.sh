#!/bin/bash
#
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

SRC_PKG=gridgain-hadoop

service_pkgdir=debian/$SRC_PKG
debdir=$service_pkgdir/DEBIAN
mkdir -p $service_pkgdir/etc/init.d/ $debdir
sed -e "s|@GRIDGAIN_DAEMON@|gridgain-hadoop|" debian/gridgain-hadoop.svc > debian/gridgain-hadoop1.svc
echo bash debian/init.d.tmpl debian/gridgain-hadoop1.svc deb $service_pkgdir/etc/init.d/$SRC_PKG
bash debian/init.d.tmpl debian/gridgain-hadoop1.svc deb $service_pkgdir/etc/init.d/$SRC_PKG

sed -e "s|@GRIDGAIN_DAEMON@|gridgain-hadoop|" debian/service-postinst.tpl > $debdir/postinst
sed -e "s|@GRIDGAIN_DAEMON@|gridgain-hadoop|" debian/service-postrm.tpl > $debdir/postrm
echo /etc/init.d/$SRC_PKG > $debdir/conffiles
chmod 755 $debdir/postinst $debdir/postrm $service_pkgdir/etc/init.d*

