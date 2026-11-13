#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pkg delete optionalDependencies
npm pack --ignore-scripts
npm install -ddd \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

case "${GOARCH}" in
    amd64) node_arch=x64 ;;
    *) node_arch=${GOARCH} ;;
esac
platform_package_name=typescript-${GOOS}-${node_arch}
platform_package_dir=${PREFIX}/lib/node_modules/@typescript/${platform_package_name}

mkdir -p ${platform_package_dir}/lib
pushd typescript-go
go-licenses save ./cmd/tsgo --save_path ${SRC_DIR}/library_licenses
go build -trimpath -ldflags="-s -w" -tags noembed -o ${platform_package_dir}/lib/tsc ./cmd/tsgo
cp internal/bundled/libs/* ${platform_package_dir}/lib/
cp LICENSE NOTICE.txt ${platform_package_dir}/
popd

tee ${platform_package_dir}/package.json << EOF
{
    "name": "@typescript/${platform_package_name}",
    "version": "${PKG_VERSION}",
    "license": "Apache-2.0",
    "os": ["${GOOS}"],
    "cpu": ["${node_arch}"],
    "exports": {
        "./package.json": "./package.json"
    }
}
EOF
