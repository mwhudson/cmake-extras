# Copyright (C) 2014 Canonical Ltd
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Build with system gmock and embedded gtest
#
# Usage:
#
# find_package(GMock)
#
# ...
#
# target_link_libraries(
#   my-target
#   ${GTEST_BOTH_LIBRARIES}
# )
#
# NOTE: Due to the way this package finder is implemented, do not attempt
# to find the GMock package more than once.

if (EXISTS "/usr/src/googletest")
    # As of version 1.8.0
    set (GMOCK_SOURCE_DIR "/usr/src/googletest/googlemock" CACHE PATH "gmock source directory")
    set (GMOCK_INCLUDE_DIRS "${GMOCK_SOURCE_DIR}/include" CACHE PATH "gmock source include directory")
    set (GTEST_INCLUDE_DIRS "/usr/src/googletest/googletest/include" CACHE PATH "gtest source include directory")
else()
    set (GMOCK_SOURCE_DIR "/usr/src/gmock" CACHE PATH "gmock source directory")
    set (GMOCK_INCLUDE_DIRS "/usr/include" CACHE PATH "gmock source include directory")
    set (GTEST_INCLUDE_DIRS "/usr/include" CACHE PATH "gtest source include directory")
endif()

# We add -g so we get debug info for the gtest stack frames with gdb.
# The warnings are suppressed so we get a noise-free build for gtest and gmock if the caller
# has these warnings enabled.
set(cxx_flags "${CMAKE_CXX_FLAGS} -g -Wno-old-style-cast -Wno-missing-field-initializers -Wno-ctor-dtor-privacy -Wno-switch-default")

set(BIN_DIR "${CMAKE_CURRENT_BINARY_DIR}/gmock")
set(GTEST_LIB "${BIN_DIR}/gtest/libgtest.a")
set(GTEST_MAIN_LIB "${BIN_DIR}/gtest/libgtest_main.a")
set(GMOCK_LIB "${BIN_DIR}/libgmock.a")
set(GMOCK_MAIN_LIB "${BIN_DIR}/libgmock_main.a")

include(ExternalProject)
ExternalProject_Add(GMock SOURCE_DIR "${GMOCK_SOURCE_DIR}"
                          BINARY_DIR "${BIN_DIR}"
                          BUILD_BYPRODUCTS "${GTEST_LIB}" "${GTEST_MAIN_LIB}" "${GMOCK_LIB}" "${GMOCK_MAIN_LIB}"
                          INSTALL_COMMAND ""
                          CMAKE_ARGS "-DCMAKE_CXX_FLAGS=${cxx_flags}")

add_library(gtest INTERFACE)
target_include_directories(gtest INTERFACE ${GTEST_INCLUDE_DIRS})
target_link_libraries(gtest INTERFACE ${GTEST_LIB} pthread)
add_dependencies(gtest GMock)

add_library(gtest_main INTERFACE)
target_include_directories(gtest_main INTERFACE ${GTEST_INCLUDE_DIRS})
target_link_libraries(gtest_main INTERFACE ${GTEST_MAIN_LIB} gtest)
add_dependencies(gtest_main GMock)

add_library(gmock INTERFACE)
target_include_directories(gmock INTERFACE ${GMOCK_INCLUDE_DIRS})
target_link_libraries(gmock INTERFACE ${GMOCK_LIB} gtest)
add_dependencies(gmock GMock)

add_library(gmock_main INTERFACE)
target_include_directories(gmock_main INTERFACE ${GMOCK_INCLUDE_DIRS})
target_link_libraries(gmock_main INTERFACE ${GMOCK_MAIN_LIB} gmock)
add_dependencies(gmock_main GMock)

set(GTEST_LIBRARIES gtest)
set(GTEST_MAIN_LIBRARIES gtest_main)
set(GMOCK_LIBRARIES gmock gmock_main)
set(GTEST_BOTH_LIBRARIES ${GTEST_LIBRARIES} ${GTEST_MAIN_LIBRARIES})
