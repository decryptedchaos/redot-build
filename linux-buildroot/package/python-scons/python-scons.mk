################################################################################
#
# scons
#
################################################################################

PYTHON_SCONS_VERSION = 4.5.2
PYTHON_SCONS_SOURCE = SCons-$(PYTHON_SCONS_VERSION).tar.gz
PYTHON_SCONS_SITE = https://sourceforge.net/projects/scons/files/scons/$(PYTHON_SCONS_VERSION)
PYTHON_SCONS_LICENSE = MIT
PYTHON_SCONS_LICENSE_FILES = LICENSE
PYTHON_SCONS_SETUP_TYPE = setuptools
HOST_PYTHON_SCONS_NEEDS_HOST_PYTHON = python3

$(eval $(host-python-package))
