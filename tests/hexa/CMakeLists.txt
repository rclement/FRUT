cmake_minimum_required(VERSION 3.4)

project(hexa)

# ========================================================================================

set(JUCE_juce_core_PATH "D:/dev/JUCE/modules")

add_library(_FRUT_juce_core_objects OBJECT
  "${JUCE_juce_core_PATH}/juce_core/juce_core.cpp"
)
target_include_directories(_FRUT_juce_core_objects INTERFACE
  "${JUCE_juce_core_PATH}"
)
target_compile_definitions(_FRUT_juce_core_objects PUBLIC
  "JUCE_GLOBAL_MODULE_SETTINGS_INCLUDED"
  "JUCE_STANDALONE_APPLICATION=1"
)
target_sources(_FRUT_juce_core_objects INTERFACE
  "$<TARGET_OBJECTS:_FRUT_juce_core_objects>"
)

add_library(_FRUT_juce_core INTERFACE)
foreach(prop COMPILE_DEFINITIONS INCLUDE_DIRECTORIES SOURCES)
  set_target_properties(_FRUT_juce_core PROPERTIES
    INTERFACE_${prop} "$<TARGET_PROPERTY:_FRUT_juce_core_objects,INTERFACE_${prop}>"
  )
endforeach()
add_library(JUCE::juce_core ALIAS _FRUT_juce_core)


set(JUCE_juce_events_PATH "D:/dev/JUCE/modules")

add_library(_FRUT_juce_events_objects OBJECT
  "${JUCE_juce_events_PATH}/juce_events/juce_events.cpp"
)
target_compile_definitions(_FRUT_juce_events_objects
  PUBLIC "$<TARGET_PROPERTY:_FRUT_juce_core_objects,INTERFACE_COMPILE_DEFINITIONS>"
)
target_include_directories(_FRUT_juce_events_objects
  INTERFACE "${JUCE_juce_events_PATH}"
  PUBLIC "$<TARGET_PROPERTY:_FRUT_juce_core_objects,INTERFACE_INCLUDE_DIRECTORIES>"
)
target_sources(_FRUT_juce_events_objects INTERFACE
  "$<TARGET_OBJECTS:_FRUT_juce_events_objects>"
)

add_library(_FRUT_juce_events INTERFACE)
foreach(prop COMPILE_DEFINITIONS INCLUDE_DIRECTORIES SOURCES)
  set_target_properties(_FRUT_juce_events PROPERTIES
    INTERFACE_${prop} "$<TARGET_PROPERTY:_FRUT_juce_events_objects,INTERFACE_${prop}>"
  )
endforeach()
add_library(JUCE::juce_events ALIAS _FRUT_juce_events)

# ========================================================================================

add_library(JuceLibrary STATIC)
target_link_libraries(JuceLibrary PUBLIC
  JUCE::juce_core
  JUCE::juce_events
)

add_executable(hexa
  "Source/Main.cpp"
)
target_link_libraries(hexa PRIVATE JuceLibrary)

add_executable(six
  "Source/Main.cpp"
)
target_link_libraries(six PRIVATE JuceLibrary)
