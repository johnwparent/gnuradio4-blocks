#include <gnuradio-4.0/basic/DataSink.hpp>

#include <memory>

// The single definition of the process-wide DataSinkRegistry. Keeping it out of line, in one
// shared library, is what makes the registry shared rather than per-module: an inline function
// with a local static in a header gives every DLL that includes it a private instance on
// Windows, because there is no symbol interposition, so sinks created inside a plugin would be
// invisible to the host application querying them.
//
// This mirrors grGlobalBlockRegistry() in gnuradio-core's BlockRegistry.cpp. The extern "C"
// accessor keeps the exported symbol undecorated so it stays resolvable by name across modules.
extern "C" {
GNURADIO_EXPORT gr::blocks::basic::DataSinkRegistry* grGlobalDataSinkRegistry() {
    static gr::blocks::basic::DataSinkRegistry s_instance;
    return std::addressof(s_instance);
}
}

namespace gr::blocks::basic {
DataSinkRegistry& globalDataSinkRegistry() { return *grGlobalDataSinkRegistry(); }
} // namespace gr::blocks::basic
