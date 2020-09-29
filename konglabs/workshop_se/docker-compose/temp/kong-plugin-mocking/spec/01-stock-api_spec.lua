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
          path = "specs/stock.json",
          contents = read_fixture("stock.json"),  
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
          api_specification_filename = "stock.json",
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

    describe("Stock API Specification tests", function()
      it("/stock/historical happy path", function()
        local r = assert(client:send {
          method = "GET",
          path = "/stock/historical",
          headers = {
            host = "mocking.com"
          }
        })
        -- validate that the request succeeded, response status 200
        local body = cjson.decode(assert.res_status(200, r))
        -- Compare meta data values against values from spec
        assert.equal("historical_stock_price_v2",find_key(body,"api_name"))
        assert.equal(10,find_key(body,"credit_cost"))
        assert.equal("yesterday",find_key(body,"end_date"))

        -- Compare result data values against values from spec
        assert.equal(275.03, find_key(body.result_data,"adj_close"))
        assert.equal(100.03, find_key(body.result_data,"close"))
        assert.equal(100.75, find_key(body.result_data,"high"))
        assert.equal(100.87, find_key(body.result_data,"low"))
        assert.equal(100.87, find_key(body.result_data,"open"))
      end)
    end)

    describe("Stock API Specification tests", function()
      it("/stock/closing happy path", function()
        local r = assert(client:send {
          method = "GET",
          path = "/stock/closing",
          headers = {
            host = "mocking.com"
          }
        })
        -- validate that the request succeeded, response status 200
        local body = cjson.decode(assert.res_status(200, r))
        -- Compare meta data values against values from spec
        assert.equal("closing_stock_price_v1",find_key(body,"api_name"))
        
        -- Compare result data values against values from spec
        assert.equal(275.03, find_key(body.result_data,"adj_close"))
        assert.equal(100.03, find_key(body.result_data,"close"))
        assert.equal(100.75, find_key(body.result_data,"high"))
        assert.equal(100.87, find_key(body.result_data,"low"))
        assert.equal(100.87, find_key(body.result_data,"open"))
      end)
    end)

    describe("Stock API Specification tests", function()
      it("/stock/historical happy path", function()
        local r = assert(client:send {
          method = "GET",
          path = "/stock/historical",
          headers = {
            host = "mocking.com"
          }
        })
        local header_value = assert.response(r).has.header("X-Kong-Mocking-Plugin")
        -- validate the value of that header
        assert.equal("true", header_value)
      end)
    end)
    
    describe("Stock API Specification tests", function()
      it("/random_path Random path", function()
        local r = assert(client:send {
          method = "GET",
          path = "/random_path",
          headers = {
            host = "mocking.com"
          }
        })
        -- Random path, Response status - 404
        local body = assert.res_status(404, r)
        local json = cjson.decode(body)
        assert.same("Path does not exist in API Specification", json.message)
      end)
    end)

  end)
end
