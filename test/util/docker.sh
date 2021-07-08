
util_dir="$(dirname $(readlink -f $BASH_SOURCE))"
hookit_dir="$(readlink -f ${util_dir}/../../src)"
payloads_dir=$(readlink -f ${util_dir}/../payloads)

payload() {
  cat ${payloads_dir}/${1}.json
}

run_hook() {
  container=$1
  hook=$2
  payload=$3

  docker exec \
    $container \
    /opt/nanobox/hooks/$hook "$payload"
}

start_container() {
  name=$1
  ip=$2
  ram=${3:-256}

  docker run \
    --name=$name \
    -d \
    -m ${ram}M \
    -e "PATH=$(path)" \
    --privileged \
    --net=nanobox \
    --ip=$ip \
    --volume=${hookit_dir}/:/opt/nanobox/hooks \
    nanobox/elasticsearch:$VERSION
}

stop_container() {
  docker stop $1
  docker rm $1
}

path() {
  paths=(
    "/opt/gonano/sbin"
    "/opt/gonano/bin"
    "/usr/local/sbin"
    "/usr/local/bin"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
  )

  path=""

  for dir in ${paths[@]}; do
    if [[ "$path" != "" ]]; then
      path="${path}:"
    fi

    path="${path}${dir}"
  done

  echo $path
}
