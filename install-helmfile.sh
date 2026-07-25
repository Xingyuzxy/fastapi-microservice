curl -s https://api.github.com/repos/helmfile/helmfile/releases/latest | grep tag_name

VERSION=v1.1.7

wget https://github.com/helmfile/helmfile/releases/download/${VERSION}/helmfile_${VERSION#v}_linux_amd64.tar.gz

tar -xzf helmfile_${VERSION#v}_linux_amd64.tar.gz

sudo mv helmfile /usr/local/bin/

chmod +x /usr/local/bin/helmfile

helm plugin install https://github.com/databus23/helm-diff