-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "eDP-1",
	mode = "1920x1080@60",
	position = "0x0",
	scale = 1,
	reserved_area = {
		top = 32, -- 给 waybar（常见高度 28~36）
		bottom = 0,
		left = 0,
		right = 0,
	},
})

---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use

-------------------
---- AUTOSTART ----
------------------- -- See https://wiki.hypr.land/Configuring/Basics/Autostart/ -- Autostart necessary processes (like notifications daemons, status bars, etc.) Or execute your favorite apps at launch like this:
---hl.on("hyprland.start", function ()
---hl.exec_cmd(terminal) hl.exec_cmd("nm-applet")
---hl.exec_cmd("waybar & hyprpaper & firefox") end)
---------------------------------- - ENVIRONMENT VARIABLES ---- ---------------------------- -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
----------------------- -- PERMISSIONS ----- -------------------- -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/ Please note permission changes here require a Hyprland restart and are not applied on-the-fly for security reasons --
---hl.config({ ecosystem = { enforce_permissions = true, }, })
---hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
---hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
---hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

----------------------- - LOOK AND FEEL ---- -------------------- -- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
---hl.config({
---  general = {
---    gaps_in = 5,
---    gaps_out = 20,
---    border_size = 2,
---    col = {
---      active_border = {
---         colors = {
---           "rgba(33ccffee)",
---           "rgba(00ff99ee)" },
---           angle = 45 },
---           inactive_border = "rgba(595959aa)", }, -- Set to true to enable resizing windows by clicking and dragging on borders and gaps resize_on_border = false, -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on allow_tearing = false, layout = "dwindle", }, decoration = { rounding = 10, rounding_power = 4, -- Change transparency of focused and unfocused windows active_opacity = 1.0, inactive_opacity = 0.92, dim_inactive = false, dim_strength = 0.2, dim_modal = true, shadow = { enabled = true, range = 4, render_power = 3, color = 0xee1a1a1a, }, blur = { enabled = true, size = 6, passes = 2, vibrancy = 0.1696, new_optimizations = true, xray = true, popups = true, }, }, animations = { enabled = true, }, }) require("conf.animations") -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more hl.config({ dwindle = { preserve_split = true, -- You probably want this }, }) -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more hl.config({ master = { new_status = "master", }, }) -- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more hl.config({ scrolling = { fullscreen_on_one_column = true, }, }) require("conf.misc") --------------- - INPUT ---- ------------ hl.config({ input = { kb_layout = "us", kb_variant = "", kb_model = "", kb_options = "", kb_rules = "", follow_mouse = 1, sensitivity = 0, -- -1.0 - 1.0, 0 means no modification. focus_on_close = 2, mouse_refocus = true,
hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

		touchpad = {
			natural_scroll = false,
		},
	},
})
require("conf.keymapping")
require("conf.windowsrule")
require("conf.decorations.default")
local status, value = pcall(require, "maybe-nonexistent")
if status then
	print("successfully loaded module, it returned:", value)
else
	print("failed to load module, its error message was:", value)
end
