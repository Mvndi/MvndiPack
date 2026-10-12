import argparse
import copy
import io
import json
from collections import Counter
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "core" / "assets"
NAMESPACE = ASSETS / "mvndicraft"
CONFIG_PATH = Path(__file__).with_name("trim_generation_config.json")
LEGACY_SOURCES = Path(__file__).with_name("trim_sources")


def asset_path(identifier, category, extension):
    namespace, name = identifier.split(":", 1) if ":" in identifier else ("minecraft", identifier)
    return ASSETS / namespace / category / (name + extension)


def case_key(case):
    return json.dumps(case["when"], sort_keys=True)


class TrimGenerator:
    def __init__(self, config):
        self.config = config
        self.pending = {}
        self.stats = Counter()
        self.unresolved = set()
        self.palette_cache = {}

    def read_json(self, path):
        return json.loads(self.pending.get(path, path.read_bytes() if path.exists() else b"null"))

    def stage_json(self, path, data, category):
        if self.read_json(path) == data:
            return
        self.pending[path] = (json.dumps(data, indent=2) + "\n").encode()
        self.stats[category] += 1

    def exists(self, path):
        return path in self.pending or path.exists()

    def palette(self, name):
        if name not in self.palette_cache:
            path = ASSETS / "minecraft" / "textures" / "trims" / "color_palettes" / (name + ".png")
            with Image.open(path) as image:
                self.palette_cache[name] = list(image.convert("RGB").getdata())
        return self.palette_cache[name]

    def recolor(self, source, material):
        original = self.palette("trim_palette")
        replacement = self.palette(material)
        if len(original) != len(replacement):
            raise ValueError(f"Palette length mismatch: {material}")
        colors = dict(zip(original, replacement))
        with Image.open(source) as image:
            result = image.convert("RGBA")
        pixels = []
        for pixel in result.getdata():
            rgb, alpha = pixel[:3], pixel[3]
            if alpha:
                nearest = min(original, key=lambda color: sum((a - b) ** 2 for a, b in zip(rgb, color)))
                rgb = colors[nearest]
            pixels.append((*rgb, alpha))
        result.putdata(pixels)
        output = io.BytesIO()
        result.save(output, format="PNG")
        return output.getvalue()

    def trim_texture(self, folder, pattern_asset, material):
        namespace, pattern = pattern_asset.split(":", 1)
        identifier = f"{namespace}:entity/equipment/{folder}/trims/{pattern}_{material}"
        target = asset_path(identifier, "textures", ".png")
        if self.exists(target):
            return identifier
        source = asset_path(f"{namespace}:trims/entity/{folder}/{pattern}", "textures", ".png")
        if not source.exists():
            source = LEGACY_SOURCES / folder / (pattern + ".png")
        if not source.exists():
            return None
        self.pending[target] = self.recolor(source, material)
        self.stats["textures generated"] += 1
        return identifier

    def validate_model(self, identifier, model):
        parent = asset_path(model["parent"], "models", ".json")
        if not self.exists(parent):
            raise ValueError(f"Missing parent for {identifier}: {model['parent']}")
        for name, texture in model.get("textures", {}).items():
            if texture.startswith("#"):
                continue
            if not self.exists(asset_path(texture, "textures", ".png")):
                raise ValueError(f"Missing {name} texture for {identifier}: {texture}")

    def make_model(self, item_id, case):
        identifier = case["model"]["model"]
        target = asset_path(identifier, "models", ".json")
        existing = self.read_json(target)
        if existing is not None:
            # Working models and their material-specific colors remain untouched.
            self.validate_model(identifier, existing)
            return True
        base_id = f"mvndicraft:item/armor/{item_id}"
        base = self.read_json(asset_path(base_id, "models", ".json"))
        if base is None:
            raise ValueError(f"Missing base model: {base_id}")
        folder = "humanoid_leggings" if item_id.endswith("_leggings") else "humanoid"
        material = case["when"]["material"].split(":", 1)[1]
        pattern = case["when"]["pattern"]
        texture = self.trim_texture(folder, pattern, material)
        if texture is None:
            self.unresolved.add(f"{item_id}: {pattern}")
            return False
        model = copy.deepcopy(base)
        model["parent"] = model["parent"].replace("layer1", "layer2")
        if model["parent"] == base["parent"]:
            raise ValueError(f"No trim-layer parent for {item_id}: {base['parent']}")
        model["textures"]["layer2"] = texture
        self.validate_model(identifier, model)
        self.stage_json(target, model, "models generated")
        return True

    def model_node(self, item_id, pattern, material, dye_default):
        pattern_name = pattern.split(":", 1)[1]
        node = {"type": "minecraft:model", "model": f"mvndicraft:item/armor/trims/{item_id}_{pattern_name}_{material}"}
        if dye_default is not None:
            node["tints"] = [{"type": "minecraft:dye", "default": dye_default}]
        return node

    def add_live_cases(self, item, group):
        item_id = item["id"]
        path = NAMESPACE / "items" / (item_id + ".json")
        data = self.read_json(path)
        if data is None:
            raise ValueError(f"Missing item definition: {item_id}")
        selector = data["model"]
        if selector.get("component") != "minecraft:trim":
            selector = {"type": "minecraft:select", "property": "minecraft:component", "component": "minecraft:trim", "cases": [], "fallback": selector}
            data["model"] = selector
        dye_default = item["dye_default"]
        fallback = selector["fallback"]
        if dye_default is not None:
            fallback.setdefault("tints", [{"type": "minecraft:dye", "default": dye_default}])
        if fallback.get("tints"):
            dye_default = fallback["tints"][0].get("default", dye_default)
        cases = {case_key(case): case for case in selector["cases"]}
        for pattern in group["patterns"].values():
            for material in self.config["materials"]:
                when = {"material": f"minecraft:{material}", "pattern": pattern}
                key = json.dumps(when, sort_keys=True)
                case = cases.get(key, {"when": when, "model": self.model_node(item_id, pattern, material, dye_default)})
                if not self.make_model(item_id, case):
                    raise ValueError(f"No source texture for live combination: {item_id}, {pattern}, {material}")
                if dye_default is not None:
                    case["model"].setdefault("tints", [{"type": "minecraft:dye", "default": dye_default}])
                if key not in cases:
                    selector["cases"].append(case)
                    cases[key] = case
                    self.stats["selector cases added"] += 1
        self.stage_json(path, data, "item selectors updated")

    def repair_legacy_cases(self):
        for path in sorted((NAMESPACE / "items").glob("*.json")):
            data = self.read_json(path)
            selector = data["model"]
            if selector.get("component") != "minecraft:trim":
                continue
            if not (NAMESPACE / "models" / "item" / "armor" / (path.stem + ".json")).exists():
                continue
            for case in selector["cases"]:
                self.make_model(path.stem, case)

    def build(self):
        for group in self.config["groups"].values():
            for item in group["items"]:
                self.add_live_cases(item, group)
        self.repair_legacy_cases()

    def write(self):
        for path, content in self.pending.items():
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(content)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true", help="Apply the validated generation plan; default is a dry run.")
    arguments = parser.parse_args()
    generator = TrimGenerator(json.loads(CONFIG_PATH.read_text()))
    generator.build()
    print(json.dumps(dict(generator.stats), indent=2))
    if generator.unresolved:
        print("Legacy cases left unchanged because matching artwork is unavailable:")
        by_item = Counter(case.split(": ", 1)[0] for case in generator.unresolved)
        for item, patterns in sorted(by_item.items()):
            print(f"  {item}: {patterns} patterns")
    if arguments.write:
        generator.write()
        print(f"Wrote {len(generator.pending)} files.")
    else:
        print(f"Dry run: {len(generator.pending)} files would change. Use --write to apply.")


if __name__ == "__main__":
    main()
