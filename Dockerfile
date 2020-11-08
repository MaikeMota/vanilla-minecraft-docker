FROM  openjdk:8-jre-alpine

LABEL org.opencontainers.image.authors="Maike Mota <maike_henrique@hotmail.com>, Gabriel Marques <gabrielf.pmarques@gmail.com>"

ARG SERVER_VERSION
ARG DOWNLOAD_URL_REGEX=(https\:\/\/launcher\.mojang\.com\/v1\/objects\/[0-9a-z]*\/server\.jar)
ARG MC_VERSION_REPO="https://mcversions.net/download/${SERVER_VERSION}"

RUN apk -U --no-cache upgrade
RUN apk --update add curl grep
RUN echo $MC_VERSION_REPO

RUN addgroup -g 1000 minecraft \
    && adduser -Ss /bin/false -u 1000 -G minecraft -h /home/minecraft minecraft \
    && mkdir -m 777 /minecraft  /world\    
    && chown minecraft:minecraft /world /minecraft /home/minecraft

USER minecraft

WORKDIR /minecraft

RUN curl $(curl $MC_VERSION_REPO | grep -E -o ${DOWNLOAD_URL_REGEX}) --output "./server.jar" \
    && java -jar "./server.jar" --initSettings \
    && echo "eula=true" > eula.txt

EXPOSE 25565 25575

CMD ["java", "-Xms256M",  "-Xmx4096M", "-jar",  "server.jar", "--nogui", "--world", "/world"]
