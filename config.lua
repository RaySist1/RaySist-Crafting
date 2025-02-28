Config = {}

Config.Debug = false

-- Crafting Tables
Config.CraftingTables = {
    {
        model = `gr_prop_gr_bench_04b`, -- Crafting table prop
        coords = vector4(-75.56, -819.05, 326.18, 291.72), -- Example location
        length = 1.0,
        width = 1.0,
        heading = 85.0,
        minZ = 29.0,
        maxZ = 31.0,
        distance = 2.5
    },
    -- Add more crafting tables as needed
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
    }

    -- Add more recipes as needed
}

-- Skills
Config.UseSkills = false -- Set to false if you don't want to use skills
Config.SkillName = "crafting" -- Skill name in your skills system
Config.SkillIncreaseAmount = 0.1 -- How much skill increases per craft
