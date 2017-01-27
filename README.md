# Empty GLPI plugin

An empty plugin, to get started!

This is basically a plugin skeleton with last minimal good practice to help you starting a new plugin (or even update/check an existing one!).

## Getting started

For convenience, you can place the `empty` directory in you GLPI plugins directory.

You can use provided `plugin.sh` script in the main directory to get started. You'll have to pass name and version of your plugin in the call:
```
./plugin.sh MyGreatPlugin 0.0.1
```

Please note than you really want to avoid special characters in name; as it will be used for paths, methods names, constants, and so on.

This will create a directory named `mygreatplugin` at the same level than the `empty` directory that contains the plugin;
all methods will be named accordingly (see result in `hook.php` and `setup.php`). Note that `My-Great-Plugin` would also create a directory named `mygreatplugin`.

You can also provide a destination path (ie. if your `empty` directory is not in the GLPI's plugins directory):
```
./plugin.sh MyGreatPlugin 0.0.1 /path/to/glpi/plugins/
```

### Replacements

* `{NAME}` will be replaced by the name you've provide, verbatim,
* `{VERSION}` will be replaced byt the version you've provided,
* `{LNAME}` will be replaced byt the lowercased name,
* `{UNAME}` will be replaced by the uppercased name,
* `{YEAR}` will be replaced by the current year.
