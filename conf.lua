function love.conf(t)
	--t.identity = "ls-hueshift"
	t.version = "0.9.1"
	t.console = false

	t.window.title = "Hue Shift"
	t.window.icon = "graphics/icon.png"
	t.window.width = 600
	t.window.height = 600
	t.window.borderless = false
	t.window.resizable = false
	t.window.minwidth = 300
	t.window.minheight = 300
	t.window.fullscreen = false
	t.window.fullscreentype = "normal"
	t.window.vsync = true
	t.window.fsaa = 0
	t.window.display = 1
	t.window.highdpi = false
	t.window.srgb = false

	t.modules.audio = true
	t.modules.event = true
	t.modules.graphics = true
	t.modules.image = true
	t.modules.joystick = false
	t.modules.keyboard = true
	t.modules.math = true
	t.modules.mouse = true
	t.modules.physics = false
	t.modules.sound = true
	t.modules.system = true
	t.modules.timer = true
	t.modules.window = true
	t.modules.thread = true
end
