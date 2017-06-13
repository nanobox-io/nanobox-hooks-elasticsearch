
service_name="Elasticsearch"
default_port=9200

wait_for_running() {
  container=$1
  until [[ $(docker exec ${container} bash -c "ps aux") =~ "java" ]]
  do
    sleep 1
  done
}

wait_for_listening() {
  container=$1
  ip=$2
  port=$3
  until docker exec ${container} bash -c "nc -q 1 ${ip} ${port} < /dev/null"
  do
    sleep 1
  done
}

wait_for_stop() {
  container=$1
  while [[ $(docker exec ${container} bash -c "ps aux") =~ "java" ]]
  do
    sleep 1
  done
}

verify_stopped() {
  container=$1
  run docker exec ${container} bash -c "ps faux"
  echo_lines
  [[ ! "$output" =~ "java" ]]
  [ "$status" -eq 0 ] 
}

insert_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  run docker exec ${container} bash -c "curl -X PUT 'http://${ip}:${port}/keys?pretty'"
  echo_lines
  run docker exec ${container} bash -c "curl -X PUT 'http://${ip}:${port}/keys/external/${key}?pretty' -H 'Content-Type: application/json' -d '{\"data\": \"${data}\"}'"
  echo_lines
}

update_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  run docker exec ${container} bash -c "curl -X POST 'http://${ip}:${port}/keys/external/${key}/_update?pretty' -H 'Content-Type: application/json' -d '{\"doc\": {\"data\": \"${data}\"}}'"
  echo_lines
  [ "$status" -eq 0 ]
}

verify_test_data() {
  container=$1
  ip=$2
  port=$3
  key=$4
  data=$5
  run docker exec ${container} bash -c "curl -s -X GET 'http://${ip}:${port}/keys/external/${key}?pretty'"
  test_data=$(echo -e "    \"data\" : \"${data}\"")
  echo_lines
  [[ "${output}" =~ "${test_data}" ]]
  [ "$status" -eq 0 ]
}

verify_plan() {
  [ "${lines[0]}" = "{" ]
  [ "${lines[1]}" = "  \"redundant\": false," ]
  [ "${lines[2]}" = "  \"horizontal\": false," ]
  [ "${lines[3]}" = "  \"users\": [" ]
  [ "${lines[4]}" = "  ]," ]
  [ "${lines[5]}" = "  \"ips\": [" ]
  [ "${lines[6]}" = "    \"default\"" ]
  [ "${lines[7]}" = "  ]," ]
  [ "${lines[8]}" = "  \"port\": 9200," ]
  [ "${lines[9]}" = "  \"behaviors\": [" ]
  [ "${lines[10]}" = "    \"migratable\"," ]
  [ "${lines[11]}" = "    \"backupable\"" ]
  [ "${lines[12]}" = "  ]" ]
  [ "${lines[13]}" = "}" ]
}