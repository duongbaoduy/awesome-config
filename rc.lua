-- {{{ Libraries
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")
-- load from git
require("vicious") -- ./vicious
require("helpers") -- helpers.lua
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
beautiful.init(awful.util.getdir("config") .."/themes/zhongguo/mytheme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
altkey = "Mod1"
modkey = "Mod4"

-- {{{ Default configuration
wallpaper_app = "feh" -- if you want to check for app before trying
wallpaper_dir = os.getenv("HOME") .. "/Pictures/Wallpaper" -- wallpaper dir

-- taglist numerals
--- arabic, chinese, {east|persian}_arabic, roman, thai, random
taglist_numbers = "chinese" -- we support arabic (1,2,3...),

cpugraph_enable = true -- Show CPU graph
cputext_format = " $1%" -- %1 average cpu, %[2..] every other thread individually

membar_enable = true -- Show memory bar
memtext_format = " $1%" -- %1 percentage, %2 used %3 total %4 free

date_format = "%a %m/%d/%Y %l:%M%p" -- refer to http://en.wikipedia.org/wiki/Date_(Unix) specifiers

networks = {'eth0'} -- add your devices network interface here netwidget, only shows first one thats up.

require_safe('personal')

-- Create personal.lua in this same directory to override these defaults

-- local wallpaper_cmd = "find " .. wallpaper_dir .. " -type f -name '*.jpg'  -print0 | shuf -n1 -z | xargs -0 feh --bg-max"
local wallpaper_cmd = "find " .. wallpaper_dir .. " -type f -name '*.jpg'  -print0 | shuf -n1 -z | xargs -0 awsetbg"
local home   = os.getenv("HOME")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell

-- }}}


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Taglist numerals
taglist_numbers_langs = { 'arabic', 'chinese', 'east_arabic', 'persian_arabic', }
taglist_numbers_sets = {
        arabic={ 1, 2, 3, 4, 5, 6, 7, 8, 9 },
        chinese={"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"},
        east_arabic={'١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'}, -- '٠' 0
        persian_arabic={'٠', '١', '٢', '٣', '۴', '۵', '۶', '٧', '٨', '٩'},
        roman={'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'},
        thai={'๑', '๒', '๓', '๔', '๕', '๖', '๗', '๘', '๙', '๑๐'},
}
-- }}}

-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    if taglist_numbers == 'random' then
        math.randomseed(os.time())
        local taglist = taglist_numbers_sets[taglist_numbers_langs[math.random(table.getn(taglist_numbers_langs))]]
        tags[s] = awful.tag(taglist, s, layouts[1])
    else
        tags[s] = awful.tag(taglist_numbers_sets[taglist_numbers], s, layouts[1])
    end
    -- tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}
-- {{ My customize
-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)

spacer = widget({ type = "textbox" })
spacer.width = 3
-- }}}

-- {{{ CPU usage

-- cpu icon
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)

-- check for cpugraph_enable == true in config
if cpugraph_enable then
	-- Initialize widget
	cpugraph  = awful.widget.graph()

	-- Graph properties
	cpugraph:set_width(40):set_height(16)
	cpugraph:set_background_color(beautiful.fg_off_widget)
	cpugraph:set_gradient_angle(0):set_gradient_colors({
	   beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
	})

	-- Register graph widget
	vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
end

-- cpu text widget
cpuwidget = widget({ type = "textbox" }) -- initialize
vicious.register(cpuwidget, vicious.widgets.cpu, cputext_format, 3) -- register

-- temperature
tzswidget = widget({ type = "textbox" })
vicious.register(tzswidget, vicious.widgets.thermal,
	function (widget, args)
		if args[1] > 0 then
			tzfound = true
			return " " .. args[1] .. "C°"
		else return "" 
		end
	end
	, 19, "thermal_zone0")

-- }}}


-- {{{ Battery state

-- Brightness

awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 15") end)
awful.key({ }, "XF86MonBrightnessUp", function () awful.util.spawn("xbacklight -inc 15") end)

-- Initialize widget
batwidget = widget({ type = "textbox" })
baticon = widget({ type = "imagebox" })

-- Register widget
vicious.register(batwidget, vicious.widgets.bat,
	function (widget, args)
		if args[2] == 0 then return ""
		else
			baticon.image = image(beautiful.widget_bat)
			return "<span color='white'>".. args[2] .. "%</span>"
		end
	end, 61, "BAT0"
)
-- }}}


-- {{{ Memory usage

-- icon
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)

if membar_enable then
	-- Initialize widget
	membar = awful.widget.progressbar()
	-- Pogressbar properties
	membar:set_vertical(true):set_ticks(true)
	membar:set_height(16):set_width(8):set_ticks_size(2)
	membar:set_background_color(beautiful.fg_off_widget)
	membar:set_gradient_colors({ beautiful.fg_widget,
	   beautiful.fg_center_widget, beautiful.fg_end_widget
	}) -- Register widget
	vicious.register(membar, vicious.widgets.mem, "$1", 13)
end

-- mem text output
memtext = widget({ type = "textbox" })
vicious.register(memtext, vicious.widgets.mem, memtext_format, 13)
-- }}}

-- {{{ File system usage
fsicon = widget({ type = "imagebox" })
fsicon.image = image(beautiful.widget_fs)
-- Initialize widgets
fs = {
  r = awful.widget.progressbar(), s = awful.widget.progressbar()
}
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_vertical(true):set_ticks(true)
  w:set_height(16):set_width(5):set_ticks_size(2)
  w:set_border_color(beautiful.border_widget)
  w:set_background_color(beautiful.fg_off_widget)
  w:set_gradient_colors({ beautiful.fg_widget,
     beautiful.fg_center_widget, beautiful.fg_end_widget
  }) -- Register buttons
  w.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () exec("dolphin", false) end)
  ))
end 
-- Enable caching
vicious.cache(vicious.widgets.fs)
-- Register widgets
vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",            599)
vicious.register(fs.s, vicious.widgets.fs, "${/media/files used_p}", 599)
-- }}}

-- {{{ Network usage
function print_net(name, down, up)
	return '<span color="'
	.. beautiful.fg_netdn_widget ..'">' .. down .. '</span> <span color="'
	.. beautiful.fg_netup_widget ..'">' .. up  .. '</span>'
end

dnicon = widget({ type = "imagebox" })
upicon = widget({ type = "imagebox" })

-- Initialize widget
netwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(netwidget, vicious.widgets.net,
	function (widget, args)
		for _,device in pairs(networks) do
			if tonumber(args["{".. device .." carrier}"]) > 0 then
				netwidget.found = true
				dnicon.image = image(beautiful.widget_net)
				upicon.image = image(beautiful.widget_netup)
				return print_net(device, args["{"..device .." down_kb}"], args["{"..device.." up_kb}"])
			end
		end
	end, 3)
-- }}}



-- {{{ Volume level
volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = widget({ type = "textbox" })
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(16):set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Enable caching
vicious.cache(vicious.widgets.volume)
-- Register widgets
vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "PCM")
vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "PCM")
-- Register buttons
volbar.widget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("kmix") end),
   awful.button({ }, 4, function () exec("amixer -q set PCM 2dB+", false) vicious.force({volbar, volwidget}) end),
   awful.button({ }, 5, function () exec("amixer -q set PCM 2dB-", false) vicious.force({volbar, volwidget}) end)
)) -- Register assigned buttons
volwidget:buttons(volbar.widget:buttons())
-- }}}
--}} end my customize

-- {{{ Wibox
-- Create a textclock widget
-- mytextclock = awful.widget.textclock({ align = "right" })
-- {{{ Date and time
mytextclock = widget({ type = "imagebox" })
mytextclock.image = image(beautiful.widget_date)
-- Initialize widget
mytextclock = widget({ type = "textbox" })
-- Register widget
vicious.register(mytextclock, vicious.widgets.date, date_format, 1)
-- }}}

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        baticon.image and separator, batwidget, baticon or nil,
        separator, volwidget,  volbar.widget, volicon,
        dnicon.image and separator, upicon, netwidget, dnicon or nil,
        separator, fs.r.widget, fs.s.widget, fsicon,
        separator, memtext, membar_enable and membar.widget or nil, memicon,
        separator, tzfound and tzswidget or nil,
        cpugraph_enable and cpugraph.widget or nil, cpuwidget, cpuicon,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

x = 0
-- setup the timer
mytimer = timer { timeout = x }
mytimer:add_signal("timeout", function()

  -- tell awsetbg to randomly choose a wallpaper from your wallpaper directory
  if file_exists(wallpaper_dir) and whereis_app('feh') then
	  os.execute(wallpaper_cmd)
  end
  -- stop the timer (we don't need multiple instances running at the same time)
  mytimer:stop()

  -- define the interval in which the next wallpaper change should occur in seconds
  -- (in this case anytime between 10 and 20 minutes)
  x = math.random( 600, 1200)

  --restart the timer
  mytimer.timeout = x
  mytimer:start()
end)

-- initial start when rc.lua is first run
mytimer:start()
require_safe('autorun')