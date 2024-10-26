local source = {}

function source:complete(cmp_params, cmp_callback)
    local coc_options = {
        bufnr = cmp_params.context.bufnr,
        line = cmp_params.context.cursor_line,
        colnr = cmp_params.context.cursor.col,
    }

    if vim.fn['coc#source#mediawiki#should_complete'](coc_options) == 0 then
        cmp_callback(nil)
        return
    end

    local function coc_callback(data)
        local response = {
            isIncomplete = false,
            items = {}
        }

        for _, datum in ipairs(data) do
            table.insert(response.items, {
                insertText = datum.word,
                label = datum.menu,
                detail = datum.info,
            })
        end

        cmp_callback(response)
    end

    vim.fn['coc#source#mediawiki#complete'](coc_options, coc_callback)
end

function source:is_available()
    return vim.bo.filetype == 'mediawiki'
end

function source:resolve(completion_item, callback)
    callback(completion_item)
end

function source:execute(completion_item, callback)
    callback(completion_item)
end

require('cmp').register_source('cmp_mediawiki', source)
