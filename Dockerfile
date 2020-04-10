# WPWatcher Dockerfile
FROM ruby:alpine
# Install dependencies ruby gem 
RUN apk --update add --virtual build-dependencies ruby-dev build-base &&\
    apk --update add curl &&\
    apk --update add git
# Install WPScan lastest tested version
RUN gem install wpscan -v 3.7.11
# Python install
ENV PYTHONUNBUFFERED=1
RUN apk add --no-cache python3
# Add only required scripts 
ADD setup.py /wpwatcher
ADD wpwatcher.py /wpwatcher
ADD wpscan_parser.py /wpwatcher
ADD README.md /wpwatcher
WORKDIR /wpwatcher
# Install WPWatcher
RUN python3 ./setup.py install
# Setup user and group if specified
ARG USER_ID
ARG GROUP_ID
RUN deluser --remove-home wpwatcher >/dev/null 2>&1 || true
# Init folder tree
RUN mkdir /wpwatcher && mkdir /wpwatcher/.wpwatcher
RUN if [ ${USER_ID:-0} -ne 0 ]; then adduser -h /wpwatcher -D -u ${USER_ID} wpwatcher; fi
RUN adduser -h /wpwatcher -D wpwatcher >/dev/null 2>&1 || true
RUN if [ ${GROUP_ID:-0} -ne 0 ]; then addgroup -g ${GROUP_ID} wpwatcher && addgroup wpwatcher wpwatcher ; fi
RUN chown -R wpwatcher /wpwatcher
USER wpwatcher
RUN echo -e "\n\n\tWPWatcher installed\n\tUse: docker run -it -v '/path/to/your/wpwatcher.conf/folder/:/wpwatcher/.wpwatcher/' wpwatcher\n\n"
# Run command
ENTRYPOINT ["wpwatcher"]
