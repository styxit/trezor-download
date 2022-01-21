# trezor-download
Tool to download and verify the signature of Trezor suite install files.

# Build and run from source
```
docker build -t styxit/trezor-download .

docker run -it --rm -v ${PWD}/downloads:/downloads styxit/trezor-download mac-arm
```
