#!/bin/bash
# Download all required Python packages for offline builds

set -e

# Create packages directory if it doesn't exist
mkdir -p debian-gitfs/packages

echo "Downloading Python packages for offline build..."

# Use make to get the variables
get_var() {
    make -f VERSIONS -f - <<< "print-$1: ; @echo \$($1)" print-$1 2>/dev/null
}

# Download wheel packages
wget -q "$(get_var HATCHLING_URL)" -O "debian-gitfs/packages/hatchling-$(get_var HATCHLING_VERSION).whl"
wget -q "$(get_var PACKAGING_URL)" -O "debian-gitfs/packages/packaging-$(get_var PACKAGING_VERSION).whl"
wget -q "$(get_var PATHSPEC_URL)" -O "debian-gitfs/packages/pathspec-$(get_var PATHSPEC_VERSION).whl"
wget -q "$(get_var PLUGGY_URL)" -O "debian-gitfs/packages/pluggy-$(get_var PLUGGY_VERSION).whl"
wget -q "$(get_var TROVE_CLASSIFIERS_URL)" -O "debian-gitfs/packages/trove-classifiers-$(get_var TROVE_CLASSIFIERS_VERSION).whl"

# Download tar.gz packages
wget -q "$(get_var ATOMICLONG_URL)" -O "debian-gitfs/packages/atomiclong-$(get_var ATOMICLONG_VERSION).tar.gz"
wget -q "$(get_var CFFI_URL)" -O "debian-gitfs/packages/cffi-$(get_var CFFI_VERSION).tar.gz"
wget -q "$(get_var MFUSEPY_URL)" -O "debian-gitfs/packages/mfusepy-$(get_var MFUSEPY_VERSION).tar.gz"
wget -q "$(get_var PYCPARSER_URL)" -O "debian-gitfs/packages/pycparser-$(get_var PYCPARSER_VERSION).tar.gz"
wget -q "$(get_var PYGIT2_URL)" -O "debian-gitfs/packages/pygit2-$(get_var PYGIT2_VERSION).tar.gz"
wget -q "$(get_var SENTRY_SDK_URL)" -O "debian-gitfs/packages/sentry-sdk-$(get_var SENTRY_SDK_VERSION).tar.gz"
wget -q "$(get_var URLLIB3_URL)" -O "debian-gitfs/packages/urllib3-$(get_var URLLIB3_VERSION).tar.gz"
wget -q "$(get_var PIP_URL)" -O "debian-gitfs/packages/pip-$(get_var PIP_VERSION).tar.gz"
wget -q "$(get_var SETUPTOOLS_URL)" -O "debian-gitfs/packages/setuptools-$(get_var SETUPTOOLS_VERSION).tar.gz"
wget -q "$(get_var WHEEL_URL)" -O "debian-gitfs/packages/wheel-$(get_var WHEEL_VERSION).tar.gz"
wget -q "$(get_var FLIT_CORE_URL)" -O "debian-gitfs/packages/flit-core-$(get_var FLIT_CORE_VERSION).tar.gz"

echo "All packages downloaded successfully!"
ls -la debian-gitfs/packages/
