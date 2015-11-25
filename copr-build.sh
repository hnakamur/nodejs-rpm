#!/bin/bash
set -e
copr_login=$1
copr_username=$2
copr_token=$3

project_name=nodejs5
spec_file=/root/rpmbuild/SPECS/nodejs.spec

mkdir -p /root/.config
cat > /root/.config/copr <<EOF
[copr-cli]
login = ${copr_login}
username = ${copr_username}
token = ${copr_token}
copr_url = https://copr.fedoraproject.org
EOF

status=`curl -s -o /dev/null -w "%{http_code}" https://copr.fedoraproject.org/api/coprs/${copr_username}/${project_name}/detail/`
if [ $status = "404" ]; then
  copr-cli create --chroot epel-7-x86_64 --description 'node.js repository' ${project_name}
fi
version=`awk '$1=="Version:" {print $2}' ${spec_file}`
release=$(rpm --eval `awk '$1=="Release:" {print $2}' ${spec_file}`)
srpm_file=/root/rpmbuild/SRPMS/nodejs-${version}-${release}.src.rpm
copr-cli build --nowait ${project_name} ${srpm_file}
