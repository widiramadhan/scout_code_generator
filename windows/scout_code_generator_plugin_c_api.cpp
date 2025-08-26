#include "include/scout_code_generator/scout_code_generator_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "scout_code_generator_plugin.h"

void ScoutCodeGeneratorPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  scout_code_generator::ScoutCodeGeneratorPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
