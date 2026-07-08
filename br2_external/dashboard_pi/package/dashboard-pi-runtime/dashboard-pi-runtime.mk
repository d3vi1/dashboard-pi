DASHBOARD_PI_RUNTIME_VERSION = 0.1
DASHBOARD_PI_RUNTIME_LICENSE = GPL-2.0-only
DASHBOARD_PI_RUNTIME_LICENSE_FILES = LICENSE

DASHBOARD_PI_RUNTIME_USERS = dashboard -1 dashboard -1 * - - video,input,render Dashboard Pi browser user

define DASHBOARD_PI_RUNTIME_INSTALL_TARGET_CMDS
	cp -a $(DASHBOARD_PI_RUNTIME_PKGDIR)/rootfs-overlay/. $(TARGET_DIR)/
	chmod 0755 $(TARGET_DIR)/usr/bin/dashboard-*
	mkdir -p $(TARGET_DIR)/etc/systemd/system
	ln -sf /usr/lib/systemd/system/dashboard.target \
		$(TARGET_DIR)/etc/systemd/system/default.target
	mkdir -p $(TARGET_DIR)/etc/systemd/system/sysinit.target.wants
	ln -sf /usr/lib/systemd/system/systemd-networkd.service \
		$(TARGET_DIR)/etc/systemd/system/sysinit.target.wants/systemd-networkd.service
	ln -sf /usr/lib/systemd/system/systemd-resolved.service \
		$(TARGET_DIR)/etc/systemd/system/sysinit.target.wants/systemd-resolved.service
	mkdir -p $(TARGET_DIR)/etc/systemd/system/dashboard.target.wants
	ln -sf /usr/lib/systemd/system/dashboard-url.service \
		$(TARGET_DIR)/etc/systemd/system/dashboard.target.wants/dashboard-url.service
	ln -sf /usr/lib/systemd/system/dashboard-browser.service \
		$(TARGET_DIR)/etc/systemd/system/dashboard.target.wants/dashboard-browser.service
	ln -sf /usr/lib/systemd/system/dashboard-cec.service \
		$(TARGET_DIR)/etc/systemd/system/dashboard.target.wants/dashboard-cec.service
	ln -sf /usr/lib/systemd/system/dashboard-syslog.service \
		$(TARGET_DIR)/etc/systemd/system/dashboard.target.wants/dashboard-syslog.service
	ln -sf ../run/systemd/resolve/stub-resolv.conf \
		$(TARGET_DIR)/etc/resolv.conf
endef

$(eval $(generic-package))
