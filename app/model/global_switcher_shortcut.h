#import "controller/WindowController.h"
#import <ShortcutRecorder/ShortcutRecorder.h>

struct shortcut_info_t;

class global_switcher_shortcut {
public:
    shortcut_info_t* sh;
    WindowController* windowController;

    global_switcher_shortcut(SRShortcut* shortcut, WindowController* windowController);
    ~global_switcher_shortcut();
    void register_hotkey();
    void add_global_handler();
    void register_for_getting_hotkey_events();
    void unregister_for_getting_hotkey_events();
    void set_command_tab_enabled(bool is_enabled);
};
