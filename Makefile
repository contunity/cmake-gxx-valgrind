tags = ubuntu-18.04 alpine-3.10
image_prefix = contunity/
image_name = cmake-gxx-valgrind

.PHONY: all $(tags) clean

all: $(tags)

$(tags): %: %/Dockerfile
	docker build -t $(image_prefix)$(image_name):$@ -f $< .
