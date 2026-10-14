local function create_pg_commands()
  -- Função auxiliar para pegar URL da conexão pelo nome
  local function get_db_url(db_name)
    if not vim.g.dbs or #vim.g.dbs == 0 then
      return nil
    end

    for _, db in ipairs(vim.g.dbs) do
      if db.name == db_name then
        return db.url
      end
    end

    return nil
  end

  -- Função auxiliar para executar query e mostrar resultados
  local function execute_query(query, title, db_name)
    -- Criar novo buffer para a query
    vim.cmd("tabnew")
    local buf = vim.api.nvim_get_current_buf()

    -- Configurar o buffer como SQL
    vim.bo.filetype = "sql"
    vim.bo.buftype = "nofile"

    -- Definir nome do buffer
    vim.api.nvim_buf_set_name(0, title .. ".sql")

    -- Inserir a query
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(query, "\n"))

    -- Pegar a URL da conexão
    local db_url = nil

    if db_name then
      db_url = get_db_url(db_name)
      if not db_url then
        vim.notify(string.format("Conexão '%s' não encontrada em vim.g.dbs!", db_name), vim.log.levels.ERROR)
        return
      end
    else
      -- Tentar usar a última conexão ou a primeira configurada
      if vim.g.db_ui_last_query_db and vim.g.db_ui_last_query_db ~= "" then
        db_url = vim.g.db_ui_last_query_db
      elseif vim.g.dbs and #vim.g.dbs > 0 then
        db_url = vim.g.dbs[1].url
        vim.notify(string.format("Usando conexão padrão: %s", vim.g.dbs[1].name), vim.log.levels.INFO)
      end
    end

    if db_url then
      -- Definir a conexão para este buffer
      vim.b.db = db_url

      -- Executar a query (selecionar tudo e executar)
      vim.cmd("normal! ggVG")
      vim.cmd("DB")

      vim.notify("Query executada! Aguarde os resultados...", vim.log.levels.INFO)
    else
      vim.notify("Nenhuma conexão encontrada! Configure vim.g.dbs ou use DBUI primeiro.", vim.log.levels.WARN)
      vim.notify("Você pode executar manualmente: selecione a query e use :DB url_conexao", vim.log.levels.INFO)
    end
  end

  -- Comando 1: Listar triggers de uma tabela
  vim.api.nvim_create_user_command("PgListTriggers", function(opts)
    local args = vim.split(opts.args, "%s+")
    local db_name = nil
    local table_name = nil

    if #args == 0 then
      vim.notify("Uso: :PgListTriggers [nome_conexao] nome_da_tabela", vim.log.levels.ERROR)
      return
    elseif #args == 1 then
      table_name = args[1]
    else
      db_name = args[1]
      table_name = args[2]
    end

    local query = string.format(
      [[
SELECT 
    t.tgname AS trigger_name,
    t.tgenabled AS enabled,
    p.proname AS function_name,
    CASE t.tgtype & 2
        WHEN 2 THEN 'BEFORE'
        ELSE 'AFTER'
    END AS timing,
    CASE t.tgtype & 28
        WHEN 4 THEN 'INSERT'
        WHEN 8 THEN 'DELETE'
        WHEN 16 THEN 'UPDATE'
        WHEN 12 THEN 'INSERT OR DELETE'
        WHEN 20 THEN 'INSERT OR UPDATE'
        WHEN 24 THEN 'DELETE OR UPDATE'
        WHEN 28 THEN 'INSERT OR DELETE OR UPDATE'
    END AS event
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = '%s'
  AND n.nspname = 'public'
  AND NOT t.tgisinternal
ORDER BY t.tgname;
]],
      table_name
    )

    execute_query(query, "Triggers: " .. table_name, db_name)
  end, { nargs = "+", desc = "Listar triggers de uma tabela PostgreSQL" })

  -- Comando 2: Listar todas as funções do banco
  vim.api.nvim_create_user_command("PgListFunctions", function(opts)
    local db_name = opts.args ~= "" and opts.args or nil
    local query = [[
SELECT 
    n.nspname AS schema,
    p.proname AS function_name,
    pg_catalog.pg_get_function_arguments(p.oid) AS arguments,
    CASE p.prokind
        WHEN 'f' THEN 'FUNCTION'
        WHEN 'p' THEN 'PROCEDURE'
        WHEN 'a' THEN 'AGGREGATE'
        WHEN 'w' THEN 'WINDOW'
    END AS type,
    pg_catalog.obj_description(p.oid, 'pg_proc') AS description
FROM pg_catalog.pg_proc p
JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schema, function_name;
]]

    execute_query(query, "PostgreSQL Functions", db_name)
  end, { nargs = "?", desc = "Listar todas as funções PostgreSQL" })

  -- Comando 3: Mostrar código de uma função
  vim.api.nvim_create_user_command("PgShowFunction", function(opts)
    local args = vim.split(opts.args, "%s+")
    local db_name = nil
    local function_name = nil

    if #args == 0 then
      vim.notify("Uso: :PgShowFunction [nome_conexao] nome_da_funcao", vim.log.levels.ERROR)
      return
    elseif #args == 1 then
      function_name = args[1]
    else
      db_name = args[1]
      function_name = args[2]
    end

    local query = string.format(
      [[
SELECT pg_get_functiondef(p.oid) AS function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = '%s'
  AND n.nspname = 'public';
]],
      function_name
    )

    execute_query(query, "Function: " .. function_name, db_name)
  end, { nargs = "+", desc = "Mostrar código de uma função PostgreSQL" })
end

-- Criar os comandos quando o Neovim iniciar
vim.api.nvim_create_autocmd("VimEnter", {
  callback = create_pg_commands,
})
