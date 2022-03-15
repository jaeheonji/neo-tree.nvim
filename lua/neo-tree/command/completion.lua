local parser = require("neo-tree.command.parser")
local utils   = require("neo-tree.utils")

local M = {
  show_key_value_completions = false,
}

local get_path_completions = function(key_prefix, base_path)
  key_prefix = key_prefix or ""
  local completions = {}
  local expanded = parser.resolve_path(base_path)
  local path_completions = vim.fn.glob(expanded .. "*", false, true)
  for _, completion in ipairs(path_completions) do
    if expanded ~= base_path then
      completion = base_path .. string.sub(completion, #expanded + 1)
    end
    table.insert(completions, key_prefix .. completion)
  end

  return table.concat(completions, "\n")
end

M.complete_args = function (argLead, cmdLine)
  local candidates = {}
  local existing = utils.split(cmdLine, " ")
  local parsed = parser.parse(existing, false)

  local eq = string.find(argLead, "=")
  if eq == nil then
    if M.show_key_value_completions then
      -- may be the start of a new key=value pair
      for _, key in ipairs(parser.list_args) do
        key = tostring(key)
        if key:find(argLead) and not parsed[key] then
          table.insert(candidates, key .. "=")
        end
      end

      for _, key in ipairs(parser.path_args) do
        key = tostring(key)
        if key:find(argLead) and not parsed[key] then
          table.insert(candidates, key .. "=./")
        end
      end
    end
  else
    -- continuation of a key=value pair
    local key = string.sub(argLead, 1, eq - 1)
    local value = string.sub(argLead, eq + 1)
    local arg_type = parser.arg_type_lookup[key]
    if arg_type == parser.PATH then
      return get_path_completions(key .. "=", value)
    elseif arg_type == parser.LIST then
      local valid_values = parser.arguments[key].values
      if valid_values and not parsed[key] then
        for _, vv in ipairs(valid_values) do
          if vv:find(value) then
            table.insert(candidates, key .. "=" .. vv)
          end
        end
      end
    end
  end

  -- may be a value without a key
  for value, key  in pairs(parser.reverse_lookup) do
    value = tostring(value)
    local key_already_used = false
    if parser.arg_type_lookup[key] == parser.LIST then
      key_already_used = type(parsed[key]) ~= "nil"
    else
      key_already_used = type(parsed[value]) ~= "nil"
    end

    if not key_already_used and value:find(argLead) then
      table.insert(candidates, value)
    end
  end

  if #candidates == 0 then
    -- default to path completion
    return get_path_completions(nil, argLead)
  end
  return table.concat(candidates, "\n")
end

return M
