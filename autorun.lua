run_once("xscreensaver", "-no-splash")         -- starts screensaver daemon 
run_once("xsetroot", "-cursor_name left_ptr")  -- sets the cursor icon
run_once(os.getenv("HOME") .. "/bin/emacs_script.sh", "start")
run_once("/usr/bin/pidgin")
run_once(os.getenv("HOME") .. "/.dropbox-dist/dropboxd") -- dropbox