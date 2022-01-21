# trezor-download
Tool to download and verify the signature of Trezor suite install files.

# Usage
To download the file that matches you platform, you must provide a this as an argument.

| Platform     | Argument  |
| ------------ | --------- |
| linux ARM    | linux-arm |
| Linux        | linux     |
| Mac ARM (M1) | mac-arm   |
| Mac          | mac       |
| Windows      | win       |

Provide the right argument when running the docker container. In the example below the files for Mac ARM are being downloaded by specifying the `mac-arm` argument.

```
docker run -it --rm -v ${PWD}:/downloads ghcr.io/styxit/trezor-download mac-arm
```

# Updating
Remove the old image and pull the latest image from the container registry.

```
docker image rm ghcr.io/styxit/trezor-download
docker pull ghcr.io/styxit/trezor-download:latest
```

# Build and run from source
```
docker build -t styxit/trezor-download .

docker run -it --rm -v ${PWD}:/downloads styxit/trezor-download mac-arm
```
