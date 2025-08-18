PLUGIN_DIR = {LNAME}

# These two options will change the behavior of the `make vendor` command.
USE_COMPOSER = true
USE_NPM = false

# These options will change the behavior of several lint/static analysis commands.
# By default, you do not need to change anything as these binaries are provided by
# GLPI's core.
# You only need to set it to true if your plugin load its own binary
# in its vendor directory for one of these tools.
USE_LOCAL_PHPUNIT_BIN = false
USE_LOCAL_PHPSTAN_BIN = false
USE_LOCAL_PSALM_BIN = false
USE_LOCAL_RECTOR_BIN = false
USE_LOCAL_PHPCSFIXER_BIN = false

include ../../PluginsMakefile.mk
