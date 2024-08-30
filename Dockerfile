FROM  --platform=linux/amd64 gradle:8.6.0-jdk21 as builder
LABEL authors="reivax"

WORKDIR /app
ENV KONAN_DATA_DIR=/app/gradle/.gradle
COPY . .

RUN ./gradlew nativeBinaries

FROM busybox:1.35.0-uclibc as busybox

FROM scratch

WORKDIR /app

# Now copy the static shell into base image.
COPY --from=busybox /bin/sh /bin/sh

## You may also copy all necessary executables into distroless image.
#COPY --from=busybox /bin/mkdir /bin/mkdir
#COPY --from=busybox /bin/cat /bin/cat
#COPY --from=busybox /bin/ls /bin/ls

COPY --from=builder /lib /lib
COPY --from=builder /lib64 /lib64

COPY --from=builder /app/build/bin/native/releaseExecutable/ ./releaseExecutable/

EXPOSE 8080

CMD ["./releaseExecutable/poc-kn-serverless.kexe"]