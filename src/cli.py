import argparse
import subprocess

from utils.folders import create_user_directory


def run_cli(argv=None) -> int:
    """Unified command-line interface for common tasks."""
    parser = argparse.ArgumentParser(description="2025_BASIC management tool")
    subparsers = parser.add_subparsers(dest="command")

    subparsers.add_parser("run", help="Launch the GUI")
    subparsers.add_parser("test", help="Run the test suite")
    user_parser = subparsers.add_parser("create-user", help="Create a user folder")
    user_parser.add_argument("username")
    subparsers.add_parser("list-plugins", help="Show available plugins")
    subparsers.add_parser("cleanup", help="Remove cached bytecode")

    args = parser.parse_args(argv)

    if args.command == "run":
        from gui.app import run as run_gui

        return run_gui()
    if args.command == "test":
        return subprocess.call(["pytest", "-q"])
    if args.command == "create-user":
        path = create_user_directory(args.username)
        print(f"Created {path}")
        return 0
    if args.command == "list-plugins":
        from gui.app import load_plugins

        plugins = [p.__name__ for p in load_plugins()]
        if plugins:
            print("\n".join(plugins))
        else:
            print("No plugins installed")
        return 0
    if args.command == "cleanup":
        from utils.cleanup import cleanup_directory

        cleanup_directory()
        print("Removed __pycache__ folders")
        return 0

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(run_cli())
