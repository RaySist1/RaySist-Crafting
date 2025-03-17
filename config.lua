Config = {}

Config.Debug = false

-- Crafting Tables with specific item categories
Config.CraftingTables = {
    {
        name = "weapons_table",
        model = `gr_prop_gr_bench_04b`, -- Weapons crafting table prop
        coords = vector4(-968.11, -3011.98, 13.95, 56.95), -- Example location
        length = 1.0,
        width = 1.0,
        heading = 85.0,
        minZ = 29.0,
        maxZ = 31.0,
        distance = 2.5,
        allowedCategories = {"weapons", "ammo"}, -- This table only allows weapons and ammo crafting
        tableLabel = "Weapons Workbench"
    },
    {
        name = "tools_table",
        model = `prop_tool_bench02`, -- Tools crafting table prop
        coords = vector4(-966.02, -3008.91, 13.95, 63.94), -- Different location
        length = 1.0,
        width = 1.0,
        heading = 110.5,
        minZ = 29.0,
        maxZ = 31.0,
        distance = 2.5,
        allowedCategories = {"tools"}, -- This table only allows tools crafting
        tableLabel = "Tools Workbench"
    },
    {
        name = "medical_table",
        model = `prop_tool_bench01`, -- Medical crafting table prop
        coords = vector4(-963.64, -3004.74, 13.95, 62.79), -- Another location
        length = 1.0,
        width = 1.0,
        heading = 180.0,
        minZ = 29.0,
        maxZ = 31.0,
        distance = 2.5,
        allowedCategories = {"medical"}, -- This table only allows medical crafting
        tableLabel = "Medical Station"
    }
}

-- Crafting Categories
Config.Categories = {
    {
        name = "weapons",
        label = "Weapons",
        icon = "gun"
    },
    {
        name = "ammo",
        label = "Ammunition",
        icon = "bomb"
    },
    {
        name = "tools",
        label = "Tools",
        icon = "toolbox"
    },
    {
        name = "medical",
        label = "Medical",
        icon = "first-aid"
    }
}

-- Crafting Recipes
Config.Recipes = {
    -- Weapons
    {
        name = "weapon_pistol",
        label = "Pistol",
        category = "weapons",
        time = 60, -- seconds to craft
        ingredients = {
            { item = "metalscrap", amount = 30, label = "Metal Scrap" },
            { item = "steel", amount = 45, label = "Steel" },
            { item = "rubber", amount = 20, label = "Rubber" }
        },
        requireBlueprint = false,
        blueprintItem = "pistol_blueprint"
    },
    {
        name = "weapon_smg",
        label = "SMG",
        category = "weapons",
        time = 90,
        ingredients = {
            { item = "metalscrap", amount = 50, label = "Metal Scrap" },
            { item = "steel", amount = 60, label = "Steel" },
            { item = "rubber", amount = 30, label = "Rubber" }
        },
        requireBlueprint = true,
        blueprintItem = "smg_blueprint"
    },

    -- Ammo
    {
        name = "pistol_ammo",
        label = "Pistol Ammo",
        category = "ammo",
        time = 10,
        ingredients = {
            { item = "metalscrap", amount = 10, label = "Metal Scrap" },
            { item = "steel", amount = 10, label = "Steel" },
            { item = "copper", amount = 10, label = "Copper" }
        },
        requireBlueprint = false
    },
    {
        name = "smg_ammo",
        label = "SMG Ammo",
        category = "ammo",
        time = 15,
        ingredients = {
            { item = "metalscrap", amount = 15, label = "Metal Scrap" },
            { item = "steel", amount = 15, label = "Steel" },
            { item = "copper", amount = 15, label = "Copper" }
        },
        requireBlueprint = false
    },
    {
        name = "shotgun_ammo",
        label = "Shotgun Ammo",
        category = "ammo",
        time = 17,
        ingredients = {
            { item = "metalscrap", amount = 17, label = "Metal Scrap" },
            { item = "steel", amount = 17, label = "Steel" },
            { item = "copper", amount = 17, label = "Copper" }
        },
        requireBlueprint = false
    },
    {
        name = "rifle_ammo",
        label = "Rifle Ammo",
        category = "ammo",
        time = 20,
        ingredients = {
            { item = "metalscrap", amount = 20, label = "Metal Scrap" },
            { item = "steel", amount = 20, label = "Steel" },
            { item = "copper", amount = 20, label = "Copper" }
        },
        requireBlueprint = false
    },

    -- Tools
    {
        name = "lockpick",
        label = "Lockpick",
        category = "tools",
        time = 20,
        ingredients = {
            { item = "metalscrap", amount = 5, label = "Metal Scrap" },
            { item = "plastic", amount = 5, label = "Plastic" }
        },
        requireBlueprint = false
    },
    {
        name = "advancedlockpick",
        label = "Advanced Lockpick",
        category = "tools",
        time = 33,
        ingredients = {
            { item = "metalscrap", amount = 13, label = "Metal Scrap" },
            { item = "plastic", amount = 13, label = "Plastic" }
        },
        requireBlueprint = false
    },
    {
        name = "screwdriverset",
        label = "Screwdriver Set",
        category = "tools",
        time = 15,
        ingredients = {
            { item = "metalscrap", amount = 8, label = "Metal Scrap" },
            { item = "plastic", amount = 3, label = "Plastic" },
            { item = "rubber", amount = 2, label = "Rubber" }
        },
        requireBlueprint = false
    },
    {
        name = "drill",
        label = "Drill",
        category = "tools",
        time = 40,
        ingredients = {
            { item = "metalscrap", amount = 20, label = "Metal Scrap" },
            { item = "steel", amount = 10, label = "Steel" },
            { item = "electronics", amount = 5, label = "Electronics" }
        },
        requireBlueprint = true,
        blueprintItem = "drill_blueprint"
    },

    -- Medical
    {
        name = "bandage",
        label = "Bandage",
        category = "medical",
        time = 15,
        ingredients = {
            { item = "cloth", amount = 3, label = "Cloth" },
            { item = "alcohol", amount = 1, label = "Alcohol" }
        },
        requireBlueprint = false
    },
    {
        name = "painkillers",
        label = "Painkillers",
        category = "medical",
        time = 18,
        ingredients = {
            { item = "chemicals", amount = 2, label = "Chemicals" },
            { item = "plastic", amount = 1, label = "Plastic" }
        },
        requireBlueprint = false
    },
    {
        name = "firstaid",
        label = "First Aid Kit",
        category = "medical",
        time = 30,
        ingredients = {
            { item = "cloth", amount = 5, label = "Cloth" },
            { item = "alcohol", amount = 3, label = "Alcohol" },
            { item = "painkillers", amount = 2, label = "Painkillers" }
        },
        requireBlueprint = false
    }
}

-- Skills
Config.UseSkills = false -- Set to false if you don't want to use skills
Config.SkillName = "crafting" -- Skill name in your skills system
Config.SkillIncreaseAmount = 0.1 -- How much skill increases per craft
