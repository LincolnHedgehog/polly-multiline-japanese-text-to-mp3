#!/bin/bash

# テキストファイルをJSON形式に変換するシェルスクリプト
# 各行を個別のオブジェクトとして、IDとcontentを持つJSON配列に変換します。

# デフォルトのファイル名
DEFAULT_INPUT="examtopics-20250628-keyword.txt"
DEFAULT_OUTPUT="examtopics-20250628-keyword.json"

# 使用方法を表示する関数
show_usage() {
    echo "使用方法:"
    echo "  $0"
    echo "  $0 <入力ファイル>"
    echo "  $0 <入力ファイル> <出力ファイル>"
    echo ""
    echo "環境変数:"
    echo "  INPUT_TEXT  - 入力ファイルのパス"
    echo "  INPUT_JSON  - 出力ファイルのパス（後続スクリプトの入力となる）"
    echo ""
    echo "例:"
    echo "  $0"
    echo "  $0 data.txt"
    echo "  $0 data.txt output.json"
    echo "  INPUT_TEXT=data.txt INPUT_JSON=output.json $0"
}

# 環境変数の確認と引数の処理
if [ -n "$INPUT_TEXT" ] && [ -n "$INPUT_JSON" ]; then
    # 環境変数が両方設定されている場合
    INPUT_FILE="$INPUT_TEXT"
    OUTPUT_FILE="$INPUT_JSON"
else
    # 環境変数が両方設定されていない場合はエラー
    echo "エラー: 環境変数 INPUT_TEXT と INPUT_JSON の両方を設定してください。"
    echo ""
    echo "例:"
    echo "  export INPUT_TEXT=\"input.txt\""
    echo "  export INPUT_JSON=\"output.json\""
    echo "  $0"
    echo ""
    show_usage
    exit 1
fi

# 入力ファイルの存在確認
if [ ! -f "$INPUT_FILE" ]; then
    echo "エラー: 入力ファイル '$INPUT_FILE' が見つかりません。"
    exit 1
fi

echo "入力ファイル: $INPUT_FILE"
echo "出力ファイル: $OUTPUT_FILE"
echo ""

# 一時ファイル
TEMP_FILE=$(mktemp)

# JSONの開始
echo "[" > "$OUTPUT_FILE"

# 行数をカウント
TOTAL_LINES=$(grep -c . "$INPUT_FILE")
CURRENT_LINE=0

# 各行を処理
while IFS= read -r line; do
    # 空行をスキップ
    if [ -z "$line" ]; then
        continue
    fi
    
    CURRENT_LINE=$((CURRENT_LINE + 1))
    
    # JSONエスケープ処理（基本的な文字のみ）
    ESCAPED_LINE=$(echo "$line" | sed 's/\\/\\\\/g; s/"/\\"/g')
    
    # JSON オブジェクトを作成
    if [ $CURRENT_LINE -eq $TOTAL_LINES ]; then
        # 最後の行（カンマなし）
        echo "  {" >> "$OUTPUT_FILE"
        echo "    \"id\": $CURRENT_LINE," >> "$OUTPUT_FILE"
        echo "    \"content\": \"$ESCAPED_LINE\"" >> "$OUTPUT_FILE"
        echo "  }" >> "$OUTPUT_FILE"
    else
        # 最後以外の行（カンマあり）
        echo "  {" >> "$OUTPUT_FILE"
        echo "    \"id\": $CURRENT_LINE," >> "$OUTPUT_FILE"
        echo "    \"content\": \"$ESCAPED_LINE\"" >> "$OUTPUT_FILE"
        echo "  }," >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"

# JSONの終了
echo "]" >> "$OUTPUT_FILE"

# 一時ファイルを削除
rm -f "$TEMP_FILE"

echo "変換完了: $CURRENT_LINE 行のデータを '$OUTPUT_FILE' に保存しました。"
echo "変換が正常に完了しました。"
