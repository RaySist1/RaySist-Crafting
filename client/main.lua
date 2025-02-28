local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local craftingOpen = false

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
    for _, table in pairs(Config.CraftingTables) do
        -- Create target for crafting tables
        exports['qb-target']:AddTargetModel(table.model, {
            options = {
                {
                    type = "client",
                    event = "RaySist-Crafting:client:OpenCrafting",
                    icon = "fas fa-hammer",
                    label = "Use Crafting Table",
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
RegisterNetEvent('RaySist-Crafting:client:OpenCrafting', function()
    if craftingOpen then return end

    craftingOpen = true
    SetNuiFocus(true, true)

    -- Get player inventory for checking materials
    QBCore.Functions.TriggerCallback('RaySist-Crafting:server:GetPlayerInventory', function(inventory)
        -- Send data to NUI
        SendNUIMessage({
            action = "open",
            recipes = Config.Recipes,
            categories = Config.Categories,
            inventory = inventory,
            useSkills = Config.UseSkills
        })
    end)
end)

-- Close crafting menu
RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    craftingOpen = false
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

                TriggerServerEvent('RaySist-Crafting:server:CraftItem', recipe.name)
                cb('ok')
            end
        end, recipe.blueprintItem)
    else
        -- Close the NUI before starting crafting
        SetNuiFocus(false, false)
        craftingOpen = false

        TriggerServerEvent('RaySist-Crafting:server:CraftItem', recipe.name)
        cb('ok')
    end
end)

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
