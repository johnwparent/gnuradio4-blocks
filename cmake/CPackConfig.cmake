set(CPACK_PACKAGE_VENDOR "GNU Radio")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "GNU Radio 4 blocks")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/README.md")
# without this CPack substitutes its own placeholder licence into the installer
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_CONTACT "admin@gnuradio.org")
if(NOT CPACK_PACKAGE_NAME)
  set(CPACK_PACKAGE_NAME "gnuradio4-blocks")
endif()
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")

include(CPackComponent)

cpack_add_component(
  CORE
  DISPLAY_NAME "Runtime"
  DESCRIPTION "GNU Radio 4 blocks runtime libraries"
  REQUIRED)
cpack_add_component(DEVELOP DISPLAY_NAME "Development files"
                    DESCRIPTION "Headers, import libraries and CMake/pkg-config files needed to build against GR 4")

# APPLE implies UNIX, so macOS must be excluded here or it selects the Debian
# generator and `--target package` tries to build a .deb on a Mac.
if(UNIX AND NOT APPLE)
  if(NOT CPACK_GENERATOR)
    set(CPACK_GENERATOR "DEB")
  endif()

  set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
  set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
  # When installing to a non-standard prefix (e.g. /opt/gnuradio4), dpkg-shlibdeps
  # cannot find the package's own private libraries. Point it to the install lib dir.
  set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS "${CMAKE_INSTALL_PREFIX}/lib")
  if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    set(CPACK_DEBIAN_DEBUGINFO_PACKAGE ON)
  endif()
endif()

if(APPLE)
  set(CPACK_GENERATOR "productbuild")
  # gr_configure_productbuild_installer() comes from gr-core's installed
  # GrProductBuild.cmake, which gnuradio4Config.cmake includes on APPLE.
  #
  # Same reason as the Windows branch below: gr-blocks installs without
  # COMPONENT, so everything lands in Unspecified and a CORE/DEVELOP split would
  # ship empty components. Unspecified is therefore also the component that
  # carries the manifest registration -- REGISTER_COMPONENT must name one that
  # actually installs files, or gr-blocks would never appear in the manifest.
  set(CPACK_COMPONENTS_ALL Unspecified)
  set(CPACK_COMPONENT_UNSPECIFIED_DISPLAY_NAME "Runtime")

  # the identifier identifies gr-blocks to pkgutil across releases: never reuse
  # it in another GR installer and never change it between versions
  gr_configure_productbuild_installer(
    IDENTIFIER
    "org.gnuradio.gr4.blocks"
    PACKAGES
    "gr-blocks=${CPACK_PACKAGE_VERSION}"
    REGISTER_COMPONENT
    Unspecified
    PRESELECTED_COMPONENTS
    Unspecified)
endif()

if(WIN32)
  set(CPACK_GENERATOR "INNOSETUP")
  set(CPACK_INNOSETUP_USE_CMAKE_BOOL_FORMAT ON)
  set(CPACK_INNOSETUP_USE_MODERN_WIZARD ON)
  set(CPACK_INNOSETUP_ALLOW_CUSTOM_DIRECTORY ON)
  # fallback only: gr_configure_innosetup_installer() takes the install root from
  # the shared manifest when a GR 4 installation already exists
  set(CPACK_INNOSETUP_INSTALL_ROOT "{autopf}")
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "GNURadio4")
  # This needs to be the same for all GR component installs
  # so we allow it to be configurable
  if(NOT GR_START_MENU)
    set(GR_START_MENU "GNURadio 4.0")
  endif()
  set(CPACK_INNOSETUP_PROGRAM_MENU_FOLDER ${GR_START_MENU})
  # CPACK_COMPONENTS_ALL is deliberately unset: gr-blocks installs without
  # COMPONENT, so a CORE/DEVELOP split would ship empty components. Until the
  # installs are assigned, this stays a monolithic installer.

  # gr_configure_innosetup_installer() comes from find_package(gnuradio4)
  # the AppId identifies gr-blocks to Windows across releases: never reuse it in
  # another GR installer and never change it between versions
  gr_configure_innosetup_installer(
    APP_ID
    "{{8aa11ca1-4756-4280-b07b-e9aea3a00358}"
    PACKAGES
    "gr-blocks=${CPACK_PACKAGE_VERSION}"
    PRESELECTED_COMPONENTS
    CORE
    DEVELOP)
endif()

include(CPack)
