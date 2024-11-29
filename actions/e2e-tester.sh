#!/sbin/openrc-run

depend() {
  need net
}

start() {
  ebegin "test start"
  chmod a+x /tests/test.sh
  /tests/test.sh 2>&1 | tee -a /tests/test.log | xargs -I{} einfo "log: {}"
  einfo "test end"
  eend $?
}
