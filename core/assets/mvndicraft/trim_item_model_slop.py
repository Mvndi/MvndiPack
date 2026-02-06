import os
import json
from PIL import Image

# Hardcoded from the provided YAML
armors = {
    'surcoated_hauberk': {
        'base_items': ['surcoated_hauberk_chest'],
        'allowed_patterns': [
            'gambeson_cross', 'gambeson_horizontal', 'gambeson_vertical', 'gambeson_fancy_cross',
            'gambeson_lorraine_cross', 'gambeson_x', 'gambeson_four', 'gambeson_plus',
            'gambeson_y', 'gambeson_half', 'gambeson_t', 'gambeson_hash', 'gambeson_tree'
        ]
    },
    'surcoated_hauberk_leggings': {
        'base_items': ['surcoated_hauberk_leggings'],
        'allowed_patterns': ['gambeson_vertical', 'gambeson_strip']
    },
    # 'half_plate': {
    #     'base_items': ['half_plate_chest'],
    #     'allowed_patterns': [
    #         'half_plate_cup', 'half_plate_horizontal', 'half_plate_quarter', 'half_plate_chess',
    #         'half_plate_triangle', 'half_plate_cross', 'half_plate_vertical'
    #     ]
    # },
    # 'round_plate': {
    #     'base_items': ['round_plate_chest'],
    #     'allowed_patterns': [
    #         'round_plate_cross', 'round_plate_quarter', 'round_plate_cross_iron', 'round_plate_cross_small',
    #         'round_plate_half', 'round_plate_horizontal', 'round_plate_vertical', 'round_plate_fabric'
    #     ]
    # },
    # 'full_plate': {
    #     'base_items': ['full_plate_chest'],
    #     'allowed_patterns': ['full_plate_fabric']
    # }
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
    if 'chest' in armor['base_items'][0]:
        entity_folder = 'humanoid'
    else:
        entity_folder = 'humanoid_leggings'
    trims_dir = f'textures/entity/equipment/{entity_folder}/trims'
    os.makedirs(trims_dir, exist_ok=True)
    for pattern in armor['allowed_patterns']:
        pattern_png = f'textures/trims/entity/{entity_folder}/{pattern}.png'
        if not os.path.exists(pattern_png):
            print(f'Warning: {pattern_png} does not exist')
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
for armor_key, armor in armors.items():
    is_dyeable = armor_key.startswith('surcoated_hauberk')
    default_tint = -6265536
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