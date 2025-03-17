local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local craftingOpen = false
local currentCraftingTable = nil

-- Initialize
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- Create crafting tables
CreateThread(function()
    for tableName, table in pairs(Config.CraftingTables) do
        -- Create target for crafting tables
        exports['qb-target']:AddTargetModel(table.model, {
            options = {
                {
                    type = "client",
                    event = "RaySist-Crafting:client:OpenCrafting",
                    icon = "fas fa-hammer",
                    label = "Use " .. (table.tableLabel or "Crafting Table"),
                    tableName = table.name, -- Pass the table name to identify which table was used
                },
            },
            distance = table.distance or 2.5
        })

        -- Create crafting table props if coords are provided
        if table.coords then
            local model = table.model
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end

            local craftingTable = CreateObject(model, table.coords.x, table.coords.y, table.coords.z - 1.0, false, false, false)
            SetEntityHeading(craftingTable, table.coords.w)
            FreezeEntityPosition(craftingTable, true)
            SetEntityAsMissionEntity(craftingTable, true, true)
            SetModelAsNoLongerNeeded(model)

            if Config.Debug then
                print("Created crafting table at: " .. table.coords.x .. ", " .. table.coords.y .. ", " .. table.coords.z)
            end
        end
    end
end)

-- Open crafting menu
RegisterNetEvent('RaySist-Crafting:client:OpenCrafting', function(data)
    if craftingOpen then return end

    -- Find the table configuration by name
    local tableName = data.tableName
    local tableConfig = nil

    for _, table in pairs(Config.CraftingTables) do
        if table.name == tableName then
            tableConfig = table
            break
        end
    end

    if not tableConfig then
        QBCore.Functions.Notify("Invalid crafting table", "error")
        return
    end

    -- Check for required job if set
    if tableConfig.requiredJob and PlayerData.job.name ~= tableConfig.requiredJob then
        QBCore.Functions.Notify("You don't have the required job to use this table", "error")
        return
    end

    -- Check for required items if set
    if tableConfig.requiredItems then
        QBCore.Functions.TriggerCallback('RaySist-Crafting:server:HasRequiredItems', function(hasItems, missingItems)
            if not hasItems then
                QBCore.Functions.Notify("You're missing required items: " .. missingItems, "error")
                return
            else
                OpenCraftingTable(tableConfig)
            end
        end, tableConfig.requiredItems)
    else
        OpenCraftingTable(tableConfig)
    end
end)

-- Function to open a specific crafting table
function OpenCraftingTable(tableConfig)
    craftingOpen = true
    currentCraftingTable = tableConfig.name
    SetNuiFocus(true, true)

    -- Get player inventory for checking materials
    QBCore.Functions.TriggerCallback('RaySist-Crafting:server:GetPlayerInventory', function(inventory)
        -- Filter categories based on the table's allowed categories
        local filteredCategories = {}
        for _, category in pairs(Config.Categories) do
            for _, allowedCategory in pairs(tableConfig.allowedCategories) do
                if category.name == allowedCategory then
                    table.insert(filteredCategories, category)
                    break
                end
            end
        end

        -- Filter recipes based on the table's allowed categories
        local filteredRecipes = {}
        for _, recipe in pairs(Config.Recipes) do
            for _, allowedCategory in pairs(tableConfig.allowedCategories) do
                if recipe.category == allowedCategory then
                    table.insert(filteredRecipes, recipe)
                    break
                end
            end
        end

        -- Send data to NUI
        SendNUIMessage({
            action = "open",
            recipes = filteredRecipes,
            categories = filteredCategories,
            inventory = inventory,
            useSkills = Config.UseSkills,
            tableName = tableConfig.name,
            tableLabel = tableConfig.tableLabel or "Crafting Table"
        })
    end)
end

-- Close crafting menu
RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    craftingOpen = false
    currentCraftingTable = nil
    cb('ok')
end)

-- Start crafting process
RegisterNUICallback('craftItem', function(data, cb)
    local recipe = nil

    -- Find the recipe
    for _, r in pairs(Config.Recipes) do
        if r.name == data.item then
            recipe = r
            break
        end
    end

    if not recipe then
        QBCore.Functions.Notify("Recipe not found", "error")
        cb('error')
        return
    end

    -- Verify the item can be crafted at this table
    local canCraftHere = false
    for _, table in pairs(Config.CraftingTables) do
        if table.name == currentCraftingTable then
            for _, category in pairs(table.allowedCategories) do
                if category == recipe.category then
                    canCraftHere = true
                    break
                end
            end
            break
        end
    end

    if not canCraftHere then
        QBCore.Functions.Notify("This item cannot be crafted at this table", "error")
        cb('error')
        return
    end

    -- Check if player has the blueprint if required
    if recipe.requireBlueprint then
        QBCore.Functions.TriggerCallback('RaySist-Crafting:server:HasBlueprint', function(hasBlueprint)
            if not hasBlueprint then
                QBCore.Functions.Notify(Lang:t("error.no_blueprint"), "error")
                cb('error')
                return
            else
                -- Close the NUI before starting crafting
                SetNuiFocus(false, false)
                craftingOpen = false
                currentCraftingTable = nil

                TriggerServerEvent('RaySist-Crafting:server:CraftItem', recipe.name)
                cb('ok')
            end
        end, recipe.blueprintItem)
    else
        -- Close the NUI before starting crafting
        SetNuiFocus(false, false)
        craftingOpen = false
        currentCraftingTable = nil

        TriggerServerEvent('RaySist-Crafting:server:CraftItem', recipe.name)
        cb('ok')
    end
end)

function OpenCraftingMenu(tableData)
    -- Get player inventory for checking materials
    QBCore.Functions.TriggerCallback('RaySist-Crafting:server:GetPlayerInventory', function(inventory)
        -- Filter categories based on the table
        local filteredCategories = {}
        if tableData and tableData.allowedCategories then
            for _, category in pairs(Config.Categories) do
                for _, allowedCategory in pairs(tableData.allowedCategories) do
                    if category.name == allowedCategory then
                        table.insert(filteredCategories, category)
                        break
                    end
                end
            end
        else
            filteredCategories = Config.Categories
        end

        -- Filter recipes based on the table
        local filteredRecipes = {}
        if tableData and tableData.allowedCategories then
            for _, recipe in pairs(Config.Recipes) do
                for _, allowedCategory in pairs(tableData.allowedCategories) do
                    if recipe.category == allowedCategory then
                        table.insert(filteredRecipes, recipe)
                        break
                    end
                end
            end
        else
            filteredRecipes = Config.Recipes
        end

        -- Send data to NUI
        SendNUIMessage({
            action = "open",
            recipes = filteredRecipes,
            categories = filteredCategories,
            inventory = inventory,
            useSkills = Config.UseSkills,
            tableName = tableData and tableData.name or "generic_table"
        })
    end)
end

-- Crafting progress
RegisterNetEvent('RaySist-Crafting:client:CraftingProgress', function(item, time)
    local recipe = nil

    -- Find the recipe
    for _, r in pairs(Config.Recipes) do
        if r.name == item then
            recipe = r
            break
        end
    end

    if not recipe then return end

    QBCore.Functions.Progressbar("crafting_item", Lang:t("info.crafting_in_progress", {item = recipe.label}), time * 1000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "mini@repair",
        anim = "fixing_a_ped",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)
        QBCore.Functions.Notify(Lang:t("error.canceled"), "error")

        TriggerServerEvent('RaySist-Crafting:server:CancelCrafting')
    end)
end)

-- Crafting result
RegisterNetEvent('RaySist-Crafting:client:CraftingResult', function(success, item)
    local recipe = nil

    -- Find the recipe
    for _, r in pairs(Config.Recipes) do
        if r.name == item then
            recipe = r
            break
        end
    end

    if not recipe then return end

    if success then
        QBCore.Functions.Notify(Lang:t("success.crafted_item", {item = recipe.label}), "success")
    else
        QBCore.Functions.Notify(Lang:t("error.failed_craft"), "error")
    end
end)

-- Update inventory in NUI
RegisterNetEvent('RaySist-Crafting:client:UpdateInventory', function()
    if not craftingOpen then return end

    QBCore.Functions.TriggerCallback('RaySist-Crafting:server:GetPlayerInventory', function(inventory)
        SendNUIMessage({
            action = "updateInventory",
            inventory = inventory
        })
    end)
end)
