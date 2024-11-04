echo "$@"
input=$@
id=`echo $input | rev | cut -d / -f 1 | rev`
#wget "$@" -O /tmp/veo_get.out


echo id=$id


wget "https://voe.sx/e/$id" -O /tmp/veo_get.out
#i@id=`echo "$@" | cut -d "/" -f 5`
#echo id=$id
title=`cat /tmp/veo_get.out| grep "<title>" |cut -d '>' -f 2 | cut -f 1 -d '<' | cut -d ' ' -f 2-`
m3u=`cat /tmp/veo_get.out| grep m3u8 | cut -d '"' -f 4`
echo m3u=$m3u

ytdl_voe -o "$title"-$id.mp4 $m3u


sleep 3
