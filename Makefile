NAME=game_sf_template
SHELL = /bin/sh
OPTS = CRYSTAL_OPTS="--link-flags=-Wl,-ld_classic"
CC = ${OPTS} crystal build
BUILD_DIR = build
OUT_FILE = ${BUILD_DIR}/${NAME}
SOURCE_FILES = src/${NAME}.cr
SFML_DLL_DIR = "D:/Program Files/SFML-2.5.1/bin"
SFML_MAC_DIR = /Users/matt/code/libs/SFML-2.5.1-macos-clang

build_and_test: clean test

clean:
	@if [ -d ${BUILD_DIR} ]; then env echo "cleaning..." && rm -r ${BUILD_DIR}; fi
	@mkdir ${BUILD_DIR}

build_test:
	${CC} ${SOURCE_FILES} -o ${OUT_FILE}_test.o --error-trace

test: build_test
	./${OUT_FILE}_test.o

${OUT_FILE}.o:
	${CC} ${SOURCE_FILES} -o ${OUT_FILE}.o --release --no-debug -p

${OUT_FILE}.exe:
	${CC} ${SOURCE_FILES} -o ${OUT_FILE}.exe --release --no-debug -p

release: clean ${OUT_FILE}.o
	./${OUT_FILE}.o

winpack: clean ${OUT_FILE}.exe
	cp ${SFML_DLL_DIR}/*.dll ${BUILD_DIR}
	cp -r assets ${BUILD_DIR}/assets
	cd ${BUILD_DIR} && 7z a -tzip -mx9 ${NAME}-win.zip .
	cd ..

macpack: clean ${OUT_FILE}.o
	mkdir ${BUILD_DIR}/sfml
	cp -r "${SFML_MAC_DIR}/lib" ${BUILD_DIR}/sfml
	cp -r "${SFML_MAC_DIR}/extlibs" ${BUILD_DIR}/sfml
	platypus --load-profile profile.platypus ${OUT_FILE}.app
	mkdir ${NAME}
	cp -r ${OUT_FILE}.app ${NAME}/${NAME}.app
	7zz a -tzip -mx9 ${BUILD_DIR}/${NAME}-mac.zip ${NAME}/${NAME}.app
	rm -rf ${NAME}

rename: clean
	${CC} src/rename.cr -o ${BUILD_DIR}/rename.o --error-trace
	./${BUILD_DIR}/rename.o
