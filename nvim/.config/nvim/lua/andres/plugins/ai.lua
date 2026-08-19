return {
  -- Disabled: in-editor ChatGPT integration (API key read via 1Password CLI, never hardcoded)
  -- "jackMort/ChatGPT.nvim",
  -- event = "VeryLazy",
  -- dependencies = {
  --   "MunifTanjim/nui.nvim",
  --   "nvim-lua/plenary.nvim",
  --   "folke/trouble.nvim",
  --   "nvim-telescope/telescope.nvim",
  -- },
  -- config = function()
  --   require("chatgpt").setup({
  --     api_key_cmd = "op read op://Personal/open-ai-key/credential",
  --   })
  -- end,
  -- keys = {
  --   { "<leader>ai", "<cmd>ChatGPT<cr>", desc = "Open chatgpt" },
  -- },
}
