FROM ubuntu:18.04

RUN apt-get update && apt-get -y -q install gcc g++ cmake make valgrind
COPY check-leaks.sh /bin/check-leaks
RUN chmod +x /bin/check-leaks

CMD bash /bin/check-leaks
