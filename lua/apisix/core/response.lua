-- Copyright (C) Yuansheng Wang

local ngx = ngx
local ngx_say = ngx.say
local ngx_header = ngx.header
local encode_json = require("cjson.safe").encode
local error = error
local select = select
local type = type
local ngx_exit = ngx.exit
local insert_tab = table.insert
local concat_tab = table.concat


local _M = {version = 0.1}


local resp_exit
do
    local t = {}
    local idx = 1

function resp_exit(code, ...)
    idx = 0

    if type(code) ~= "number" then
        insert_tab(t, code)
        code = nil
    end

    if code then
        ngx.status = code
    end

    for i = 1, select('#', ...) do
        local v = select(i, ...)
        if type(v) == "table" then
            local body, err = encode_json(v)
            if err then
                error("failed to encode data: " .. err, -2)
            else
                idx = idx + 1
                insert_tab(t, idx, body)
            end

        else
            idx = idx + 1
            insert_tab(t, idx, v)
        end
    end

    if idx > 0 then
        ngx_say(concat_tab(t, "", 1, idx))
    end

    if code then
        ngx_exit(code)
    end
end

end -- do
_M.exit = resp_exit


function _M.say(...)
    resp_exit(nil, ...)
end


function _M.set_header(name, value)
    if ngx.headers_sent then
      error("headers have already been sent", 2)
    end

    ngx_header[name] = value
end


return _M
