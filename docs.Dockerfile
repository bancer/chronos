# Generate the HTML output.
FROM markstory/cakephp-docs-builder as builder

RUN pip install git+https://github.com/sphinx-contrib/video.git@master

COPY docs /data/docs

# build docs with sphinx
RUN cd /data/docs-builder && \
  make website LANGS="en fr ja pt" SOURCE=/data/docs DEST=/data/website

# Build a small nginx container with just the static site in it.
FROM nginx:1.15-alpine

COPY --from=builder /data/website /data/website
COPY --from=builder /data/docs-builder/nginx.conf /etc/nginx/conf.d/default.conf

# Move docs into place.
RUN mv /data/website/html/* /usr/share/nginx/html

# Also versioned for deployment boundary reasons
RUN ln -s /usr/share/nginx/html /usr/share/nginx/html/1.x
