import json

import aiofiles
import aiofiles.os

from meilisync.enums import ProgressType
from meilisync.progress import Progress


class File(Progress):
    type = ProgressType.file

    def __init__(
        self,
        path: str = "progress.json",
    ):
        super().__init__(path=path)
        self.path = path

    async def set(self, **kwargs):
        tmp_path = f"{self.path}.tmp"
        async with aiofiles.open(tmp_path, "w") as f:
            await f.write(json.dumps(kwargs))
        await aiofiles.os.replace(tmp_path, self.path)

    async def get(self):
        try:
            async with aiofiles.open(self.path) as f:
                return json.loads(await f.read())
        except FileNotFoundError:
            return None
