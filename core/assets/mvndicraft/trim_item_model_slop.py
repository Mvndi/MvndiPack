import os
import json
from PIL import Image

# Updated from the new trims.yml
armors = {
    'gambeson': {
        'base_items': ['gambeson_chest'],
        'allowed_patterns': [
            'cross', 'gambeson_horizontal', 'gambeson_vertical', 'fancy_cross',
            'lorraine_cross', 'x', 'four', 'plus', 'y', 'half', 't', 'hash', 'tree'
        ]
    },
    'gambeson_leggings': {
        'base_items': ['gambeson_leggings'],
        'allowed_patterns': ['gambeson_vertical', 'gambeson_strip']
    },
    'surcoated_hauberk': {
        'base_items': ['surcoated_hauberk_chest'],
        'allowed_patterns': [
            'tabard_full_plate_cup', 'tabard_full_plate_horizontal', 'tabard_full_plate_quarter', 'tabard_full_plate_chess',
            'tabard_full_plate_triangle', 'full_cross', 'tabard_full_plate_vertical', 'cross', 'fancy_cross',
            'lorraine_cross', 'x', 'four', 'plus', 'y', 'half', 't', 'hash', 'tree'
        ]
    },
    'tabard_full_plate': {
        'base_items': ['tabard_full_plate_chest'],
        'allowed_patterns': [
            'tabard_full_plate_cup', 'tabard_full_plate_horizontal', 'tabard_full_plate_quarter', 'tabard_full_plate_chess',
            'tabard_full_plate_triangle', 'full_cross', 'tabard_full_plate_vertical', 'fancy_cross',
            'lorraine_cross', 'x', 'four', 'plus', 'y', 'half', 't', 'hash', 'tree', 'cross'
        ]
    },
    'cuirass': {
        'base_items': ['cuirass_chest'],
        'allowed_patterns': [
            'cuirass_cross', 'cuirass_quarter', 'cuirass_cross_iron', 'cuirass_cross_small',
            'cuirass_half', 'cuirass_horizontal', 'cuirass_vertical'
        ]
    }
}

materials = ['quartz', 'iron', 'netherite', 'redstone', 'copper', 'gold', 'emerald', 'diamond', 'lapis', 'amethyst', 'resin']

def get_closest_color(color, palette_colors):
    min_dist = float('inf')
    closest = None
    for pc in palette_colors:
        dist = sum((a - b) ** 2 for a, b in zip(color, pc))
        if dist < min_dist:
            min_dist = dist
            closest = pc
    return closest

# Load trim_palette and extract colors (assuming 8x1 horizontal)
trim_palette_path = '../minecraft/textures/trims/color_palettes/trim_palette.png'
trim_img = Image.open(trim_palette_path)
base_colors = [trim_img.getpixel((i, 0))[:3] for i in range(8)]

# Process all PNGs in textures/trims/entity/humanoid and humanoid_leggings to snap to base_colors
for folder in ['humanoid', 'humanoid_leggings']:
    dir_path = f'textures/trims/entity/{folder}'
    if not os.path.exists(dir_path):
        continue
    for filename in os.listdir(dir_path):
        if filename.endswith('.png'):
            path = os.path.join(dir_path, filename)
            img = Image.open(path)
            img = img.convert('RGBA')
            for x in range(img.width):
                for y in range(img.height):
                    px = img.getpixel((x, y))
                    if px[3] == 0:
                        continue
                    rgb = px[:3]
                    new_rgb = get_closest_color(rgb, base_colors)
                    img.putpixel((x, y), new_rgb + (px[3],))
            img.save(path)

# Create material-specific trim textures
for armor_key, armor in armors.items():
    allowed_patterns = armor['allowed_patterns']
    is_dyeable = armor_key in ['gambeson', 'gambeson_leggings', 'surcoated_hauberk', 'tabard_full_plate_full_plate']

    for base_item in armor['base_items']:
        if '_chest' in base_item:
            entity_folder = 'humanoid'
        elif '_leggings' in base_item:
            entity_folder = 'humanoid_leggings'
        else:
            continue

        trims_dir = f'textures/entity/equipment/{entity_folder}/trims'
        os.makedirs(trims_dir, exist_ok=True)

        for pattern in allowed_patterns:
            pattern_png = f'textures/trims/entity/{entity_folder}/{pattern}.png'
            if not os.path.exists(pattern_png):
                print(f'Warning: {pattern_png} does not exist - skipping for {base_item}')
                continue

            pattern_img = Image.open(pattern_png)
            pattern_img = pattern_img.convert('RGBA')

            for material in materials:
                material_path = f'../minecraft/textures/trims/color_palettes/{material}.png'
                if not os.path.exists(material_path):
                    print(f'Warning: {material_path} does not exist')
                    continue

                material_img = Image.open(material_path)
                material_colors = [material_img.getpixel((i, 0))[:3] for i in range(8)]
                color_map = dict(zip(base_colors, material_colors))

                new_img = pattern_img.copy()
                for x in range(new_img.width):
                    for y in range(new_img.height):
                        px = new_img.getpixel((x, y))
                        if px[3] == 0:
                            continue
                        rgb = px[:3]
                        if rgb not in color_map:
                            rgb = get_closest_color(rgb, base_colors)
                        new_rgb = color_map[rgb]
                        new_img.putpixel((x, y), new_rgb + (px[3],))

                output_path = os.path.join(trims_dir, f'{pattern}_{material}.png')
                new_img.save(output_path)

# Update item models and create trim models
default_tint = -6265536
for armor_key, armor in armors.items():
    is_dyeable = armor_key in ['gambeson', 'gambeson_leggings', 'surcoated_hauberk', 'tabard_full_plate_full_plate']

    for base_item in armor['base_items']:
        prefix = base_item.rsplit('_', 1)[0] + '_'
        item_type = base_item.rsplit('_', 1)[1]
        items_dir = 'items'
        variants = [f for f in os.listdir(items_dir) if f.startswith(prefix) and f.endswith(f'_{item_type}.json')]

        entity_folder = 'humanoid' if item_type == 'chest' else 'humanoid_leggings'

        for variant_file in variants:
            variant_name = variant_file[:-5]
            path = os.path.join(items_dir, variant_file)
            with open(path, 'r') as f:
                current_json = json.load(f)

            inner_model = current_json['model']
            if inner_model.get('type') == 'minecraft:select':
                fallback_model_str = inner_model['fallback']['model']
            else:
                fallback_model_str = inner_model['model']

            base_model_path = f'models/item/armor/{variant_name}.json'
            with open(base_model_path, 'r') as f:
                base_model = json.load(f)

            # Create trim models
            trims_model_dir = 'models/item/armor/trims'
            os.makedirs(trims_model_dir, exist_ok=True)

            for pattern in armor['allowed_patterns']:
                for material in materials:
                    trim_model_name = f'{variant_name}_{pattern}_{material}'
                    trim_model_path = os.path.join(trims_model_dir, f'{trim_model_name}.json')
                    trim_model = base_model.copy()
                    trim_model['parent'] = trim_model['parent'].replace("layer1", "layer2")
                    trim_model['textures']['layer2'] = f'mvndicraft:entity/equipment/{entity_folder}/trims/{pattern}_{material}'
                    with open(trim_model_path, 'w') as f:
                        json.dump(trim_model, f, indent=2)

            # Update item JSON
            cases = []
            for pattern in armor['allowed_patterns']:
                for material in materials:
                    case = {
                        'when': {
                            'material': f'minecraft:{material}',
                            'pattern': f'mvndicraft:{pattern}'
                        },
                        'model': {
                            'type': 'minecraft:model',
                            'model': f'mvndicraft:item/armor/trims/{variant_name}_{pattern}_{material}'
                        }
                    }
                    if is_dyeable:
                        case['model']['tints'] = [{'type': 'minecraft:dye', 'default': default_tint}]
                    cases.append(case)

            fallback = {
                'type': 'minecraft:model',
                'model': fallback_model_str
            }
            if is_dyeable:
                fallback['tints'] = [{'type': 'minecraft:dye', 'default': default_tint}]

            new_json = {
                'model': {
                    'type': 'minecraft:select',
                    'property': 'minecraft:component',
                    'component': 'minecraft:trim',
                    'cases': cases,
                    'fallback': fallback
                }
            }
            with open(path, 'w') as f:
                json.dump(new_json, f, indent=2)