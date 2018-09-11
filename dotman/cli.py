USAGE = """usage: dotman <command>

commands:
    config          Set the default config location
    install         Run a package script
    reinstall       Run a package script again
    upgrade         Run a package script in upgrade mode"""

"""
dotman [-c <path> | --config=<path>] run [-f | --force] [-F | --force-all] <name>...
"""

SUBCOMMAND_USAGE = {
    "config": "usage: dotman config [<path>]",
    "install": "usage: dotman [--config=<path>] install [--deps]"
}

    dotman config [<path>]
    dotman [--config=<path>] install [--reinstall-dependencies] <package>...
    dotman [--config=<path>] reinstall <package>...
    dotman [--config=<path>] upgrade [--reinstall-dependencies] [--upgrade-dependencies] <package>...
"""

def main():
    print("Hello!")
