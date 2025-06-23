-- === CopilotChat Setup ===
require("CopilotChat").setup {
  agent = "copilot",
  show_help = true,
  context = {"selection", "git:staged"},
  chat_autocomplete = true,
  highlight_selection = true,
  highlight_headers = true,
  question_header = '# My Question',
  window = {
    layout = 'float',
    relative = 'cursor',
    width = 1,
    height = 0.8,
    row = 1,
    winhighlight = "Normal:CopilotChatNormal,FloatBorder:CopilotChatBorder",
    border = "double",
    prompt_title = function()
      local agent = require("CopilotChat.config").options.agent or "?"
      return "CopilotChat (" .. agent .. ")"
    end
  },
  show_diff = true,
  mappings = {
    quickfix_diffs = {
      normal = 'gq',
    },
    reset = {
      normal = '<C-l>',
      insert = '<C-l>'
    },
    jump_to_diff = {
      normal = 'jd',
    }
  },
  submit_prompt = {
    normal = '<CR>',
    insert = '<C-s>',
  }
}

-- === Highlight Groups (1:1 with Vim) ===
vim.api.nvim_set_hl(0, "markdownCodeBlock", { bg = "#3c3836", fg = "#fabd2f", bold = true })
vim.api.nvim_set_hl(0, "CopilotChatNormal", { bg = "#282828", fg = "#eeeeee" })
vim.api.nvim_set_hl(0, "CopilotChatBorder", { fg = "#af87ff" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#282828", fg = "#eeeeee" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#af87ff" })

-- === Autocmd for FileType copilot-chat (1:1) ===
vim.api.nvim_create_autocmd("FileType", {
  pattern = "copilot-chat",
  callback = function()
    vim.bo.filetype = "markdown"
    vim.cmd("syntax enable")
    vim.cmd("setlocal conceallevel=0")
    vim.api.nvim_buf_set_keymap(0, "i", "<C-J>", "<C-R>=copilot#Accept(\"\\<CR>\")<CR>", { noremap = true, silent = true })
  end,
})

-- === Telescope Agent Action Picker ===
local copilot = require("CopilotChat")
local actions = require("CopilotChat.actions")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local symbol = vim.fn.expand("<cword>") or "this function"

local agent_actions = {
  commit = function() copilot.ask("Write a commit message for this code and explain why the changes were made", { context = { "git:staged" } }) end,
  tests = function() copilot.ask("Write Rspec tests for this method only", { context = { "selection" } }) end,
  test_class = function() copilot.ask("Write Rspec tests for this class", { context = { "buffer" } }) end,
  refactor = function() copilot.ask("Refactor this to be more idiomatic Ruby", { context = { "selection" } }) end,
  optimize = function() copilot.ask("Optimize this function for performance", { context = { "selection" } }) end,
  docs = function() copilot.ask("Generate documentation comments for this method", { context = { "selection" } }) end,
  explain_method = function() copilot.ask("Summarize what the function '" .. symbol .. "' is doing", { context = { "buffer" } }) end,
  explain = function() copilot.ask("Explain what this code is doing step by step", { context = { "buffer" } }) end,
  explain_multiple = function() copilot.ask("Explain what this code is doing step by step", { context = { "buffers" } }) end,
  fix = function() copilot.ask("Help identify and fix any bugs in this code", { context = { "selection" } }) end,
  alternatives = function() copilot.ask("Suggest some alternative ways to implement this", { context = { "selection" } }) end,
  review = function() copilot.ask("Do a code review of this snippet", { context = { "git:staged" } }) end,
  changes_summary = function() copilot.ask("Summarize the changes in the staged diff", { context = { "git:staged" } }) end,
}

local function agent_prompt_picker()
  local prompt_list = {
    { name = "🧪 Write tests for this method", action = agent_actions.tests },
    { name = "🧪 Write tests for this class", action = agent_actions.test_class },
    { name = "🧐 Do a code review", action = agent_actions.review },
    { name = "🧠 Suggest alternatives", action = agent_actions.alternatives },
    { name = "🧼 Refactor this code", action = agent_actions.refactor },
    { name = "📈 Optimize performance", action = agent_actions.optimize },
    { name = "📚 Add documentation", action = agent_actions.docs },
    { name = "💬 Explain code", action = agent_actions.explain },
    { name = "💬 Explain method", action = agent_actions.explain_method },
    { name = "💬 Explain code from multiple files", action = agent_actions.explain_multiple },
    { name = "🛠️ Fix bugs", action = agent_actions.fix },
    { name = "📥 Commit message", action = agent_actions.commit },
    { name = "🔎 Summarize Changes", action = agent_actions.changes_summary },
  }

  pickers.new({}, {
    prompt_title = "Copilot Agent Actions",
    finder = finders.new_table {
      results = prompt_list,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    },
    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, map)
      local actions_telescope = require("telescope.actions")
      actions_telescope.select_default:replace(function(prompt_bufnr)
        local selection = require("telescope.actions.state").get_selected_entry()
        actions_telescope.close(prompt_bufnr)
        selection.value.action()
      end)
      return true
    end,
  }):find()
end

vim.keymap.set("v", "<leader>ca", agent_prompt_picker, { desc = "CopilotChat: Agent Actions (Visual Mode)" })
vim.keymap.set("n", "<leader>ca", agent_prompt_picker, { desc = "CopilotChat: Agent Actions (Normal Mode)" })

vim.api.nvim_create_user_command("CopilotChatToScratch", function()
  local input_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code_blocks = {}
  local in_block = false

  for _, line in ipairs(input_lines) do
    if line:match("^```") then
      in_block = not in_block
    elseif in_block then
      table.insert(code_blocks, line)
    end
  end

  if #code_blocks == 0 then
    print("No code blocks found in chat output.")
    return
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, code_blocks)
  vim.cmd("split")
  vim.api.nvim_win_set_buf(0, bufnr)
end, {})

vim.keymap.set("v", "<leader>cp", ":CopilotChat<CR>", {})
vim.keymap.set("n", "<leader>cp", ":CopilotChat<CR>", {})
vim.keymap.set("v", "<leader>cf", ":CopilotChatFix<CR>", {})
vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", {})
vim.keymap.set("v", "<leader>co", ":CopilotChatOptimize<CR>", {})
vim.keymap.set("n", "<leader>cm", ":CopilotChatCommit<CR>", {})
vim.keymap.set("n", "<leader>cb", ":CopilotChatBuffer<CR>", {})
vim.keymap.set("n", "<leader>cx", ":CopilotChatExplain<CR>", {})
vim.keymap.set("v", "<leader>cc", ":CopilotChatVisual<CR>", {})
vim.keymap.set("n", "<leader>cs", ":CopilotChatToScratch<CR>", {})
