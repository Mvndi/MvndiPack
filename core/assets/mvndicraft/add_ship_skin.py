#!/usr/bin/env python3
import os
import sys
import json
import copy

# i grok'd this idek man

def replace_in_obj(obj, old, new):
    if isinstance(obj, str):
        return obj.replace(old, new)
    elif isinstance(obj, dict):
        return {k: replace_in_obj(v, old, new) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [replace_in_obj(item, old, new) for item in obj]
    return obj


def main():
    if len(sys.argv) < 4:
        print("Usage: python add_ship_skin.py <ship> <part> <skin1> [skin2] ...")
        sys.exit(1)

    ship = sys.argv[1].lower()
    part_input = sys.argv[2].lower()
    is_mast = part_input in {"mast", "sail"}
    skins = sys.argv[3:]

    target_parts = ["mast"] if is_mast else ["bow", "hull", "stern"]

    script_dir = os.path.dirname(os.path.abspath(__file__))
    item_path = os.path.join(script_dir, "items", "ships", f"{ship}.json")

    if not os.path.exists(item_path):
        print(f"Ship not found: {ship}")
        sys.exit(1)

    with open(item_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    indices = {"bow": 0, "hull": 1, "mast": 2, "stern": 3}

    for skin in skins:
        skin = skin.strip()
        if not skin:
            continue

        print(f"Adding skin: {skin}")

        for part in target_parts:
            idx = indices[part]
            model_dir = os.path.join(
                script_dir, "models", "vehicles", "ships", ship, part
            )

            src_dir = os.path.join(model_dir, "test")
            if not os.path.exists(src_dir):
                src_dir = os.path.join(model_dir, "default")

            if not os.path.exists(src_dir):
                print(f"  No source folder for {part}")
                continue

            dst_dir = os.path.join(model_dir, skin)

            if os.path.exists(dst_dir):
                print(f"  {part}/{skin} already exists, skipping files")
            else:
                os.makedirs(dst_dir, exist_ok=True)

                for root, _, files in os.walk(src_dir):
                    rel = os.path.relpath(root, src_dir)
                    out_dir = os.path.join(dst_dir, rel) if rel != "." else dst_dir
                    os.makedirs(out_dir, exist_ok=True)

                    for file in files:
                        if not file.endswith(".json"):
                            continue

                        src_file = os.path.join(root, file)
                        dst_file = os.path.join(out_dir, file)

                        with open(src_file, "r", encoding="utf-8") as f:
                            model_data = json.load(f)

                        base_name = file[:-5]
                        rel_path = (
                            os.path.join(rel, base_name) if rel != "." else base_name
                        )

                        new_model = {
                            "parent": f"mvndicraft:vehicles/ships/{ship}/{part}/default/{rel_path}"
                        }

                        if "textures" in model_data:
                            tex = {}
                            for k, v in model_data["textures"].items():
                                if v.endswith("/default") or v.endswith("/test"):
                                    v = v.rsplit("/", 1)[0] + "/" + skin
                                tex[k] = v
                            new_model["textures"] = tex

                        with open(dst_file, "w", encoding="utf-8") as f:
                            json.dump(new_model, f, indent=2)

                print(f"  Created models for {part}/{skin}")

            # JSON entry in item file
            cases = data["model"]["models"][idx]["cases"]

            if any(c.get("when", "").lower() == skin.lower() for c in cases):
                print(f"  {skin} already in JSON")
                continue

            # Use the SECOND case as template (index 1) — this is the first real custom skin
            template = cases[1]

            old_name = template["when"]
            new_case = copy.deepcopy(template)
            new_case = replace_in_obj(new_case, old_name, skin)
            new_case["when"] = skin

            cases.append(new_case)
            print(f"  Added {skin} to item JSON")

    with open(item_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print("All done")


if __name__ == "__main__":
    main()
