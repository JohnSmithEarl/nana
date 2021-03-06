local common = require('lib.common')

local _M = {}
local controller_prefix = 'controllers.'
local middleware_prefix = 'middlewares.'
local middleware_group = {}

local function call_action(uri, controller, action)
    if common:remove_slash(uri) == common:remove_slash(ngx.var.request_uri) then
        if middleware_group then
            for _,middleware in ipairs(middleware_group) do
                common:log('use middleware: '..middleware)
                require(middleware_prefix..middleware):handle()
            end
        end
        require(controller_prefix..controller)[action]()
    end
end

function _M:get(uri, controller, action)
    if 'GET' == ngx.var.request_method then
        call_action(uri, controller, action)
    end
end

function _M:post(uri, controller, action)
    if 'POST' == ngx.var.request_method then
        call_action(uri, controller, action)
    end
end

function _M:group(middlewares, func)
    for _,middleware in ipairs(middlewares) do
        table.insert(middleware_group, middleware)
    end
    func()
end

return _M