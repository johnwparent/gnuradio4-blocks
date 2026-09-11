set(GrBasicBlocks_HDRS
    include/gnuradio-4.0/basic/ClockSource.hpp
    include/gnuradio-4.0/basic/ConverterBlocks.hpp
    include/gnuradio-4.0/basic/DataSink.hpp
    include/gnuradio-4.0/basic/FunctionGenerator.hpp
    include/gnuradio-4.0/basic/Selector.hpp
    include/gnuradio-4.0/basic/SignalGenerator.hpp
    include/gnuradio-4.0/basic/StreamToDataSet.hpp
    include/gnuradio-4.0/basic/SyncBlock.hpp
    include/gnuradio-4.0/basic/Trigger.hpp)

set(GrBasicBlocks_LIBS gnuradio4::gr-basic gnuradio4::gr-testing)

if(PYTHON_AVAILABLE)
  list(
    APPEND
    GrBasicBlocks_HDRS
    include/gnuradio-4.0/basic/PythonBlock.hpp
    include/gnuradio-4.0/basic/PythonInterpreter.hpp)
  list(
    APPEND
    GrBasicBlocks_LIBS
    Python3::Python
    Python3::NumPy)
endif()

add_library(gr-basic INTERFACE ${GrBasicBlocks_HDRS})
add_library(gnuradio4::gr-basic ALIAS gr-basic)
target_link_libraries(gr-basic INTERFACE gnuradio4::gnuradio-core gnuradio4::gnuradio-algorithm)
target_include_directories(gr-basic INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/>
                                              $<INSTALL_INTERFACE:include/>)
install(TARGETS gr-basic EXPORT gnuradio4Targets)
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include/gnuradio-4.0/basic"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/gnuradio-4.0")

# Owns the single process-wide DataSinkRegistry instance. It exists only so that the registry has
# exactly one definition to export: a header-inline local static is per-module on Windows, so a
# sink registered inside a plugin DLL would never be visible to the application polling for it.
# EMSCRIPTEN links everything into one module and has no shared libraries, so a static archive is
# both sufficient and required there -- the same split gnuradio-blocklib-core makes in core.
if(EMSCRIPTEN)
  add_library(gnuradio-datasink-core STATIC src/DataSinkRegistry.cpp)
else()
  add_library(gnuradio-datasink-core SHARED src/DataSinkRegistry.cpp)
endif()
add_library(gnuradio4::gnuradio-datasink-core ALIAS gnuradio-datasink-core)
set_target_properties(gnuradio-datasink-core PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_link_libraries(gnuradio-datasink-core PUBLIC gnuradio4::gnuradio-core gnuradio4::gnuradio-algorithm)
target_include_directories(gnuradio-datasink-core PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/>
                                                         $<INSTALL_INTERFACE:include/>)
gr_install_artifact(TARGETS gnuradio-datasink-core EXPORT gnuradio4Targets)

# every consumer of DataSink.hpp needs the definition the library holds
target_link_libraries(gr-basic INTERFACE gnuradio4::gnuradio-datasink-core)

gr_add_block_library(
  GrBasicBlocks
  MAKE_SHARED_LIBRARY
  MAKE_STATIC_LIBRARY
  HEADERS
  ${GrBasicBlocks_HDRS}
  LINK_LIBRARIES
  ${GrBasicBlocks_LIBS})

if(TARGET gnuradio4::GrBasicBlocksShared AND ENABLE_TESTING)
  add_subdirectory(test)
endif()
