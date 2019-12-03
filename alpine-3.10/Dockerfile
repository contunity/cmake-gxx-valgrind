FROM alpine:3.10

RUN apk add --no-cache gcc g++ musl-dev cmake make valgrind
COPY check-leaks.sh /bin/check-leaks
RUN chmod +x /bin/check-leaks

CMD sh /bin/check-leaks
