-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"
vim.cmd.colorscheme "catppuccin"
vim.opt.wrap = true
vim.api.nvim_set_hl(0, "Comment", { italic = false })
vim.api.nvim_set_hl(0, "Comment", { fg = "#414559" })



local dap = require('dap')
require('dapui').setup({ 
  layouts = { {
    elements = {
      {
        id = "repl", size = 0.30
      },
      {
        id = "scopes", size = 0.30
      },
      {
        id = "console", size = 0.40
      },
    },
    size = 20,
    position = "bottom"
  }
  }
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.js", "*.ts" },
  callback = function()
    if dap.session() then
      -- Temporarily disable dapui's auto close
      dap.listeners.before.event_terminated["restart_hook"] = function() end
      dap.listeners.before.event_exited["restart_hook"] = function() end

      -- Terminate current session
      dap.terminate()

      -- Wait a bit, then restart cleanly
      vim.defer_fn(function()
        dap.run_last()
        vim.notify("🔁 Node DAP session manually restarted", vim.log.levels.INFO)
      end, 500) -- Small delay ensures termination finishes first
    end
  end,
})
dap.configurations.javascript = {
  {
    name = 'Launch via npm',
    type = 'node2',
    request = 'launch',
    cwd = vim.fn.getcwd(),
    program = '${workspaceFolder}/bin/www',
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
  {
    name = 'Run file',
    type = 'node2',
    request = 'launch',
    cwd = vim.fn.getcwd(),
    program = '${file}',
    envFile = '${workspaceFolder}/.env',
    sourceMaps = true,
    protocol = 'inspector',
    console = 'integratedTerminal',
  },
  {
    -- For this to work you need to make sure the node process is started with the `--inspect` flag.
    name = 'Attach to process',
    type = 'node2',
    request = 'attach',
    processId = require'dap.utils'.pick_process,
  },
}
