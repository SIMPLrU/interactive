local helpers   = require "spec.helpers"
local pl_path   = require "pl.path"
local cjson     = require("cjson.safe").new()


local PLUGIN_NAME = "mocking"

local fixture_path do
  -- this code will get debug info and from that determine the file
  -- location, so fixtures can be found based of this path
  local info = debug.getinfo(function() end)
  fixture_path = info.source
  if fixture_path:sub(1,1) == "@" then
    fixture_path = fixture_path:sub(2, -1)
  end
  fixture_path = pl_path.splitpath(fixture_path) .. "/resources/"
end


local function read_fixture(filename)
  local content  = assert(helpers.utils.readfile(fixture_path .. filename))
  return content
end

local function find_key(tbl, key)
  for lk, lv in pairs(tbl) do
    if lk == key then return lv end
    if type(lv) == "table" then
      for dk, dv in pairs(lv) do
        if dk == key then return dv end
        if type(dv) == "table" then
          for ek, ev in pairs(dv) do
            if ek == key then return ev end
          end
        end
      end
    end
  end
  return nil
end

for _, strategy in helpers.each_strategy() do
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

      lazy_setup(function()
        local bp, db = helpers.get_db_utils(strategy, {
          "routes",
          "services",
          "files",
        }, { PLUGIN_NAME })

        assert(db.files:insert {
          path = "specs/users.yaml",
          contents = read_fixture("users.yaml"),  
        })
        
        local service1 = bp.services:insert{
          protocol = "http",
          port     = 80,
          host     = "mocking.com",
        }
        
      local route1 = db.routes:insert({
        hosts = { "mocking.com" },
        service    = service1,

      })

      -- add the plugin to test to the route we created
      db.plugins:insert {
        name = PLUGIN_NAME,
        service = { id = service1.id },
        config = {
          api_specification_filename = "users.yaml",
          random_delay = false
        },
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("YAML format API Specification tests", function()
      it("Check with Path Variable", function()
        local r = assert(client:send {
          method = "GET",
          path = "/users/123",  
          headers = {
            host = "mocking.com"
          }
        })
        -- validate that the request succeeded, response status 200
        local body = cjson.decode(assert.res_status(200, r))
        -- verify the values from the response
        assert.equal("jdoe",find_key(body,"sub"))
        assert.equal("Jane Doe",find_key(body,"name"))
        assert.equal("Jane",find_key(body,"given_name"))
        assert.equal("Doe",find_key(body,"family_name"))
        assert.equal("janedoe@example.com",find_key(body,"email"))
      end)
    end)

    describe("YAML format API Specification tests", function()
      it("Check for X-Kong-Mocking-Plugin header", function()
        local r = assert(client:send {
          method = "GET",
          path = "/pet/findByStatus/MultipleExamples",  
          headers = {
            host = "mocking.com"
          }
        })
        
        local header_value = assert.response(r).has.header("X-Kong-Mocking-Plugin")
        
        assert.equal("true", header_value)
      end)
    end)
  
  end)
end
