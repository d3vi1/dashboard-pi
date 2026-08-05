################################################################################
#
# dashboard-pi-launcher
#
################################################################################

DASHBOARD_PI_LAUNCHER_VERSION = 0.1.0
DASHBOARD_PI_LAUNCHER_SITE = $(DASHBOARD_PI_LAUNCHER_PKGDIR)/src
DASHBOARD_PI_LAUNCHER_SITE_METHOD = local
DASHBOARD_PI_LAUNCHER_DEPENDENCIES = dashboard-pi-wpewebkit
DASHBOARD_PI_LAUNCHER_LICENSE = GPL-2.0-only
DASHBOARD_PI_LAUNCHER_LICENSE_FILES = LICENSE

$(eval $(cmake-package))
