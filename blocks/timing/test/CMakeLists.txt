function(add_timing_test TEST_NAME)
  # add_ut_test() comes from core's GnuRadioTestHelpers and already supplies gnuradio-options,
  # gnuradio-core, gnuradio-blocklib-core, ut and -- importantly here -- gnuradio-plugin, whose
  # out-of-line gr_plugin_base destructor gnuradio-core's Graph/BlockModel/PluginLoader reference.
  # It also registers the test by target file rather than by directory, which a multi-config
  # generator needs, and sets the MSVC stack size and the Windows DLL search path.
  add_ut_test(${TEST_NAME})
  target_include_directories(${TEST_NAME} PRIVATE ${CMAKE_BINARY_DIR}/include)
  target_link_libraries(${TEST_NAME} PRIVATE gr-timing gr-testing)
  if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_link_libraries(${TEST_NAME} PRIVATE util)
  endif()
endfunction()

add_timing_test(qa_NMEAParser)
add_timing_test(qa_NMEADevice)

if(NOT EMSCRIPTEN)
  add_timing_test(qa_GpsSource)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT EMSCRIPTEN)
  add_timing_test(qa_PpsSource)
endif()
