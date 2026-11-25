import json

from meilisync.progress.file import File


async def test_set_replaces_existing_progress_without_leaving_temp_file(tmp_path):
    path = tmp_path / "progress.json"
    progress = File(path=str(path))

    await progress.set(start_lsn=1)
    await progress.set(start_lsn=2)

    assert json.loads(path.read_text()) == {"start_lsn": 2}
    assert await progress.get() == {"start_lsn": 2}
    assert [p.name for p in tmp_path.iterdir()] == ["progress.json"]


async def test_failed_write_keeps_previous_progress(tmp_path, monkeypatch):
    path = tmp_path / "progress.json"
    progress = File(path=str(path))
    await progress.set(start_lsn=1)

    def fail_dumps(_):
        raise RuntimeError("write failed")

    monkeypatch.setattr("meilisync.progress.file.json.dumps", fail_dumps)
    try:
        await progress.set(start_lsn=2)
    except RuntimeError:
        pass

    assert await progress.get() == {"start_lsn": 1}
