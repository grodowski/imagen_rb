FROM ruby:2.4.1
RUN mkdir /imagen

COPY Gemfile* /tmp/
WORKDIR /tmp

# use a local bundle path for gem inspections
ENV BUNDLE_PATH /imagen/.bundle

# add /bin to PATH
ENV BUNDLE_BIN=/imagen/.bundle/bin
ENV PATH $BUNDLE_BIN:$PATH

WORKDIR /imagen
ADD . /imagen
