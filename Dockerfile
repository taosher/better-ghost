# https://docs.ghost.org/faq/node-versions/
# https://github.com/nodejs/LTS
# https://github.com/TryGhost/Ghost/blob/3.3.0/package.json#L38
FROM node:12-alpine3.11

USER root

# grab su-exec for easy step-down from root
RUN apk add --no-cache 'su-exec>=0.2';
RUN apk add --no-cache bash ;

ENV GHOST_CLI_VERSION 1.13.1
ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content
ENV GHOST_HOST 0.0.0.0
ENV GHOST_PORT 2368
ENV GHOST_URL http://localhost:2368

RUN mkdir -p "$GHOST_INSTALL"; \
    mkdir -p "$GHOST_INSTALL"/core; \
    mkdir -p "$GHOST_INSTALL"/core/dist; \
    mkdir -p "$GHOST_CONTENT"; \
    mkdir -p "$GHOST_CONTENT"/data;

COPY content/images "$GHOST_CONTENT"/images
COPY content/settings "$GHOST_CONTENT"/settings
COPY content/themes "$GHOST_CONTENT"/themes
COPY content/data/ghost-empty.db "$GHOST_CONTENT"/data/ghost.db
COPY core/built "$GHOST_INSTALL"/core/built
COPY core/client/dist "$GHOST_INSTALL"/core/client/dist
COPY core/frontend "$GHOST_INSTALL"/core/frontend
COPY core/server "$GHOST_INSTALL"/core/server
COPY core/shared "$GHOST_INSTALL"/core/shared
COPY core/index.js "$GHOST_INSTALL"/core/index.js
# COPY node_modules/ "$GHOST_INSTALL"/node_modules
COPY index.js "$GHOST_INSTALL"/index.js
COPY MigratorConfig.js "$GHOST_INSTALL"/MigratorConfig.js
COPY package.json "$GHOST_INSTALL"/package.json

# RUN apk add --no-cache 'su-exec>=0.2';
# RUN apk add --no-cache bash ;

RUN set -eux; \
	chown node:node -R "$GHOST_INSTALL"; \
  	chown node:node -R "$GHOST_CONTENT" ;

WORKDIR $GHOST_INSTALL

# RUN	sqlite3Version="$(node -p 'require("./package.json").optionalDependencies.sqlite3')"; \
	# su-exec node yarn add "sqlite3@$sqlite3Version" --force; \
    # apk add --no-cache --virtual .build-deps python make gcc g++ libc-dev; \
    # su-exec node yarn add "sqlite3@$sqlite3Version" --force --build-from-source; \
    # apk del --no-network .build-deps; \
# RUN apk add --no-cache 'su-exec>=0.2' ; \
# USER node

RUN su-exec node yarn --prod=true --verbose; \
	su-exec node yarn cache clean; \
	su-exec node npm cache clean --force;

	# npm cache clean --force; \
	# rm -rv /tmp/v8*;
VOLUME $GHOST_CONTENT
EXPOSE 2368
USER node
# ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["yarn", "start"]

