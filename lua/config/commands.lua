vim.api.nvim_create_user_command("DBTriggers", function()
  -- Pergunta o schema, default "public"
  local schema = vim.fn.input("Schema (default: public): ", "public")

  -- Monta a query
  local sql = string.format(
    [[
SELECT
    event_object_schema AS schema,
    event_object_table  AS tabela,
    trigger_name        AS trigger,
    string_agg(event_manipulation, ', ' ORDER BY event_manipulation) AS eventos,
    action_timing       AS timing
FROM information_schema.triggers
WHERE event_object_schema = '%s'
GROUP BY
    event_object_schema,
    event_object_table,
    trigger_name,
    action_timing
ORDER BY
    event_object_schema,
    event_object_table,
    trigger_name;
  ]],
    schema
  )

  -- Abre dadbod-ui em buffer novo (split opcional)
  vim.cmd("DBUI")

  -- Executa a query usando dadbod
  vim.cmd("DB " .. sql)
end, { desc = "Listar triggers do DB via Dadbod-UI" })

-- Atalho opcional: <leader>dt
vim.keymap.set("n", "<leader>dt", ":DBTriggers<CR>", { desc = "Listar triggers do DB" })
