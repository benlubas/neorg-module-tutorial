--[[
file: My Custom Module
title: A Short Whitty Description of the Module
summary: A longer description of what this module actually does
internal: false
---

Any extra documentation about how the module works. Normally I like to include
a longer, clear description of what that module is capable of.

## Commands
If there are commands, I will list them here like:
- `:Neorg sub command` - does xyz

## Keybinds
It's important to let the user know if your module makes keybinds available.
Again, I like to list them out:
- `<Plug>(neorg.my_module.do_thing)` - does a thing
--]]

local neorg = require("neorg.core")
local modules, lib, log = neorg.modules, neorg.lib, neorg.log

local treesitter ---@type core.integrations.treesitter

local module = modules.create("external.my-module")

module.setup = function()
  -- local ok, res = pcall(require, "some_other_plugin")
  -- if not ok then
  --   log.error("[My Module] Failed to load `some_other_plugin` ...")
  -- end

  return {
    -- success = ok,
    success = true,
    requires = { "core.integrations.treesitter", "core.dirman" },
  }
end

module.load = function()
  treesitter = module.required["core.integrations.treesitter"]
  dirman = module.required["core.dirman"]

  -- Add a command, called like `:Neorg greet <name>`
  modules.await("core.neorgcmd", function(neorgcmd)
    neorgcmd.add_commands_from_table({
      greet = { -- this is the name of the subcommand
        name = "external.my-module.greet", -- this is the `id` of the subcommand
        args = 1, -- this command takes 1 argument
        condition = "norg", -- the command is only available from "norg" documents
        complete = { -- we can provide completions for this position in the
          -- command line. see `:h :command-completion-customlist` for more info
          { "World" },
        },
      },
      ["greet!"] = {
        name = "external.my-module.greet!",
        args = 1,
        condition = "norg",
      }
    })
  end)
end

module.public.config = {
  -- Enables this functionality, which does xyz.
  -- This is _markdown_ and
  --
  -- you can leave blank lines like this.
  enable_thing = false,
}

---@class external.my-module
module.public = {
  ---Greets the user
  ---@param user_name string
  greet_user = function(user_name)
    vim.notify(("Hello %s!"):format(user_name), vim.log.levels.INFO)
  end,
}

module.private = {
  ---Upercase the first letter in each word, assumes words are two or more
  -- letters long (b/c this is a neorg tutorial and I'm lazy)
  ---@param name string
  ---@return string
  title_case = function(name)
    return vim.iter(vim.split(name, " "))
      :map(function(word)
        return string.upper(word:sub(1, 1)) .. word:sub(2)
      end):join(" ")
  end
}

---Convert a function into mEmEcAsE
---@param name string
---@return string
local function mEmEcAsE(name)
  local res = ""
  for i = 1, #name do
    local char = name:sub(i, i):lower()
    if i % 2 == 0 then
      char = char:upper()
    end
    res = res .. char
  end
  return res
end

-- here, we subscribe to the command so that our module is notified when that
-- command fires
module.events.subscribed = {
  ["core.neorgcmd"] = {
    ["external.my-module.greet"] = true,
    ["external.my-module.greet!"] = true,
  },
}

local handlers = {
  ["external.my-module.greet"] = function(name)
    module.public.greet_user(module.private.title_case(name))
  end,

  ["external.my-module.greet!"] = function(name)
    module.public.greet_user(mEmEcAsE(name))
  end,
}

-- And now we set the event handler
module.on_event = function(event)
  -- Have a look at all the information in this event!
  -- vim.print(event)

  local ev_name = event.split_type[2]
  if handlers[ev_name] then
    handlers[ev_name](event.content[1])
  end
end

return module