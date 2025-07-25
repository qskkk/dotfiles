{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Karabiner-Elements configuration
  home.file.".config/karabiner/karabiner.json" = {
    force = true; # Force overwrite to avoid backup conflicts
    text = builtins.toJSON {
      global = {
        check_for_updates_on_startup = true;
        show_in_menu_bar = true;
        show_profile_name_in_menu_bar = false;
      };

      profiles = [
        {
          name = "Default profile";
          selected = true;

          # Complex modifications
          complex_modifications = {
            parameters = {
              basic = {
                simultaneous_threshold_milliseconds = 50;
                to_delayed_action_delay_milliseconds = 500;
                to_if_alone_timeout_milliseconds = 1000;
                to_if_held_down_threshold_milliseconds = 500;
              };
            };

            rules = [
              {
                # Transform Caps Lock to Hyper key
                description = "Change caps_lock to command+control+shift+option (Hyper)";
                manipulators = [
                  {
                    type = "basic";
                    from = {
                      key_code = "caps_lock";
                      modifiers = {
                        optional = [ "any" ];
                      };
                    };
                    to = [
                      {
                        key_code = "left_command";
                        modifiers = [
                          "left_control"
                          "left_shift"
                          "left_option"
                        ];
                      }
                    ];
                    to_if_alone = [
                      {
                        key_code = "escape";
                      }
                    ];
                  }
                ];
              }
              {
                # Optional: Add some useful Hyper key combinations
                description = "Hyper key shortcuts";
                manipulators = [
                  # Hyper + H -> Left arrow
                  {
                    type = "basic";
                    from = {
                      key_code = "h";
                      modifiers = {
                        mandatory = [
                          "command"
                          "control"
                          "shift"
                          "option"
                        ];
                      };
                    };
                    to = [
                      {
                        key_code = "left_arrow";
                      }
                    ];
                  }
                  # Hyper + J -> Down arrow
                  {
                    type = "basic";
                    from = {
                      key_code = "j";
                      modifiers = {
                        mandatory = [
                          "command"
                          "control"
                          "shift"
                          "option"
                        ];
                      };
                    };
                    to = [
                      {
                        key_code = "down_arrow";
                      }
                    ];
                  }
                  # Hyper + K -> Up arrow
                  {
                    type = "basic";
                    from = {
                      key_code = "k";
                      modifiers = {
                        mandatory = [
                          "command"
                          "control"
                          "shift"
                          "option"
                        ];
                      };
                    };
                    to = [
                      {
                        key_code = "up_arrow";
                      }
                    ];
                  }
                  # Hyper + L -> Right arrow
                  {
                    type = "basic";
                    from = {
                      key_code = "l";
                      modifiers = {
                        mandatory = [
                          "command"
                          "control"
                          "shift"
                          "option"
                        ];
                      };
                    };
                    to = [
                      {
                        key_code = "right_arrow";
                      }
                    ];
                  }
                  # Hyper + R -> Execute nbuild script
                  {
                    type = "basic";
                    from = {
                      key_code = "r";
                      modifiers = {
                        mandatory = [
                          "command"
                          "control"
                          "shift"
                          "option"
                        ];
                      };
                    };
                    to = [
                      {
                        shell_command = "osascript -e 'tell application \"Terminal\" to do script \"$HOME/.scripts/nbuild.sh\"'";
                      }
                    ];
                  }
                  {
                    type = "basic";
                    from = {
                      key_code = "y";
                      modifiers = {
                        mandatory = [
                          "command"
                          "control"
                          "shift"
                          "option"
                        ];
                      };
                    };
                    to = [
                      {
                        shell_command = "osascript -e 'tell application \"AeroSpace\" to quit' && osascript -e 'display notification \"Reload aerospace completed successfully!\" with title \"AeroSpace\"'";
                      }
                    ];
                  }
                ];
              }
            ];
          };

          # Simple modifications (if needed)
          simple_modifications = [ ];

          # Virtual HID keyboard settings
          virtual_hid_keyboard = {
            country_code = 0;
            keyboard_type_v2 = "ansi";
            indicate_sticky_modifier_keys_state = true;
            mouse_key_xy_scale = 100;
          };

          # Device settings
          devices = [ ];

          # Function keys
          fn_function_keys = [
            {
              from = {
                key_code = "f1";
              };
              to = [
                {
                  consumer_key_code = "display_brightness_decrement";
                }
              ];
            }
            {
              from = {
                key_code = "f2";
              };
              to = [
                {
                  consumer_key_code = "display_brightness_increment";
                }
              ];
            }
            {
              from = {
                key_code = "f3";
              };
              to = [
                {
                  apple_vendor_keyboard_key_code = "mission_control";
                }
              ];
            }
            {
              from = {
                key_code = "f4";
              };
              to = [
                {
                  apple_vendor_keyboard_key_code = "spotlight";
                }
              ];
            }
            {
              from = {
                key_code = "f5";
              };
              to = [
                {
                  consumer_key_code = "dictation";
                }
              ];
            }
            {
              from = {
                key_code = "f6";
              };
              to = [
                {
                  key_code = "f6";
                }
              ];
            }
            {
              from = {
                key_code = "f7";
              };
              to = [
                {
                  consumer_key_code = "rewind";
                }
              ];
            }
            {
              from = {
                key_code = "f8";
              };
              to = [
                {
                  consumer_key_code = "play_or_pause";
                }
              ];
            }
            {
              from = {
                key_code = "f9";
              };
              to = [
                {
                  consumer_key_code = "fast_forward";
                }
              ];
            }
            {
              from = {
                key_code = "f10";
              };
              to = [
                {
                  consumer_key_code = "mute";
                }
              ];
            }
            {
              from = {
                key_code = "f11";
              };
              to = [
                {
                  consumer_key_code = "volume_decrement";
                }
              ];
            }
            {
              from = {
                key_code = "f12";
              };
              to = [
                {
                  consumer_key_code = "volume_increment";
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
