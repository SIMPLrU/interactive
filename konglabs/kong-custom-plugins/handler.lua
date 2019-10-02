local MyPluginHandler = {}

MyPluginHandler.PRIORITY = 1000
MyPluginHandler.VERSION = "0.1.0"

function MyPluginHandler:access(conf)
  local server = kong.response.get_header("Server")
  kong.response.add_header("X-My-Plugin", conf.message .. ", " .. server)
end

return MyPluginHandler