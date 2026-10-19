#!/usr/bin/env python3
"""Run the current V36 regression suite with isolated user data and retained logs."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

TESTS = [
    "v36/test_saves", "v36/test_los", "v36/test_isolation", "v36/test_contract",
    "v36/test_ui", "v36/test_hidden_worlds", "test_strict0833", "test_isolation0835",
    "test_release0830", "test_artillery0823", "test_revision0830", "test_weapons",
    "test_combat_routes", "test_exchange_assault", "test_formations08", "test_positions_results",
    "test_multi_objectives", "test_multi_objectives_ui", "test_cavalry085", "test_exact_intel087",
    "test_support0820", "test_ai_compat0833", "test_regimental0835_ui", "test_river0814",
    "test_morale_ai", "test_fog086",
]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default=shutil.which("godot"))
    parser.add_argument("--output-dir", type=Path)
    parser.add_argument("--timeout", type=int, default=180)
    parser.add_argument("--ai", action="store_true", help="Also run the three active simulations and replay/diagnosis")
    parser.add_argument("--only", nargs="+", choices=TESTS, help="Run selected regression tests")
    args = parser.parse_args()
    if not args.godot:
        parser.error("Provide --godot pointing to Godot 4.5.1")
    project = Path(__file__).resolve().parents[2]
    output = args.output_dir or Path(tempfile.mkdtemp(prefix="1870-v36-tests-"))
    output = output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    for directory in [output / "cache", output / "config"]:
        directory.mkdir(parents=True, exist_ok=True)
    version_env = os.environ.copy()
    version_env.update(XDG_CACHE_HOME=str(output / "cache"), XDG_CONFIG_HOME=str(output / "config"))
    version = subprocess.check_output([args.godot, "--version"], env=version_env, text=True).strip()
    if not version.startswith("4.5.1."):
        parser.error("Godot 4.5.1 required, found " + version)
    print("Logs:", output, flush=True)
    results = []
    commands = [("import", ["--headless", "--editor", "--import", "--quit"])]
    for name in args.only or TESTS:
        options = ["--headless", "--script", "res://tests/" + name + ".gd"]
        if name == "test_river0814":
            options += ["--", "--quick"]
        commands.append((name, options))
    if args.ai:
        for label in ["AB_active", "C_turn12", "E_final"]:
            commands.append((label, ["--headless", "--script", "res://tests/v36/test_ai_active.gd", "--", label]))
        for name in ["test_ai_replay", "test_ai_diagnosis"]:
            commands.append((name, ["--headless", "--script", "res://tests/v36/" + name + ".gd"]))
    for name, options in commands:
        env = os.environ.copy()
        # Save files and editor/audio caches are outside the source tree.
        env.update(XDG_DATA_HOME=str(output / "runtime" / name.replace("/", "_")),
                   XDG_CACHE_HOME=str(output / "cache"), XDG_CONFIG_HOME=str(output / "config"))
        command = [args.godot, "--path", str(project)] + options
        timeout = max(args.timeout, 900) if name in ["AB_active", "C_turn12", "E_final"] else args.timeout
        try:
            run = subprocess.run(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                 text=True, timeout=timeout)
            code, log = run.returncode, run.stdout
        except subprocess.TimeoutExpired as error:
            code = 124
            log = error.stdout or b""
            if isinstance(log, bytes):
                log = log.decode(errors="replace")
        failures = [line for line in log.splitlines()
                    if any(token in line for token in ["FAIL", "SCRIPT ERROR", "Parse Error", "ERROR:"])]
        (output / (name.replace("/", "_") + ".log")).write_text(log)
        result = {"test": name, "exit": code, "errors": failures, "command": command}
        results.append(result)
        (output / "results.json").write_text(json.dumps({"godot": version, "results": results}, indent=2))
        print(name, "PASS" if code == 0 and not failures else "FAIL", flush=True)
        if name == "import" and (code != 0 or failures):
            break
    return int(any(r["exit"] != 0 or r["errors"] for r in results))


if __name__ == "__main__":
    raise SystemExit(main())
