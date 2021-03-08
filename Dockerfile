FROM ruby:2.7.2

WORKDIR /workdir

COPY Gemfile Gemfile.lock /workdir/
RUN bundle install

COPY . /workdir

EXPOSE 3000

ENTRYPOINT [ "/usr/local/bundle/bin/rails" ]

CMD ["server", "-b", "0.0.0.0"]