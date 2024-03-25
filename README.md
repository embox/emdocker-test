# emdocker-test
Embox build and test environment

## Build
```
docker build -t embox/emdocker .
```

## Run
```
export EMBOX_PATH=<full_path_to_embox>
```
```
docker run -it --rm --privileged --name emdocker -v "$EMBOX_PATH":/embox embox/emdocker
```
