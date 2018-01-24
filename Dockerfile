FROM ruby:2.4-stretch

RUN apt-get update && apt-get install -y git make curl autoconf automake libtool pkg-config unzip

ENV LANG C.UTF-8

RUN mkdir /app
COPY ./ /app
WORKDIR /app

RUN make setup
RUN make libpostal LIBPOSTAL_INSTALL_DIR=/libpostal
RUN bundle install --without development

ENV LD_LIBRARY_PATH /app/geosupport/version-17d_17.4/lib/
ENV GEOFILES /app/geosupport/version-17d_17.4/fls/
ENV LIBGEO_PATH /app/geosupport/version-17d_17.4/lib/libgeo.so
ENV RACK_ENV production

EXPOSE 4567

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
