// Copyright (c) 2017 Alain Martin, Matthieu Talbot
//
// This file is part of JUCE.cmake.
//
// JUCE.cmake is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// JUCE.cmake is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with JUCE.cmake.  If not, see <http://www.gnu.org/licenses/>.

#include "JuceHeader.h"

#include <fstream>
#include <functional>
#include <iostream>
#include <iterator>
#include <locale>
#include <numeric>
#include <string>
#include <utility>
#include <vector>


void printError(const std::string& error)
{
  std::cerr << "error: " << error << std::endl;
}


std::string escape(const std::string& charsToEscape, std::string value)
{
  auto pos = std::string::size_type{0};

  while ((pos = value.find_first_of(charsToEscape, pos)) != std::string::npos)
  {
    value.insert(pos, "\\");
    pos += 2;
  }

  return value;
}


std::vector<std::string> escape(
  const std::string& charsToEscape, std::vector<std::string> elements)
{
  std::transform(elements.begin(),
    elements.end(),
    elements.begin(),
    [&charsToEscape](const std::string& element)
    {
      return escape(charsToEscape, element);
    });
  return elements;
}


std::string join(const std::string& sep, const std::vector<std::string>& elements)
{
  if (elements.empty())
  {
    return {};
  }

  return std::accumulate(std::next(elements.begin()),
    elements.end(),
    *elements.begin(),
    [&sep](const std::string& sum, const std::string& elm)
    {
      return sum + sep + elm;
    });
}


std::vector<std::string> split(const std::string& sep, const std::string& value)
{
  std::vector<std::string> tokens;
  std::string::size_type start = 0u, end = 0u;

  while ((end = value.find(sep, start)) != std::string::npos)
  {
    tokens.push_back(value.substr(start, end - start));
    start = end + sep.length();
  }
  tokens.push_back(value.substr(start));

  return tokens;
}


std::string makePreprocessorDefinitionsList(const std::string& preprocessorDefinitions)
{
  return join("\\;", escape("\"", split("\n", preprocessorDefinitions)));
}


int main(int argc, char* argv[])
{
  if (argc != 3)
  {
    std::cerr << "usage: Jucer2CMake"
                 " <jucer_project_file>"
                 " <Reprojucer.cmake_file>"
              << std::endl;
    return 1;
  }

  const auto args = std::vector<std::string>{argv, argv + argc};
  const auto& jucerFilePath = args.at(1);
  const auto& reprojucerFilePath = args.at(2);

  const auto xml = std::unique_ptr<juce::XmlElement>{
    juce::XmlDocument::parse(juce::File{jucerFilePath})};
  if (xml == nullptr || !xml->hasTagName("JUCERPROJECT"))
  {
    printError(jucerFilePath + " is not a valid Jucer project.");
    return 1;
  }

  const auto jucerProject = juce::ValueTree::fromXml(*xml);
  if (!jucerProject.hasType("JUCERPROJECT"))
  {
    printError(jucerFilePath + " is not a valid Jucer project.");
    return 1;
  }

  std::ofstream out{"CMakeLists.txt"};

  const auto jucerFileName = juce::File{jucerFilePath}.getFileName().toStdString();

  // Preamble
  {
    out << "# This file was generated by Jucer2CMake from " << jucerFileName << "\n"
        << "\n"
        << "cmake_minimum_required(VERSION 3.4)\n"
        << "\n"
        << "\n";
  }

  // include(Reprojucer)
  {
    out << "list(APPEND CMAKE_MODULE_PATH \""
        << "${CMAKE_CURRENT_LIST_DIR}/"
        << juce::File{reprojucerFilePath}
             .getParentDirectory()
             .getRelativePathFrom(juce::File::getCurrentWorkingDirectory())
             .replace("\\", "/")
        << "\")\n"
        << "include(Reprojucer)\n"
        << "\n"
        << "\n";
  }

  std::string escapedJucerFileName = jucerFileName;
  std::replace_if(escapedJucerFileName.begin(),
    escapedJucerFileName.end(),
    [](const std::string::value_type& c)
    {
      return !(std::isalpha(c, std::locale{"C"}) || std::isdigit(c, std::locale{"C"}));
    },
    '_');

  // get_filename_component()
  {
    out << "if(NOT DEFINED " << escapedJucerFileName << "_FILE)\n"
        << "  message(FATAL_ERROR \"" << escapedJucerFileName
        << "_FILE must be defined\")\n"
        << "endif()\n"
        << "\n"
        << "get_filename_component(" << escapedJucerFileName << "_FILE\n"
        << "  \"${" << escapedJucerFileName << "_FILE}\" ABSOLUTE\n"
        << "  BASE_DIR \"${CMAKE_BINARY_DIR}\"\n"
        << ")\n"
        << "\n"
        << "if(NOT EXISTS \"${" << escapedJucerFileName << "_FILE}\")\n"
        << "  message(FATAL_ERROR \"No such file: ${" << escapedJucerFileName
        << "_FILE}\")\n"
        << "endif()\n"
        << "\n"
        << "get_filename_component(" << escapedJucerFileName << "_DIR\n"
        << "  \"${" << escapedJucerFileName << "_FILE}\" DIRECTORY\n"
        << ")\n"
        << "\n"
        << "\n";
  }

  // set(VST3_SDK_FOLDER)
  if (jucerProject.getChildWithName("MODULES")
        .getChildWithProperty("id", "juce_audio_processors")
        .isValid() &&
      jucerProject.getChildWithName("JUCEOPTIONS").getProperty("JUCE_PLUGINHOST_VST3") ==
        "enabled")
  {
    out << "if(WIN32)\n"
        << "  set(VST3_SDK_FOLDER \"C:/SDKs/VST_SDK/VST3_SDK\")\n"
        << "else()\n"
        << "  set(VST3_SDK_FOLDER \"~/SDKs/VST_SDK/VST3_SDK\")\n"
        << "endif()\n"
        << "set(VST3_SDK_FOLDER \"${VST3_SDK_FOLDER}\" CACHE PATH \"VST3 SDK "
           "Folder\")\n"
        << "\n"
        << "\n";
  }

  // jucer_project_begin()
  {
    const auto projectSetting = [&jucerProject](
      const std::string& cmakeTag, const juce::Identifier& property)
    {
      if (jucerProject.hasProperty(property))
      {
        const auto value = jucerProject.getProperty(property).toString().toStdString();

        if (!value.empty())
        {
          return cmakeTag + " \"" + escape("\"", value) + "\"";
        }
      }

      return "# " + cmakeTag;
    };

    const auto projectType = jucerProject.getProperty("projectType").toString();
    const auto projectTypeDescription =
      projectType == "guiapp" ? "GUI Application"
                              : projectType == "consoleapp"
                                  ? "Console Application"
                                  : projectType == "library"
                                      ? "Static Library"
                                      : projectType == "audioplug" ? "Audio Plug-in" : "";

    const auto preprocessorDefinitions = makePreprocessorDefinitionsList(
      jucerProject.getProperty("defines").toString().toStdString());

    out << "jucer_project_begin(\n"
        << "  " << projectSetting("PROJECT_NAME", "name") << "\n"
        << "  " << projectSetting("PROJECT_VERSION", "version") << "\n"
        << "  " << projectSetting("COMPANY_NAME", "companyName") << "\n"
        << "  " << projectSetting("COMPANY_WEBSITE", "companyWebsite") << "\n"
        << "  " << projectSetting("COMPANY_EMAIL", "companyEmail") << "\n"
        << "  PROJECT_TYPE \"" << projectTypeDescription << "\"\n"
        << "  " << projectSetting("BUNDLE_IDENTIFIER", "bundleIdentifier") << "\n"
        << "  BINARYDATACPP_SIZE_LIMIT \"Default\"\n"
        << "  " << projectSetting("BINARYDATA_NAMESPACE", "binaryDataNamespace") << "\n"
        << "  " << (preprocessorDefinitions.empty()
                       ? "# PREPROCESSOR_DEFINITIONS"
                       : "PREPROCESSOR_DEFINITIONS \"" + preprocessorDefinitions + "\"")
        << "\n"
        << "  " << projectSetting("PROJECT_ID", "id") << "\n"
        << ")\n"
        << "\n";

    // jucer_audio_plugin_settings()
    if (projectType == "audioplug")
    {
      const auto onOffProjectSetting = [&jucerProject](
        const std::string& cmakeTag, const juce::Identifier& property)
      {
        if (jucerProject.hasProperty(property))
        {
          const auto value = int{jucerProject.getProperty(property)};

          return cmakeTag + " " + (value ? "ON" : "OFF");
        }

        return "# " + cmakeTag;
      };

      out << "jucer_audio_plugin_settings(\n"
          << "  " << onOffProjectSetting("BUILD_VST", "buildVST") << "\n"
          << "  " << onOffProjectSetting("BUILD_AUDIOUNIT", "buildAU") << "\n"
          << "  " << projectSetting("PLUGIN_NAME", "pluginName") << "\n"
          << "  " << projectSetting("PLUGIN_DESCRIPTION", "pluginDesc") << "\n"
          << "  " << projectSetting("PLUGIN_MANUFACTURER", "pluginManufacturer") << "\n"
          << "  " << projectSetting("PLUGIN_MANUFACTURER_CODE", "pluginManufacturerCode")
          << "\n"
          << "  " << projectSetting("PLUGIN_CODE", "pluginCode") << "\n"
          << "  "
          << projectSetting("PLUGIN_CHANNEL_CONFIGURATIONS", "pluginChannelConfigs")
          << "\n"
          << "  " << onOffProjectSetting("PLUGIN_IS_A_SYNTH", "pluginIsSynth") << "\n"
          << "  " << onOffProjectSetting("PLUGIN_MIDI_INPUT", "pluginWantsMidiIn") << "\n"
          << "  " << onOffProjectSetting("PLUGIN_MIDI_OUTPUT", "pluginProducesMidiOut")
          << "\n"
          << "  " << onOffProjectSetting("MIDI_EFFECT_PLUGIN", "pluginIsMidiEffectPlugin")
          << "\n"
          << "  " << onOffProjectSetting("KEY_FOCUS", "pluginEditorRequiresKeys") << "\n"
          << "  " << projectSetting("PLUGIN_AU_EXPORT_PREFIX", "pluginAUExportPrefix")
          << "\n"
          << "  " << projectSetting("PLUGIN_AU_MAIN_TYPE", "pluginAUMainType") << "\n"
          << "  " << projectSetting("VST_CATEGORY", "pluginVSTCategory") << "\n"
          << ")\n"
          << "\n";
    }
  }

  // jucer_project_files()
  {
    const auto writeFileGroups = [&out, &escapedJucerFileName](
      const std::string& fullGroupName,
      const std::vector<std::string>& filePaths,
      const std::vector<std::string>& doNotCompileFilePaths,
      const std::vector<std::string>& resourcePaths)
    {
      if (!filePaths.empty())
      {
        out << "jucer_project_files"
            << "(\"" << fullGroupName << "\"\n";

        for (const auto& filePath : filePaths)
        {
          out << "  \"${" << escapedJucerFileName << "_DIR"
              << "}/" << filePath << "\"\n";
        }

        if (!doNotCompileFilePaths.empty())
        {
          out << ")\n"
              << "set_source_files_properties(\n";

          for (const auto& doNotCompileFilePath : doNotCompileFilePaths)
          {
            out << "  \"${" << escapedJucerFileName << "_DIR"
                << "}/" << doNotCompileFilePath << "\"\n";
          }

          out << "  PROPERTIES HEADER_FILE_ONLY TRUE\n";
        }

        out << ")\n"
            << "\n";
      }

      if (!resourcePaths.empty())
      {
        out << "jucer_project_resources"
            << "(\"" << fullGroupName << "\"\n";

        for (const auto& resourcePath : resourcePaths)
        {
          out << "  \"${" << escapedJucerFileName << "_DIR"
              << "}/" << resourcePath << "\"\n";
        }

        out << ")\n"
            << "\n";
      }
    };

    std::vector<std::string> groupNames;

    std::function<void(const juce::ValueTree&)> processGroup =
      [&groupNames, &processGroup, &writeFileGroups](const juce::ValueTree& group)
    {
      groupNames.push_back(group.getProperty("name").toString().toStdString());

      const auto fullGroupName = join("/", groupNames);

      std::vector<std::string> filePaths, doNotCompileFilePaths, resourcePaths;

      for (const auto& fileOrGroup : group)
      {
        if (fileOrGroup.hasType("FILE"))
        {
          const auto& file = fileOrGroup;
          const auto path = file.getProperty("file").toString().toStdString();

          if (int{file.getProperty("resource")} == 1)
          {
            resourcePaths.push_back(path);
          }
          else
          {
            filePaths.push_back(path);

            if (juce::File::createFileWithoutCheckingPath(path).hasFileExtension("cpp") &&
                int{file.getProperty("compile")} == 0)
            {
              doNotCompileFilePaths.push_back(path);
            }
          }
        }
        else
        {
          writeFileGroups(fullGroupName, filePaths, doNotCompileFilePaths, resourcePaths);
          filePaths.clear();
          doNotCompileFilePaths.clear();
          resourcePaths.clear();

          processGroup(fileOrGroup);
        }
      }

      writeFileGroups(fullGroupName, filePaths, doNotCompileFilePaths, resourcePaths);

      groupNames.pop_back();
    };

    processGroup(jucerProject.getChildWithName("MAINGROUP"));
  }

  // jucer_project_module()
  {
    std::vector<std::string> moduleNames;
    for (const auto& module : jucerProject.getChildWithName("MODULES"))
    {
      moduleNames.push_back(module.getProperty("id").toString().toStdString());
    }

    const auto modulePaths = jucerProject.getChildWithName("EXPORTFORMATS")
                               .getChild(0)
                               .getChildWithName("MODULEPATHS");

    for (const auto& moduleName : moduleNames)
    {
      const auto relativeModulePath =
        modulePaths.getChildWithProperty("id", juce::String{moduleName})
          .getProperty("path")
          .toString();

      out << "jucer_project_module(\n"
          << "  " << moduleName << "\n"
          << "  PATH \"${" << escapedJucerFileName << "_DIR"
          << "}/" << relativeModulePath << "\"\n";

      const auto moduleHeader = juce::File{jucerFilePath}
                                  .getParentDirectory()
                                  .getChildFile(relativeModulePath)
                                  .getChildFile(juce::String{moduleName})
                                  .getChildFile(juce::String{moduleName + ".h"});
      juce::StringArray moduleHeaderLines;
      moduleHeader.readLines(moduleHeaderLines);

      const auto modulesOptions = jucerProject.getChildWithName("JUCEOPTIONS");

      for (const auto& line : moduleHeaderLines)
      {
        if (line.startsWith("/** Config: "))
        {
          const auto moduleOption = line.substring(12);
          const auto optionValue = modulesOptions.getProperty(moduleOption);

          if (optionValue == "enabled")
          {
            out << "  " << moduleOption << " ON\n";
          }
          else if (optionValue == "disabled")
          {
            out << "  " << moduleOption << " OFF\n";
          }
          else
          {
            out << "  # " << moduleOption << "\n";
          }
        }
      }

      out << ")\n"
          << "\n";
    }
  }

  // jucer_export_target() and jucer_export_target_configuration()
  {
    const std::vector<std::pair<const char*, const char*>> supportedExporters = {
      {"XCODE_MAC", "Xcode (MacOSX)"},
      {"VS2015", "Visual Studio 2015"},
      {"VS2013", "Visual Studio 2013"}};

    for (const auto& element : supportedExporters)
    {
      const auto exporter = jucerProject.getChildWithName("EXPORTFORMATS")
                              .getChildWithName(std::get<0>(element));
      if (exporter.isValid())
      {
        out << "jucer_export_target(\n"
            << "  \"" << std::get<1>(element) << "\"\n"
            << ")\n"
            << "\n";

        for (const auto& configuration : exporter.getChildWithName("CONFIGURATIONS"))
        {
          out << "jucer_export_target_configuration(\n"
              << "  \"" << std::get<1>(element) << "\"\n"
              << "  NAME \"" << configuration.getProperty("name").toString() << "\"\n"
              << ")\n"
              << "\n";
        }
      }
    }
  }

  out << "jucer_project_end()" << std::endl;

  return 0;
}
