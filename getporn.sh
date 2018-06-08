#!/bin/bash 										# скрипт скачивания контента с сайта

a="eks-por"; b="video"; pn="s${a}no"; uri="https://720${b}.tv/"
path="/media/media/video"							# путь к папке куда складывать ролики

for i in `seq 1 638`; do							# цикл перечисления титульных страниц сайта
	if [ ${i} -eq 1 ]; then i=""
	else i="${i}"
	fi												# скачиваю титульную сраницу со ссылками
													# на идивидуальные ролики
	wget "${uri}${pn}-${b}/${i}" -O /tmp/tmp.http

													# и распарсиваю её создавая простой URL-лист файл
	grep "https://720${b}.tv/${b}s" "/tmp/tmp.http"|sed 's/^.*<a href=\"//; s/\/\".*$//g' > /tmp/tmp.pls

	while read page; do								# цикл чтения URL-листа страниц с роликами
													# скачиваю страницу с описанием и ссылкой на ролик
		wget "${page}" -O /tmp/tmp.http >/dev/null 2>&1
		nm=$(grep "_.mp4\/" /tmp/tmp.http|sed 's/^.*\(https:\/\/720video\.tv\/get_file\/.*_.mp4\).*/\1/')
		url="https${nm##*https}"					# распарсиваю страницу для получения прямой видео-ссылки
													# и русскоязычного имени ролика
		name="$(grep "<\/title>" /tmp/tmp.http|sed 's/ /_/g')"
		name="${name:8:-8}$(echo ${url}|tail -c 5)"	# создаю_правильное_имя_файла
		name="$(echo ${name}|sed 's/\.\./\./g')"	# скачиваю ролик, с применением режима докачки
													# что вынудить wget докачивать прерванную загрузку.
		wget "${url}" --continue -O "${path}/${name}"
	done < /tmp/tmp.pls								# конец цикла скачивания роликов
done												# конец цикла выборки титульных страниц
