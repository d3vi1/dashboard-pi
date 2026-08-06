include $(sort $(wildcard $(BR2_EXTERNAL_DASHBOARD_PI_PATH)/package/*/*.mk))

# Buildroot 2026.05 does not expose GStreamer's direct EGL/GBM winsys in
# gst1-plugins-base. WPEPlatform DRM needs gstreamer-gl without X11/Wayland.
ifeq ($(BR2_PACKAGE_DASHBOARD_PI_WPEWEBKIT),y)
GST1_PLUGINS_BASE_CONF_OPTS := $(filter-out -Dgl=disabled -Dgl_winsys=%,$(GST1_PLUGINS_BASE_CONF_OPTS))
GST1_PLUGINS_BASE_CONF_OPTS += -Dgl=enabled -Dgl_winsys=gbm
GST1_PLUGINS_BASE_DEPENDENCIES += libgbm libdrm libgudev

# gst1-plugins-base has already expanded its dependency graph by the time an
# external tree can append the dependencies above. Attach the direct GBM
# prerequisites to its configure stamp as well, so parallel clean builds cannot
# configure GStreamer before libgudev has populated staging.
$(GST1_PLUGINS_BASE_TARGET_CONFIGURE): libgbm libdrm libgudev
endif
