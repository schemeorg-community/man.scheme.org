FROM debian:bullseye AS build
RUN apt-get update && apt-get -y --no-install-recommends install \
      gcc groff libelk0 libelk0-dev make \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /build
ADD https://gitea.scheme.org/conservatory/unroff/archive/master.tar.gz \
      unroff.tar.gz
RUN tar -xf unroff.tar.gz
WORKDIR /build/unroff/src
RUN make PREFIX=/usr/local
RUN make PREFIX=/usr/local install

FROM debian:bullseye
RUN apt-get update && apt-get -y --no-install-recommends install \
      groff libelk0 \
 && rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/local/ /usr/local/
WORKDIR /work
ADD . /work
CMD ["sh", "-c", "scripts/www.sh >&2 && tar --sort=name -cf - www/"]
