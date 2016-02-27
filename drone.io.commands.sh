# The shell script configured in drone.io's Settings -> Build & Test -> Commands
# This settings will archive following binaries. (configured in Settings -> Artifacts)
# artifacts/darwin_amd64/haskap-jam-server
# artifacts/linux_386/haskap-jam-server
# artifacts/linux_amd64/haskap-jam-server
# artifacts/linux_arm/haskap-jam-server
# artifacts/windows_amd64/haskap-jam-server
# artifacts/linux_amd64/haskap-jam-interceptor

# install libcap-dev
sudo apt-get update -y
sudo apt-get install -y libpcap-dev

# install golang
pushd ~/
# cf. https://github.com/docker-library/golang/blob/master/1.6/Dockerfile
export GOLANG_VERSION=1.6
export GOLANG_DOWNLOAD_URL=https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
export GOLANG_DOWNLOAD_SHA256=5470eac05d273c74ff8bac7bef5bad0b5abbd1c4052efbdbc8db45332e836b0b

curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar xzf golang.tar.gz \
	&& rm golang.tar.gz

export GOROOT=~/go
export PATH=$GOROOT/bin:$PATH
popd

go version
go env

# build
#BUILD_VERSION=`git describe --always --dirty`
BUILD_VERSION=nightly
echo BUILD_VERSION: $BUILD_VERSION
BUILD_DATE=`date +%FT%T%z`
echo BUILD_DATE: $BUILD_DATE
GIT_COMMIT=`git describe --always`
echo GIT_COMMIT: $GIT_COMMIT

# jam-server
SRC_DIR=server/jam-server
OUT_DIR=artifacts

mkdir -p $OUT_DIR
export GOOS=darwin;export GOARCH=amd64;go build -ldflags "-X main.BuildVersion=$BUILD_VERSION -X main.GitCommit=$GIT_COMMIT -X main.BuildDate=$BUILD_DATE" -o ${OUT_DIR}/${GOOS}_${GOARCH}/haskap-jam-server ${SRC_DIR}/haskap-jam-server.go
export GOOS=windows;export GOARCH=amd64;go build -ldflags "-X main.BuildVersion=$BUILD_VERSION -X main.GitCommit=$GIT_COMMIT -X main.BuildDate=$BUILD_DATE" -o ${OUT_DIR}/${GOOS}_${GOARCH}/haskap-jam-server ${SRC_DIR}/haskap-jam-server.go
# remove for exceeded max number of archives
#  Warning: Could not archive /home/ubuntu/src/github.com/kn1kn1/haskap-jam-pack/artifacts/linux_amd64/haskap-jam-interceptor, exceeded max number of archives
#export GOOS=windows;export GOARCH=386;go build -ldflags "-X main.BuildVersion=$BUILD_VERSION -X main.GitCommit=$GIT_COMMIT -X main.BuildDate=$BUILD_DATE" -o ${OUT_DIR}/${GOOS}_${GOARCH}/haskap-jam-server ${SRC_DIR}/haskap-jam-server.go
export GOOS=linux;export GOARCH=amd64;go build -ldflags "-X main.BuildVersion=$BUILD_VERSION -X main.GitCommit=$GIT_COMMIT -X main.BuildDate=$BUILD_DATE" -o ${OUT_DIR}/${GOOS}_${GOARCH}/haskap-jam-server ${SRC_DIR}/haskap-jam-server.go
export GOOS=linux;export GOARCH=386;go build -ldflags "-X main.BuildVersion=$BUILD_VERSION -X main.GitCommit=$GIT_COMMIT -X main.BuildDate=$BUILD_DATE" -o ${OUT_DIR}/${GOOS}_${GOARCH}/haskap-jam-server ${SRC_DIR}/haskap-jam-server.go
export GOOS=linux;export GOARCH=arm;go build -ldflags "-X main.BuildVersion=$BUILD_VERSION -X main.GitCommit=$GIT_COMMIT -X main.BuildDate=$BUILD_DATE" -o ${OUT_DIR}/${GOOS}_${GOARCH}/haskap-jam-server ${SRC_DIR}/haskap-jam-server.go

# log-interceptor
SRC_DIR=server/log-interceptor
OUT_DIR=artifacts

export GOOS=linux;export GOARCH=amd64;go get github.com/google/gopacket;go build -ldflags "-X main.BuildVersion=$BUILD_VERSION -X main.GitCommit=$GIT_COMMIT -X main.BuildDate=$BUILD_DATE" -o ${OUT_DIR}/${GOOS}_${GOARCH}/haskap-jam-interceptor ${SRC_DIR}/haskap-jam-interceptor.go
# cannot cross-compile pcap...
#  https://stackoverflow.com/questions/31648793/go-programming-cross-compile-for-revel-framework
