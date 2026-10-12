import os
from pathlib import Path

from axallias_pack_packer import packer
from axallias_pack_packer import typical_banlists


# The packer reads its input from the working directory.
os.chdir(Path(__file__).resolve().parents[2] / "core")

rp = packer.Pack(
    str(Path(__file__).resolve().parents[2] / "mvndicraft.zip"), packer.Pack.RESOURCEPACK
)

rp.add_pack(
    extention_banlist=typical_banlists.RESOURCEPACK_EXTENTIONS,
    path_keyword_banlist=typical_banlists.TYPICAL_PATH_KEYWORDS,
    filename_keyword_banlist=typical_banlists.TYPICAL_FILENAME_KEYWORDS
)