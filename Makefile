.PHONY: default
default: clean build run copy;

build:
	docker build . -t binja

run:
	mkdir -p build
	docker run --rm -it -v $$(cat ~/.binaryninja/lastrun):/binja -v $$PWD/build:/so -t binja 

copy:
	sudo cp build/binexport12_binaryninja.so ~/.binaryninja/plugins/

clean:
	rm -rf build/
