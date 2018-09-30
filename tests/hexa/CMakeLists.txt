cmake_minimum_required(VERSION 3.4)

project(hexa)

# ========================================================================================

set(JUCE_juce_core_PATH "D:/dev/JUCE/modules")

add_library(JUCE::juce_core INTERFACE IMPORTED)
set_property(TARGET JUCE::juce_core PROPERTY
  INTERFACE_COMPILE_DEFINITIONS
    "JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED"
    "JUCE_STANDALONE_APPLICATION=1"
)
set_target_properties(JUCE::juce_core PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${JUCE_juce_core_PATH}"
)

add_library(JUCE::juce_core::sources INTERFACE IMPORTED)
set_target_properties(JUCE::juce_core::sources PROPERTIES
  INTERFACE_LINK_LIBRARIES "JUCE::juce_core"
  INTERFACE_SOURCES "${JUCE_juce_core_PATH}/juce_core/juce_core.cpp"
)


set(JUCE_juce_events_PATH "D:/dev/JUCE/modules")

add_library(JUCE::juce_events INTERFACE IMPORTED)
set_target_properties(JUCE::juce_events PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${JUCE_juce_events_PATH}"
  INTERFACE_LINK_LIBRARIES "JUCE::juce_core"
)

add_library(JUCE::juce_events::sources INTERFACE IMPORTED)
set_target_properties(JUCE::juce_events::sources PROPERTIES
  INTERFACE_LINK_LIBRARIES "JUCE::juce_events"
  INTERFACE_SOURCES "${JUCE_juce_events_PATH}/juce_events/juce_events.cpp"
)

# ========================================================================================

add_library(JuceLibrary STATIC)
target_link_libraries(JuceLibrary
  PUBLIC JUCE::juce_events
  PRIVATE JUCE::juce_core::sources JUCE::juce_events::sources
)

add_executable(hexa
  "Source/Main.cpp"
)
target_link_libraries(hexa PRIVATE JuceLibrary)

add_executable(six
  "Source/Main.cpp"
)
target_link_libraries(six PRIVATE JuceLibrary)
