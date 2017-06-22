docker run \
  --name "imagen-rb" \
  -it \
  --rm \
  --env-file ".env" \
  -v "$(pwd):/imagen" \
  --entrypoint bash \
  mrgrodo/imagen-rb
