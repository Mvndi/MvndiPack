# this doesnt do the equipment files
import os
import json

ARMOR_TYPES = {
    "full_plate": ["_blue_gold", "_rust"],
    "half_plate": ["_rust"],
    "surcoated_hauberk": ["_black"], # _overlay
    "allantica": ["_iron", "_brass_iron", "_blue_gold"],
    "round_plate": ["", "_black", "_black_gold", "_rust", "_blue", "_brass", "_gold", "_gold_iron"],
}

def create_item_file(item_name, armor_type):
    item_content = {
        "model": {
            "type": "minecraft:model",
            "model": f"mvndicraft:item/armor/{item_name}_{armor_type}"
        }
    }

    os.makedirs(os.path.dirname(f"items/{item_name}_{armor_type}.json"), exist_ok=True)
    with open(f"items/{item_name}_{armor_type}.json", 'w') as file:
        json.dump(item_content, file, indent=2)

def create_model_json(item_name, armor_type):
    parent = "item/chestplate_layer1" if armor_type == "chest" else "item/leggings_layer1"
    texture_prefix = "humanoid" if armor_type == "chest" else "humanoid_leggings"
    texture_type = "chestplate" if armor_type == "chest" else "leggings"

    model_json = {
        "parent": parent,
        "textures": {
            texture_type: f"mvndicraft:entity/equipment/{texture_prefix}/{item_name}",
            "layer1": f"mvndicraft:entity/equipment/{texture_prefix}/{item_name}",
            "particle": f"mvndicraft:entity/equipment/{texture_prefix}/{item_name}"
        }
    }

    os.makedirs(os.path.dirname(f"models/item/armor/{item_name}_{armor_type}.json"), exist_ok=True)
    with open(f"models/item/armor/{item_name}_{armor_type}.json", 'w') as file:
        json.dump(model_json, file, indent=2)

def process_armor_items():
    for base_name, variants in ARMOR_TYPES.items():
        for variant in variants:
            item_name = f"{base_name}{variant}"
            for armor_type in ["chest", "leggings"]:
                create_item_file(item_name, armor_type)
                print(f"Created/Updated item file for {item_name}_{armor_type}")

                create_model_json(item_name, armor_type)
                print(f"Created/Updated model JSON for {item_name}_{armor_type}")

process_armor_items()
print("Model generation complete!")
