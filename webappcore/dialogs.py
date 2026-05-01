"""
Pure-Python helper functions used by the JS bridge.
"""

import os
import subprocess
from os.path import relpath


def get_exe_list(target_dir: str) -> list[dict]:
    """Walk target_dir for .exe files and return list of {relative, full} paths."""
    results: list[dict] = []
    try:
        for root, _dirs, files in os.walk(target_dir):
            for f in files:
                if f.lower().endswith(".exe"):
                    full = os.path.join(root, f)
                    results.append({"relative": relpath(full, target_dir), "full": full})
    except Exception as e:
        print(f"Error searching for executables: {e}")
    return results


def launch_windows_installer(launcher_path: str) -> int:
    """Launch an exe on Windows, block until complete."""
    launcher_dir = os.path.dirname(launcher_path)
    print(f"Executing (Windows): {launcher_path}")
    proc = subprocess.Popen([launcher_path], cwd=launcher_dir)
    proc.wait()
    return proc.returncode
