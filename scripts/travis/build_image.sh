echo "Building with travis commit of $BUILD_NAME ..."
docker build . -t  anthonydenecheau/scc-ora2pg:$BUILD_NAME