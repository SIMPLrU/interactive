local BasePlugin = require "kong.plugins.base_plugin"
local cjson = require "cjson"


local kong = kong
local req = ngx.req
local exit = ngx.exit
local error = error


local ShortCircuitHandler = BasePlugin:extend()


ShortCircuitHandler.PRIORITY = math.huge


function ShortCircuitHandler:new()
  ShortCircuitHandler.super.new(self, "short-circuit")
end


function ShortCircuitHandler:access(conf)
  ShortCircuitHandler.super.access(self)
  return kong.response.exit(conf.status, {
    status  = conf.status,
    message = conf.message
  })
end


function ShortCircuitHandler:preread(conf)
  ShortCircuitHandler.super.preread(self)

  local tcpsock, err = req.socket(true)
  if err then
    error(err)
  end

  tcpsock:send(cjson.encode({
    status  = conf.status,
    message = conf.message
  }))

  -- TODO: this should really support delayed short-circuiting!
  return exit(conf.status)
end


return ShortCircuitHandler
