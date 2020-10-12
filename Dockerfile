FROM mariadb

RUN apt update
RUN apt install curl pv gzip -y
RUN curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt install nodejs -y
RUN apt install zip -y

# Copy main script
COPY package.json /package.json
RUN npm install

RUN mkdir /backup

COPY index.js /index.js
COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "sh", "/docker-entrypoint.sh" ]