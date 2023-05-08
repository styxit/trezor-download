# trezor-download
Tool to download and verify the signature of Trezor suite install files. Uses gpg to verify the downloaded binary has been signed with the SatoshiLabs key.

# Usage
In order to download the Trezor binary that matches your device, you need to select a platform. You can provide the platform as an argument on the commandline or select it from a list of availabled platforms.

| Platform         | Argument  |
| ---------------- | --------- |
| linux ARM        | linux-arm |
| Linux            | linux     |
| Mac ARM (M1, M2) | mac-arm   |
| Mac              | mac       |
| Windows          | win       |

Provide the right argument when running the docker container. In the example below the files for Mac ARM are being downloaded by specifying the `mac-arm` argument.


Download mac-arm image by providing the platform as an argument.
```
docker run -it --rm -v ${PWD}:/downloads ghcr.io/styxit/trezor-download mac-arm
```


Download image without providing a platform argument and you will be prompted to select one.
```
docker run -it --rm -v ${PWD}:/downloads ghcr.io/styxit/trezor-download
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
