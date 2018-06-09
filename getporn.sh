#!/bin/bash
# скрипт скачивания видео-контента с сайта

a="eks-por"; b="video"; pn="s${a}no"; uri="https://720${b}.tv/"
path="/media/media/video"					# путь к папке куда складывать ролики

for i in `seq 1 638`; do					# цикл перечисления титульных страниц сайта
	if [ ${i} -eq 1 ]; then i=""
	else i="${i}"
	fi										# скачиваю титульную сраницу со ссылками
											# на идивидуальные ролики
	wget "${uri}${pn}-${b}/${i}" -O /tmp/tmp.http
											# и распарсиваю её в простой URL лист-файл
	grep "https://720${b}.tv/${b}s" /tmp/tmp.http|sed 's/^.*<a href=\"//; s/\/\".*$//g' > /tmp/tmp.pls

	while read page; do						# цикл чтения URL-листа страниц с роликами
											# скачиваю страницу с описанием и ссылкой на ролик
		wget "${page}" -O /tmp/tmp.http >/dev/null 2>&1
		nm=$(grep "_.mp4\/" /tmp/tmp.http|sed 's/^.*\(https:\/\/720video\.tv\/get_file\/.*_.mp4\).*/\1/')
		url="https${nm##*https}"			# распарсиваю страницу для получения прямой видео-ссылки
		name="$(grep "<\/title>" /tmp/tmp.http|sed 's/ /_/g')"	# получаю русскоязычное имя ролика
		name="${name:8:-8}$(echo ${url}|tail -c 5)"				# и убираю_из_имени_файла_пробелы
		name="$(echo ${name}|sed 's/\.\./\./g')"
		inst=$(ls "${path}"|grep "${name}")	# немного ускоряю пропуск уже существующих файлов
		if [ ! -f "${HOME}/lastdownlodfile" ] || [ "$inst" != "$name" ] ||
												 [ "$name" = "$(cat "${HOME}/lastdownlodfile")" ]
		then
			echo "$name" > "${HOME}/lastdownlodfile"
											# скачиваю ролик, с применением режима докачки
			wget "${url}" --continue -O "${path}/${name}"
		else echo "Skip existing file: $name"
		fi
	done < /tmp/tmp.pls						# конец цикла скачивания роликов
done										# конец цикла выборки титульных страниц
rm /tmp/tmp.pls /tmp/tmp.http

# git add getporn.sh
# git commit -m "update commit"
# git push -u origin master
