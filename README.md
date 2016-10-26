# Empty GLPi plugin

An empty plugin, to get started!

This is basically a plugin skeleton with last minimal good practice to help you starting a new plugin (or even update/check an existing one!).

## Getting started

You can use provided `plugin.sh` script in the main directory to get started. You'll have to pass name and version of your plugin in the call:
```
./plugin.sh MyGreatPlugin 0.0.1
```

This will create a directory named `mygreatplugin` at the same level than the `empty` directory that contains the plugin;
all methods will be named accordingly (see result in `hook.php` and `setup.php`).
