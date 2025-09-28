#!/bin/bash

# テキストファイルをJSON形式に変換するシェルスクリプト
# 各行を個別のオブジェクトとして、IDとcontentを持つJSON配列に変換します。

# 引数チェック
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <keyword>"
    echo "例: $0 ${KEYWORD}"
    exit 1
fi

# 引数からキーワードを取得
KEYWORD="$1"

# ファイル名を引数から設定
export INPUT_TEXT="./txt/${KEYWORD}.txt"
export INPUT_JSON="./json/${KEYWORD}.json"

sh ./convert_txt_to_json.sh


    echo "  export INPUT_JSON=\"./json/data.json\""
    echo "  export INPUT_SSML=\"./ssml\""
    echo "  $0"

# export INPUT_JSON=\"./json/data.json\""
export INPUT_SSML="./ssml/${KEYWORD}"

sh ./generate_ssml_files.sh



#export INPUT_SSML="$./ssml/examtopics-dop-20250713-36"
export OUTPUT_MP3="./mp3/${KEYWORD}"

sh ./convert-ssml-to-mp3.sh

export INPUT_MP3_DIR="${PWD}/mp3/${KEYWORD}"
export OUTPUT_MP3="${PWD}/mp3/${KEYWORD}/${KEYWORD}.mp3"

sh ./merge-mp3-files.sh


exit 0
