local Translations = {
    error = {
        not_enough_materials = "You don't have enough materials",
        failed_craft = "Crafting failed...",
        no_blueprint = "You don't have the required blueprint",
        canceled = "Crafting canceled"
    },
    success = {
        crafted_item = "Successfully crafted %{item}!"
    },
    info = {
        crafting_in_progress = "Crafting %{item}...",
        required_blueprint = "Blueprint required"
    },
    menu = {
        crafting_menu = "Crafting Menu",
        close_menu = "Close Menu",
        craft_item = "Craft Item",
        required_materials = "Required Materials",
        crafting_time = "Crafting Time: %{time} seconds"
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
