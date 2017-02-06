<?php
/**
 * This is project's console commands configuration for Robo task runner.
 *
 * @see http://robo.li/
 */

require_once 'RoboFilePlugin.php';

class RoboFile extends RoboFilePlugin
{
   protected $csfiles = ['./', 'setup.php.tpl', 'hook.php.tpl'];
   //Own plugin's robo stuff
}
