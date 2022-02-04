# This docker build file creates a single docker image that contains both the CloudTop virtual Desktop
# and the Google Health Enabled CloudTop viewer.  To do this we start by building the OHIF viewer,
# then we copy everything we need into the CloudImage.  Then we add in nginx and we are basically done.

# Step 1: Build the OHIF viewer using a node image as the base

ARG CLOUDTOP_TAG=develop-latest
FROM node:10.16.3-slim as builder

# Get the needed files from github with wget
ENV DOWNLOAD_DIR="/tmp/downloaded-src"
ENV OHIF_SOURCE_DIR="/tmp/downloaded-src/Viewers"
WORKDIR $DOWNLOAD_DIR

ENV GIT_URL="https://github.com/OHIF/Viewers.git"

RUN apt-get update && apt-get install -y \
  git

RUN git clone $GIT_URL

RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# Copy Files
RUN cp -r $OHIF_SOURCE_DIR/.docker /usr/src/app/.docker
RUN cp -r $OHIF_SOURCE_DIR/.webpack /usr/src/app/.webpack
RUN cp -r $OHIF_SOURCE_DIR/extensions /usr/src/app/extensions
RUN cp -r $OHIF_SOURCE_DIR/platform /usr/src/app/platform
RUN cp $OHIF_SOURCE_DIR/.browserslistrc /usr/src/app/.browserslistrc
RUN cp $OHIF_SOURCE_DIR/aliases.config.js /usr/src/app/aliases.config.js
RUN cp $OHIF_SOURCE_DIR/babel.config.js /usr/src/app/babel.config.js
RUN cp $OHIF_SOURCE_DIR/lerna.json /usr/src/app/lerna.json
RUN cp $OHIF_SOURCE_DIR/package.json /usr/src/app/package.json
RUN cp $OHIF_SOURCE_DIR/postcss.config.js /usr/src/app/postcss.config.js
RUN cp $OHIF_SOURCE_DIR/yarn.lock /usr/src/app/yarn.lock

# Run the install before copying the rest of the files
RUN yarn config set workspaces-experimental true
RUN yarn install
#
ENV PATH /usr/src/app/node_modules/.bin:$PATH
ENV QUICK_BUILD true

RUN yarn run build

ARG CLOUDTOP_TAG=develop-latest
FROM helxplatform/cloudtop:$CLOUDTOP_TAG

ENV OHIF_SOURCE_DIR="/tmp/downloaded-src/Viewers"
## install nginx and copy in the OHIF code
RUN apt-get update && apt-get install -y \
	nginx
RUN rm -rf /etc/nginx/conf.d
COPY --from=builder $OHIF_SOURCE_DIR/.docker/Viewer-v2.x/default.conf /etc/nginx/conf.d/default.conf
RUN printf '\
\n\
server {\n\
  listen 3000;\n\
  location / {\n\
    root   /usr/share/nginx/html;\n\
    index  index.html index.htm;\n\
    try_files $uri $uri/ /index.html;\n\
  }\n\
  error_page   500 502 503 504  /50x.html;\n\
  location = /50x.html {\n\
    root   /usr/share/nginx/html;\n\
  }\n\
}' > /etc/nginx/conf.d/default.conf
COPY --from=builder $OHIF_SOURCE_DIR/.docker/Viewer-v2.x/entrypoint.sh /usr/src/
RUN chmod 777 /usr/src/entrypoint.sh
COPY --from=builder /usr/src/app/platform/viewer/dist /usr/share/nginx/html

WORKDIR /config

# Copy the ohif services files into S6 service area
COPY root/etc/services.d/ohif /etc/services.d/ohif
COPY root/etc/cont-init.d/60-firefox.sh /etc/cont-init.d/

ADD ./src/common/xfce/ /config

# Terra customizations here!!
ADD default /etc/nginx/sites-available/default
ADD server.xml /usr/local/tomcat/conf/server.xml
ENV RSTUDIO_HOME "unused"

# The required CloudTop entrypoint.  init starts the S6 system which reads the run direcories and
# starts the monitored services
ENTRYPOINT [ "/init" ]
