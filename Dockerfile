FROM debian:jessie

RUN apt-get -q update && apt-get install -yqq sysbench && apt-get -q clean

CMD sysbench --test=oltp \
	--oltp-table-size=1000000 \
	--db-driver=mysql \
	--mysql-host=mysql \
	--mysql-user=root \
	prepare \
	&& \
	sysbench --test=oltp \
	--oltp-test-mode=complex \
	--num-threads=16 \
	--max-time=300 \
	--max-requests=1000000 \
	--db-ps-mode=disable \
	--db-driver=mysql \
	--mysql-host=mysql \
	--mysql-user=root \
	run
