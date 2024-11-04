for i in `ls Solar.Opposites.S05E*.mp4`; do echo $i; j=${i%.*}; k=${j##*-}; echo $k; echo $j.en.vtt; wget "https://thomasalthoughhear.com/srt/11992/"$k"_en.vtt" -O $j.en.vtt; echo; done 

