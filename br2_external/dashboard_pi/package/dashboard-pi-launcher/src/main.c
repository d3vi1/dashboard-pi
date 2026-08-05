// SPDX-License-Identifier: GPL-2.0-only

#include <glib-unix.h>
#include <stdlib.h>
#include <string.h>
#include <wpe/webkit.h>

static GMainLoop *main_loop;
static WebKitWebView *web_view;

static gboolean
uri_is_allowed(const char *uri)
{
    if (g_str_has_prefix(uri, "http://") || g_str_has_prefix(uri, "https://"))
        return TRUE;

    return g_str_has_prefix(uri, "file:///usr/share/dashboard-pi/");
}

static const char *
load_event_name(WebKitLoadEvent event)
{
    switch (event) {
    case WEBKIT_LOAD_STARTED:
        return "started";
    case WEBKIT_LOAD_REDIRECTED:
        return "redirected";
    case WEBKIT_LOAD_COMMITTED:
        return "committed";
    case WEBKIT_LOAD_FINISHED:
        return "finished";
    }

    return "unknown";
}

static void
load_changed(WebKitWebView *view, WebKitLoadEvent event, gpointer user_data)
{
    const char *uri = webkit_web_view_get_uri(view);

    (void)user_data;
    g_message("navigation event=%s monotonic_us=%" G_GINT64_FORMAT " uri=%s",
        load_event_name(event), g_get_monotonic_time(), uri ? uri : "");
}

static gboolean
reload_page(gpointer user_data)
{
    (void)user_data;
    webkit_web_view_reload_bypass_cache(web_view);
    return G_SOURCE_CONTINUE;
}

static gboolean
go_back(gpointer user_data)
{
    (void)user_data;
    if (webkit_web_view_can_go_back(web_view))
        webkit_web_view_go_back(web_view);
    return G_SOURCE_CONTINUE;
}

static gboolean
go_forward(gpointer user_data)
{
    (void)user_data;
    if (webkit_web_view_can_go_forward(web_view))
        webkit_web_view_go_forward(web_view);
    return G_SOURCE_CONTINUE;
}

static gboolean
quit(gpointer user_data)
{
    (void)user_data;
    g_main_loop_quit(main_loop);
    return G_SOURCE_REMOVE;
}

int
main(int argc, char **argv)
{
    if (argc != 2 || !uri_is_allowed(argv[1])) {
        g_printerr("usage: %s <http(s) URL or Dashboard Pi local page>\n", argv[0]);
        return EXIT_FAILURE;
    }

    main_loop = g_main_loop_new(NULL, FALSE);
    web_view = WEBKIT_WEB_VIEW(g_object_new(WEBKIT_TYPE_WEB_VIEW, NULL));
    g_signal_connect(web_view, "load-changed", G_CALLBACK(load_changed), NULL);

    g_unix_signal_add(SIGHUP, reload_page, NULL);
    g_unix_signal_add(SIGUSR1, go_back, NULL);
    g_unix_signal_add(SIGUSR2, go_forward, NULL);
    g_unix_signal_add(SIGTERM, quit, NULL);
    g_unix_signal_add(SIGINT, quit, NULL);

    g_message("launcher-start monotonic_us=%" G_GINT64_FORMAT " uri=%s",
        g_get_monotonic_time(), argv[1]);
    webkit_web_view_load_uri(web_view, argv[1]);
    g_main_loop_run(main_loop);

    g_clear_object(&web_view);
    g_main_loop_unref(main_loop);
    return EXIT_SUCCESS;
}
