# Custom Trino Docker image (Hudi)

This repository builds a Docker image around [Trino](https://trino.io/) with optional replacement of the bundled Apache Hudi plugin JARs, plus catalog configs for Hive, Hudi, MySQL, memory, and TPC-DS.

## Layout

| Path | Purpose |
|------|---------|
| `Dockerfile` | Image definition (Temurin JDK, Trino server, JMX Prometheus agent, configs) |
| `build.sh` | Validates required artifacts and runs `docker build` |
| `conf/trino/catalog/` | Static Trino `etc` and catalog property files baked into the image |
| `jars/` | **You supply** Trino distribution artifacts (and optional Hudi bundle) here |

## Prerequisites

- Docker
- Trino **server** tarball and **CLI** executable JAR for the version you want (same version string for both filenames)

### Populate `jars/`

Place these files in `jars/` before building (replace `481-SNAPSHOT` with your `TRINO_VERSION`):

- `trino-server-<TRINO_VERSION>.tar.gz` — official or custom-built server package
- `trino-cli-<TRINO_VERSION>-executable.jar` — CLI jar from the same release

Optional:

- `hudi-trino-bundle-*.jar` — if present, default Hudi-related JARs under the Trino `hudi` and `hive` plugins are removed and this bundle is copied into both plugin directories (see the `Dockerfile` for the exact pattern).

Large binaries under `jars/` are ignored by Git (see `.gitignore`); only `jars/.gitkeep` is tracked so the directory exists in a fresh clone.

## Build

From the repository root:

```bash
chmod +x build.sh
./build.sh
```

Environment variables (all optional except you must match filenames to `TRINO_VERSION`):

| Variable | Default | Meaning |
|----------|---------|---------|
| `TRINO_VERSION` | `481-SNAPSHOT` | Must match the Trino tarball and CLI jar names under `jars/` |
| `IMAGE_NAME` | `custom-trino-hudi` | Docker image name |
| `IMAGE_TAG` | same as `TRINO_VERSION` | Docker image tag |

Example:

```bash
TRINO_VERSION=470 IMAGE_NAME=my-trino ./build.sh
```

Equivalent manual build:

```bash
docker build --build-arg TRINO_VERSION=470 -t my-trino:470 -f Dockerfile .
```

## Run

The container entrypoint runs `conf/trino/catalog/autoconfig_and_launch.sh`, which starts Trino with `/opt/trino-server/bin/launcher run`. Expose port **8080** (HTTP) and, if you use the bundled JMX Prometheus agent as configured in `jvm.config`, **9091** for metrics.

Example:

```bash
docker run --rm -p 8080:8080 -p 9091:9091 custom-trino-hudi:481-SNAPSHOT
```

Tune memory and JVM flags in `conf/trino/catalog/jvm.config` before rebuilding. The file `conf/trino/catalog/config.yaml` is the JMX Prometheus Java agent configuration referenced from `jvm.config`.

## Customizing catalogs

Edit the `*.properties` files under `conf/trino/catalog/` (and subpaths copied to `etc/catalog/` in the image), then rebuild. For secrets and environment-specific values, prefer mounting overrides at runtime or extending the launch script instead of baking credentials into the image.
