cmake_minimum_required(VERSION 3.16)
project(dashboard-pi-launcher VERSION 0.1.0 LANGUAGES C)

find_package(PkgConfig REQUIRED)
pkg_check_modules(WPE REQUIRED IMPORTED_TARGET wpe-webkit-2.0 wpe-platform-2.0)

add_executable(dashboard-pi-launcher main.c)
target_compile_features(dashboard-pi-launcher PRIVATE c_std_11)
target_compile_options(dashboard-pi-launcher PRIVATE -Wall -Wextra -Werror)
target_link_libraries(dashboard-pi-launcher PRIVATE PkgConfig::WPE)

install(TARGETS dashboard-pi-launcher RUNTIME DESTINATION bin)
