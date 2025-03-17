let recipes = [];
let categories = [];
let inventory = {};
let selectedCategory = null;
let selectedItem = null;
let useSkills = false;
let craftingInProgress = false;

// Initialize the UI
document.addEventListener("DOMContentLoaded", function () {
  // Hide the container initially
  document.getElementById("crafting-container").style.display = "none";

  // Close button event
  document.getElementById("close-btn").addEventListener("click", function () {
    closeMenu();
  });

  // Listen for NUI messages
  window.addEventListener("message", function (event) {
    const data = event.data;

    switch (data.action) {
      case "open":
        openMenu(data);
        break;
      case "updateInventory":
        updateInventory(data.inventory);
        break;
      case "craftingProgress":
        showCraftingProgress(data.item, data.label, data.time);
        break;
      case "craftingResult":
        showCraftingResult(data.success, data.item, data.label);
        break;
      case "craftingCanceled":
        hideCraftingProgress();
        break;
    }
  });

  // Close on escape key
  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      closeMenu();
    }
  });

  // Tablet home button
  document
    .querySelector(".tablet-home-button")
    .addEventListener("click", function () {
      closeMenu();
    });
});

// Open the crafting menu
function openMenu(data) {
  recipes = data.recipes;
  categories = data.categories;
  inventory = data.inventory;
  useSkills = data.useSkills;

  // Show the table name if provided
  if (data.tableLabel) {
    document.querySelector(".crafting-title h1").textContent = data.tableLabel;
  }

  // Show the container
  const container = document.getElementById("crafting-container");
  container.style.display = "flex";
  setTimeout(() => {
    container.classList.add("visible");
  }, 10);

  // Render categories
  renderCategories();

  // Show skill if enabled
  if (useSkills) {
    document.getElementById("skill-container").style.display = "flex";
    updateSkillDisplay();
  } else {
    document.getElementById("skill-container").style.display = "none";
  }

  // Add tablet animation
  document.querySelector(".tablet-frame").classList.add("fade-in");
}

// Close the crafting menu
function closeMenu() {
  const container = document.getElementById("crafting-container");
  container.classList.remove("visible");

  setTimeout(() => {
    container.style.display = "none";
    // Send close event to client
    fetch("https://RaySist-Crafting/close", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({}),
    });
  }, 300);
}

// Render categories
function renderCategories() {
  const categoriesList = document.getElementById("categories-list");
  categoriesList.innerHTML = "";

  categories.forEach((category) => {
    const categoryElement = document.createElement("div");
    categoryElement.className = "category-item";
    categoryElement.innerHTML = `
            <i class="fas fa-${category.icon}"></i>
            <span>${category.label}</span>
        `;

    categoryElement.addEventListener("click", function () {
      // Remove active class from all categories
      document.querySelectorAll(".category-item").forEach((el) => {
        el.classList.remove("active");
      });

      // Add active class to clicked category
      categoryElement.classList.add("active");

      // Set selected category and render items
      selectedCategory = category.name;
      renderItems();
    });

    categoriesList.appendChild(categoryElement);
  });

  // Select first category by default
  if (categories.length > 0) {
    categoriesList.firstChild.classList.add("active");
    selectedCategory = categories[0].name;
    renderItems();
  }
}

// Render items for selected category
function renderItems() {
  const itemsList = document.getElementById("items-list");
  itemsList.innerHTML = "";

  // Filter recipes by selected category
  const categoryRecipes = recipes.filter(
    (recipe) => recipe.category === selectedCategory,
  );

  if (categoryRecipes.length === 0) {
    itemsList.innerHTML =
      '<div class="no-items">No items in this category</div>';
    return;
  }

  categoryRecipes.forEach((recipe) => {
    // Check if player has all ingredients
    let canCraft = true;
    for (const ingredient of recipe.ingredients) {
      const playerHas = inventory[ingredient.item]
        ? inventory[ingredient.item].amount
        : 0;
      if (playerHas < ingredient.amount) {
        canCraft = false;
        break;
      }
    }

    // Check blueprint if required
    if (recipe.requireBlueprint) {
      const hasBlueprint = inventory[recipe.blueprintItem] ? true : false;
      if (!hasBlueprint) {
        canCraft = false;
      }
    }

    const itemElement = document.createElement("div");
    itemElement.className = `item-card ${canCraft ? "can-craft" : ""}`;

    // Get category label
    const category = categories.find((cat) => cat.name === recipe.category);
    const categoryLabel = category ? category.label : recipe.category;

    itemElement.innerHTML = `
            <div class="item-icon">
                <i class="fas fa-${getIconForItem(recipe.name)}"></i>
            </div>
            <div class="item-info">
                <div class="item-name">${recipe.label}</div>
                <div class="item-category">${categoryLabel}</div>
            </div>
        `;

    itemElement.addEventListener("click", function () {
      // Remove active class from all items
      document.querySelectorAll(".item-card").forEach((el) => {
        el.classList.remove("active");
      });

      // Add active class to clicked item
      itemElement.classList.add("active");

      // Set selected item and render details
      selectedItem = recipe.name;
      renderItemDetails(recipe);
    });

    itemsList.appendChild(itemElement);
  });

  // Clear item details
  document.getElementById("item-details").innerHTML = `
        <div class="no-item-selected">
            <p>Select an item to view details</p>
        </div>
    `;

  selectedItem = null;
}

// Render item details
function renderItemDetails(recipe) {
  const itemDetails = document.getElementById("item-details");

  // Check if player has all ingredients
  let canCraft = true;
  const ingredientsHtml = recipe.ingredients
    .map((ingredient) => {
      const playerHas = inventory[ingredient.item]
        ? inventory[ingredient.item].amount
        : 0;
      const hasEnough = playerHas >= ingredient.amount;

      if (!hasEnough) {
        canCraft = false;
      }

      return `
            <div class="ingredient-item ${hasEnough ? "has-enough" : ""}">
                <div class="ingredient-name">
                    <i class="fas fa-${getIconForIngredient(ingredient.item)}"></i>
                    <span>${ingredient.label}</span>
                </div>
                <div class="ingredient-amount ${hasEnough ? "" : "not-enough"}">
                    ${playerHas}/${ingredient.amount}
                </div>
            </div>
        `;
    })
    .join("");

  // Check if player has blueprint if required
  let blueprintHtml = "";
  if (recipe.requireBlueprint) {
    const hasBlueprint = inventory[recipe.blueprintItem] ? true : false;

    if (!hasBlueprint) {
      canCraft = false;
    }

    blueprintHtml = `
            <div class="blueprint-required ${hasBlueprint ? "has-blueprint" : ""}">
                <i class="fas fa-scroll"></i>
                <span>Blueprint Required ${hasBlueprint ? "(Available)" : "(Missing)"}</span>
            </div>
        `;
  }

  // Show amount that will be crafted for ammo
  const craftAmount = recipe.category === "ammo" ? 10 : 1;
  const craftAmountText = craftAmount > 1 ? `(x${craftAmount})` : "";

  itemDetails.innerHTML = `
        <div class="item-detail-card">
            <div class="item-detail-header">
                <div class="item-detail-icon">
                    <i class="fas fa-${getIconForItem(recipe.name)}"></i>
                </div>
                <div class="item-detail-title">
                    <h2>${recipe.label} ${craftAmountText}</h2>
                    <p>${getCategoryLabel(recipe.category)}</p>
                </div>
            </div>

            <div class="item-detail-section">
                <div class="section-title">
                    <i class="fas fa-list"></i>
                    <span>Required Materials</span>
                </div>
                <div class="ingredients-list">
                    ${ingredientsHtml}
                </div>
            </div>

            <div class="item-detail-section">
                <div class="section-title">
                    <i class="fas fa-clock"></i>
                    <span>Crafting Information</span>
                </div>
                <div class="craft-time">
                    <i class="fas fa-hourglass-half"></i>
                    <span>Crafting Time: ${recipe.time} seconds</span>
                </div>
                ${blueprintHtml}
            </div>

            <button class="craft-button ${canCraft ? "can-craft" : ""}" ${canCraft && !craftingInProgress ? "" : "disabled"} onclick="craftItem('${recipe.name}')">
                ${craftingInProgress ? "Crafting in Progress..." : "Craft Item"}
            </button>
        </div>
    `;
}

// Craft item
function craftItem(item) {
  if (craftingInProgress) return;

  fetch("https://RaySist-Crafting/craftItem", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      item: item,
    }),
  });

  // Close menu immediately when crafting starts
  closeMenu();
}

// Show crafting progress
function showCraftingProgress(item, label, time) {
  craftingInProgress = true;

  // Update any craft buttons
  const craftButtons = document.querySelectorAll(".craft-button");
  craftButtons.forEach((button) => {
    button.disabled = true;
    button.textContent = "Crafting in Progress...";
  });
}

// Hide crafting progress
function hideCraftingProgress() {
  craftingInProgress = false;

  // Update craft buttons
  const craftButtons = document.querySelectorAll(".craft-button");
  craftButtons.forEach((button) => {
    button.disabled = false;
    button.textContent = "Craft Item";
  });
}

// Show crafting result
function showCraftingResult(success, item, label) {
  craftingInProgress = false;
}

// Update inventory
function updateInventory(newInventory) {
  inventory = newInventory;

  // Update skill display if enabled
  if (useSkills) {
    updateSkillDisplay();
  }

  // Re-render item details if an item is selected
  if (selectedItem) {
    const recipe = recipes.find((r) => r.name === selectedItem);
    if (recipe) {
      renderItemDetails(recipe);
    }
  }

  // Re-render items to update the "can-craft" class
  if (selectedCategory) {
    renderItems();
  }
}

// Update skill display
function updateSkillDisplay() {
  if (!useSkills) return;

  const skillLevel = inventory.skill || 0;
  document.getElementById("skill-level").textContent = skillLevel.toFixed(1);
  document.getElementById("skill-progress").style.width =
    `${Math.min(skillLevel, 100)}%`;
}

// Get category label
function getCategoryLabel(categoryName) {
  const category = categories.find((cat) => cat.name === categoryName);
  return category ? category.label : categoryName;
}

// Get icon for item
function getIconForItem(itemName) {
  // Map item names to appropriate Font Awesome icons
  const iconMap = {
    weapon_pistol: "gun",
    weapon_smg: "gun",
    weapon_rifle: "gun",
    pistol_ammo: "bomb",
    smg_ammo: "bomb",
    rifle_ammo: "bomb",
    shotgun_ammo: "bomb",
    lockpick: "key",
    advancedlockpick: "key",
    bandage: "band-aid",
    medkit: "kit-medical",
    armor: "shield",
    repairkit: "wrench",
    radio: "walkie-talkie",
    phone: "mobile",
    binoculars: "binoculars",
    drill: "drill",
    hackingdevice: "laptop-code",
  };

  return iconMap[itemName] || "box";
}

// Get icon for ingredient
function getIconForIngredient(itemName) {
  // Map ingredient names to appropriate Font Awesome icons
  const iconMap = {
    metalscrap: "recycle",
    steel: "cubes",
    rubber: "ring",
    plastic: "prescription-bottle",
    copper: "coins",
    aluminum: "square",
    iron: "magnet",
    glass: "glass",
    electronics: "microchip",
    cloth: "tshirt",
    wood: "tree",
    gunpowder: "fire",
    alcohol: "wine-bottle",
    water: "water",
  };

  return iconMap[itemName] || "box";
}
