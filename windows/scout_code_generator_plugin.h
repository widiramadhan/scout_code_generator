#ifndef FLUTTER_PLUGIN_SCOUT_CODE_GENERATOR_PLUGIN_H_
#define FLUTTER_PLUGIN_SCOUT_CODE_GENERATOR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace scout_code_generator {

class ScoutCodeGeneratorPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ScoutCodeGeneratorPlugin();

  virtual ~ScoutCodeGeneratorPlugin();

  // Disallow copy and assign.
  ScoutCodeGeneratorPlugin(const ScoutCodeGeneratorPlugin&) = delete;
  ScoutCodeGeneratorPlugin& operator=(const ScoutCodeGeneratorPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace scout_code_generator

#endif  // FLUTTER_PLUGIN_SCOUT_CODE_GENERATOR_PLUGIN_H_
