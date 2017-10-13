# source docker helpers
. util/docker.sh
. util/service.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

@test "Start Low RAM Container" {
  start_container "simple-single-low-ram" "192.168.0.2" 64
}

@test "Configure Low RAM Container" {
  run run_hook "simple-single-low-ram" "configure" "$(payload configure-local)"
  echo_lines
  [ "$status" -eq 0 ]
}

@test "Fail To Start Low RAM ${service_name}" {
  run run_hook "simple-single-low-ram" "start" "$(payload start)"
  echo_lines
  [[ "$output" =~ "Not enough RAM" ]]
  [ "$status" -ne 0 ]
}

@test "Stop Low RAM Container" {
  stop_container "simple-single-low-ram"
}
