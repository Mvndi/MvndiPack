import json
from pathlib import Path

def main():
    base_dir = Path("mvndicraft")
    models_dir = base_dir / "models" / "armor" / "horse"
    items_dir = base_dir / "items"
    models_dir.mkdir(parents=True, exist_ok=True)
    items_dir.mkdir(parents=True, exist_ok=True)

    suffixes = [
        "gambeson",
        "chainmail",
        "chainmail_gold",
        "chainmail_brass",
        "chainmail_brass_iron",
        "scale",
        "scale_gold",
        "scale_brass",
        "scale_blue",
        "full_plate",
        "full_plate_half_golden",
        "full_plate_black",
        "full_plate_blue",
        "full_plate_blue_gold",
        "full_plate_brass",
        "full_plate_gold",
        "full_plate_rust",
    ]

    for suffix in suffixes:
        model_data = {
            "parent": "mvndicraft:armor/horse/template_horse_armor",
            "textures": {
                "0": f"mvndicraft:entity/equipment/horse_body/{suffix}",
                "particle": f"mvndicraft:entity/equipment/horse_body/{suffix}"
            }
        }
        model_file = models_dir / f"{suffix}.json"
        with open(model_file, "w") as f:
            json.dump(model_data, f, indent=2)

        item_data = {
            "model": {
                "type": "minecraft:model",
                "model": f"mvndicraft:armor/horse/{suffix}"
            }
        }
        item_file = items_dir / f"{suffix}.json"
        with open(item_file, "w") as f:
            json.dump(item_data, f, indent=2)

    print("asd")

if __name__ == "__main__":
    main()
