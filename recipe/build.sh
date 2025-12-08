#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Create package archive and install globally
npm pack --ignore-scripts
npm install -ddd \
    --no-bin-links \
    --global \
    --build-from-source \
    ${SRC_DIR}/${PKG_NAME}-${PKG_VERSION}.tgz

mkdir -p ${PREFIX}/bin
tee ${PREFIX}/bin/tsc << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/typescript/bin/tsc "\$@"
EOF
chmod +x ${PREFIX}/bin/tsc

tee ${PREFIX}/bin/tsserver << EOF
#!/bin/sh
exec \${CONDA_PREFIX}/lib/node_modules/typescript/bin/tsserver "\$@"
EOF
chmod +x ${PREFIX}/bin/tsserver

tee ${PREFIX}/bin/tsc.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\typescript\bin\tsc %*
EOF

tee ${PREFIX}/bin/tsserver.cmd << EOF
call %CONDA_PREFIX%\bin\node %CONDA_PREFIX%\lib\node_modules\typescript\bin\tsserver %*
EOF
