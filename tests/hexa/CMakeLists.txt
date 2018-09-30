cmake_minimum_required(VERSION 3.4)

project(hexa)

# ========================================================================================

set(JUCE_juce_core_PATH "D:/dev/JUCE/modules")

add_library(_FRUT_juce_core INTERFACE)
target_compile_definitions(_FRUT_juce_core INTERFACE
  "JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED"
  "JUCE_STANDALONE_APPLICATION=1"
)
target_include_directories(_FRUT_juce_core INTERFACE
  "${JUCE_juce_core_PATH}"
)
add_library(JUCE::juce_core ALIAS _FRUT_juce_core)

add_library(_FRUT_juce_core_sources INTERFACE)
target_sources(_FRUT_juce_core_sources INTERFACE
  "${JUCE_juce_core_PATH}/juce_core/juce_core.cpp"
)
add_library(JUCE::juce_core_sources ALIAS _FRUT_juce_core_sources)


set(JUCE_juce_events_PATH "D:/dev/JUCE/modules")

add_library(_FRUT_juce_events INTERFACE)
target_include_directories(_FRUT_juce_events INTERFACE
  "${JUCE_juce_events_PATH}"
)
target_link_libraries(_FRUT_juce_events INTERFACE _FRUT_juce_core)
add_library(JUCE::juce_events ALIAS _FRUT_juce_events)

add_library(_FRUT_juce_events_sources INTERFACE)
target_sources(_FRUT_juce_events_sources INTERFACE
  "${JUCE_juce_events_PATH}/juce_events/juce_events.cpp"
)
add_library(JUCE::juce_events_sources ALIAS _FRUT_juce_events_sources)

# ========================================================================================

add_library(JuceLibrary STATIC)
target_link_libraries(JuceLibrary
  PUBLIC JUCE::juce_core JUCE::juce_events
  PRIVATE JUCE::juce_core_sources JUCE::juce_events_sources
)

add_executable(hexa
  "Source/Main.cpp"
)
target_link_libraries(hexa PRIVATE JuceLibrary)

add_executable(six
  "Source/Main.cpp"
)
target_link_libraries(six PRIVATE JuceLibrary)
