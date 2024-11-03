import os
import version

v = os.getenv("REDOT_VERSION")

if hasattr(version, "patch") and version.patch != 0:
    git_version = f"{version.major}.{version.minor}.{version.patch}"
else:
    git_version = f"{version.major}.{version.minor}"

print(git_version == v.split("-")[0])