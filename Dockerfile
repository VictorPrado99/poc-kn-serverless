FROM  --platform=linux/amd64 gradle:8.6.0-jdk21 as builder
LABEL authors="reivax"

WORKDIR /app
ENV KONAN_DATA_DIR=/home/gradle/.gradle
COPY . .

RUN \
    --mount=type=cache,target=/app/.gradle,rw \
    --mount=type=cache,target=/app/bin/build,rw \
    --mount=type=cache,target=/home/gradle/.gradle,rw \
    ./gradlew nativeBinaries --no-daemon

FROM scratch

WORKDIR /app

# Now copy the static shell into base image.
COPY --from=builder /bin/sh /bin/sh

## You may also copy all necessary executables into distroless image.
#COPY --from=busybox /bin/mkdir /bin/mkdir
#COPY --from=busybox /bin/cat /bin/cat
#COPY --from=busybox /bin/ls /bin/ls

COPY --from=builder /lib /lib
COPY --from=builder /lib64 /lib64

COPY --from=builder /app/build/bin/native/releaseExecutable/ ./releaseExecutable/

EXPOSE 8080

CMD ["./releaseExecutable/poc-kn-serverless.kexe"]