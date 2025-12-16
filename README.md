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

## Updating Your Plugin

To import the changes made to the _pluginsGLPI empty_ template into your project,
we recommend using [_template-sync_](https://github.com/coopTilleuls/template-sync):

1. Run the script to synchronize your project with the latest version of the skeleton:

   ```console
   curl -sSL https://raw.githubusercontent.com/coopTilleuls/template-sync/main/template-sync.sh | sh -s -- https://github.com/pluginsGLPI/empty
   ```

2. Resolve conflicts, if any
3. Run `git cherry-pick --continue`

For more advanced options, refer to [the documentation of _template sync_](https://github.com/coopTilleuls/template-sync#template-sync).
