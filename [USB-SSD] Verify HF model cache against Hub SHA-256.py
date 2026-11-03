"""Verify files in a Hugging Face hub cache (snapshots stored as real files) against the SHA-256 the Hub publishes
for each LFS file at that exact revision. Usage: python -I verify_hf_snapshots.py <hub dir>"""
import hashlib
import json
import pathlib
import sys
import urllib.request

hub = pathlib.Path(sys.argv[1])
ok = bad = unknown = 0
total = 0
for repo_dir in sorted(hub.glob("models--*")):
    repo = repo_dir.name[len("models--"):].replace("--", "/")
    for snap in sorted((repo_dir / "snapshots").glob("*")):
        files = [p for p in snap.rglob("*") if p.is_file()]
        if not files:
            continue
        url = f"https://huggingface.co/api/models/{repo}/tree/{snap.name}?recursive=true"
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                tree = json.load(r)
        except Exception as e:  # repo gone, renamed or private
            print(f"NO-API {repo}@{snap.name[:8]}: {e}", flush=True)
            unknown += len(files)
            continue
        want = {t["path"]: t["lfs"]["oid"] for t in tree if t.get("type") == "file" and t.get("lfs")}
        for p in files:
            rel = p.relative_to(snap).as_posix()
            if rel not in want:
                unknown += 1  # small non-LFS file: the Hub only lists a git SHA-1 for those
                continue
            h = hashlib.sha256()
            with open(p, "rb") as f:
                while chunk := f.read(16 << 20):
                    h.update(chunk)
            total += p.stat().st_size
            if h.hexdigest() == want[rel]:
                ok += 1
            else:
                bad += 1
                print(f"MISMATCH {repo}/{rel}", flush=True)
        print(f"checked {repo}@{snap.name[:8]}", flush=True)
print(f"RESULT ok={ok} mismatch={bad} not-checkable={unknown} verified={total / 2**30:.1f} GiB")
