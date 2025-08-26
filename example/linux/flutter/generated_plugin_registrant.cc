//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <scout_code_generator/scout_code_generator_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) scout_code_generator_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ScoutCodeGeneratorPlugin");
  scout_code_generator_plugin_register_with_registrar(scout_code_generator_registrar);
}
