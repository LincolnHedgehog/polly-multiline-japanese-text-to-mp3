#!/bin/bash

# Script to convert SSML files to MP3 using Amazon Polly
# Uses voice mapping files to determine the correct voice for each item

# 使用方法を表示する関数
show_usage() {
    echo "使用方法:"
    echo "  環境変数を設定してスクリプトを実行してください。"
    echo ""
    echo "必須環境変数:"
    echo "  INPUT_SSML  - 入力SSMLファイルのディレクトリパス"
    echo "  OUTPUT_MP3  - 出力MP3ファイルのディレクトリパス"
    echo ""
    echo "例:"
    echo "  export INPUT_SSML=\"./ssml/examtopics-dop-20250713-36\""
    echo "  export OUTPUT_MP3=\"./mp3/examtopics-dop-20250713-36\""
    echo "  $0"
}

# 環境変数の確認
if [ -z "$INPUT_SSML" ] || [ -z "$OUTPUT_MP3" ]; then
    echo "エラー: 環境変数 INPUT_SSML, OUTPUT_MP3 の両方を設定してください。"
    echo ""
    show_usage
    exit 1
fi

SSML_DIR="$INPUT_SSML"
MP3_DIR="$OUTPUT_MP3"

# 入力ディレクトリの存在確認
if [ ! -d "$SSML_DIR" ]; then
    echo "エラー: 入力ディレクトリ '$SSML_DIR' が見つかりません。"
    exit 1
fi

# Create MP3 output directory if it doesn't exist
mkdir -p "$MP3_DIR"

echo "Converting SSML files to MP3 using Amazon Polly..."
echo "Source directory: $SSML_DIR"
echo "Output directory: $MP3_DIR"
echo ""

# Count total SSML files
total_files=$(ls -1 "$SSML_DIR"/*.ssml 2>/dev/null | wc -l)
if [ "$total_files" -eq 0 ]; then
    echo "エラー: SSMLファイルが見つかりません: $SSML_DIR"
    exit 1
fi

echo "Total SSML files found: $total_files"
echo ""

# Process all SSML files
current=0
for ssml_file in "$SSML_DIR"/item_*.ssml; do
    if [[ -f "$ssml_file" ]]; then
        current=$((current + 1))
        
        # Extract item number from filename
        filename=$(basename "$ssml_file" .ssml)
        item_num="${filename#item_}"
        
        voice_file="$SSML_DIR/item_${item_num}.voice"
        mp3_file="$MP3_DIR/item_${item_num}.mp3"
        
        # Get voice from corresponding .voice file
        if [[ -f "$voice_file" ]]; then
            voice_id=$(cat "$voice_file")
        else
            voice_id="Kazuha"  # Default voice if .voice file is missing
            echo "Warning: Voice file not found for item_${item_num}, using default voice: $voice_id"
        fi
        
        echo "[$current/$total_files] Converting item_${item_num} with voice: $voice_id"
        
        # Convert SSML to MP3 using Amazon Polly
        if aws polly synthesize-speech \
            --engine neural \
            --language-code ja-JP \
            --output-format mp3 \
            --voice-id "$voice_id" \
            --text-type ssml \
            --text "file://$ssml_file" \
            "$mp3_file" > /dev/null 2>&1; then
            
            # Get file size for confirmation
            file_size=$(ls -lh "$mp3_file" | awk '{print $5}')
            echo "  ✓ Success: item_${item_num}.mp3 ($file_size)"
        else
            echo "  ✗ Failed: item_${item_num}"
        fi
        echo ""
    fi
done

echo "Conversion completed!"
echo "MP3 files created in: $MP3_DIR"
echo "Total MP3 files created: $(ls -1 "$MP3_DIR"/*.mp3 2>/dev/null | wc -l)"
echo ""
echo "Files created:"
ls -la "$MP3_DIR"/*.mp3 2>/dev/null || echo "No MP3 files found"
