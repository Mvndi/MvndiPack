from axallias_pack_packer import packer
from axallias_pack_packer import typical_banlists


rp = packer.Pack(
    'C:/Users/admin/AppData/Roaming/.minecraft/resourcepacks/mvndicraft.zip', packer.Pack.RESOURCEPACK
)

rp.add_pack(
    extention_banlist=typical_banlists.RESOURCEPACK_EXTENTIONS,
    path_keyword_banlist=typical_banlists.TYPICAL_PATH_KEYWORDS,
    filename_keyword_banlist=typical_banlists.TYPICAL_FILENAME_KEYWORDS
)