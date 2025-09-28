#!/bin/bash

# Script to merge all MP3 files in a directory into a single MP3 file
# Uses environment variables for input directory and output file
# Handles file list creation and ffmpeg merge entirely within the script

# 使用方法を表示する関数
show_usage() {
    echo "使用方法:"
    echo "  環境変数を設定してスクリプトを実行してください。"
    echo ""
    echo "必須環境変数:"
    echo "  INPUT_MP3_DIR  - 入力MP3ファイルのディレクトリパス"
    echo "  OUTPUT_MP3     - 出力マージMP3ファイルのパス"
    echo ""
    echo "例:"
    echo "  export INPUT_MP3_DIR=\"./mp3/examtopics-dop-20250713-36\""
    echo "  export OUTPUT_MP3=\"./mp3/examtopics-dop-20250713-36-merged.mp3\""
    echo "  $0"
}

# 環境変数の確認
if [ -z "$INPUT_MP3_DIR" ] || [ -z "$OUTPUT_MP3" ]; then
    echo "エラー: 環境変数 INPUT_MP3_DIR, OUTPUT_MP3 の両方を設定してください。"
    echo ""
    show_usage
    exit 1
fi

MP3_INPUT_DIR="$INPUT_MP3_DIR"
MERGED_OUTPUT_FILE="$OUTPUT_MP3"

# 入力ディレクトリの存在確認
if [ ! -d "$MP3_INPUT_DIR" ]; then
    echo "エラー: 入力ディレクトリ '$MP3_INPUT_DIR' が見つかりません。"
    exit 1
fi

# MP3ファイルの存在確認
mp3_count=$(ls -1 "$MP3_INPUT_DIR"/*.mp3 2>/dev/null | wc -l)
if [ "$mp3_count" -eq 0 ]; then
    echo "エラー: MP3ファイルが見つかりません: $MP3_INPUT_DIR"
    exit 1
fi

# 出力ディレクトリの作成（必要に応じて）
output_dir=$(dirname "$MERGED_OUTPUT_FILE")
mkdir -p "$output_dir"

echo "Merging MP3 files..."
echo "Input directory: $MP3_INPUT_DIR"
echo "Output file: $MERGED_OUTPUT_FILE"
echo "Total MP3 files found: $mp3_count"
echo ""

# 一時的なファイルリストを作成
temp_filelist="/tmp/mp3_filelist_$$.txt"

echo "Creating file list for ffmpeg..."
# MP3ファイルを順番にソートしてファイルリストを作成（絶対パスを使用）
ls -1 "$MP3_INPUT_DIR"/item_*.mp3 2>/dev/null | sort -V | while read mp3_file; do
    echo "file '$mp3_file'" >> "$temp_filelist"
done

# ファイルリストの確認
if [ ! -s "$temp_filelist" ]; then
    echo "エラー: ファイルリストの作成に失敗しました。"
    rm -f "$temp_filelist"
    exit 1
fi

echo "Files to be merged:"
head -5 "$temp_filelist"
if [ "$mp3_count" -gt 5 ]; then
    echo "... (and $(($mp3_count - 5)) more files)"
fi
echo ""

# ffmpegを使用してMP3ファイルをマージ
echo "Starting ffmpeg merge process..."
echo "Command: ffmpeg -f concat -safe 0 -i $temp_filelist -c copy $MERGED_OUTPUT_FILE -y"

if ffmpeg -f concat -safe 0 -i "$temp_filelist" -c copy "$MERGED_OUTPUT_FILE" -y 2>/dev/null; then
    echo "✓ Merge completed successfully!"
    
    # 出力ファイルの情報を表示
    if [ -f "$MERGED_OUTPUT_FILE" ]; then
        file_size=$(ls -lh "$MERGED_OUTPUT_FILE" | awk '{print $5}')
        echo ""
        echo "Merged file information:"
        echo "  File: $MERGED_OUTPUT_FILE"
        echo "  Size: $file_size"
        
        # 再生時間を取得（ffmpegを使用）
        echo "Getting duration information..."
        duration=$(ffmpeg -i "$MERGED_OUTPUT_FILE" -f null - 2>&1 | grep "Duration" | head -1 | sed 's/.*Duration: \([^,]*\).*/\1/')
        if [ ! -z "$duration" ]; then
            echo "  Duration: $duration"
        fi
        
        echo ""
        echo "✓ Merge process completed successfully!"
    else
        echo "✗ Error: Output file was not created."
        rm -f "$temp_filelist"
        exit 1
    fi
else
    echo "✗ Error: ffmpeg merge failed."
    echo "Debugging information:"
    echo "File list content:"
    cat "$temp_filelist"
    echo ""
    echo "Trying ffmpeg with verbose output:"
    ffmpeg -f concat -safe 0 -i "$temp_filelist" -c copy "$MERGED_OUTPUT_FILE" -y
    rm -f "$temp_filelist"
    exit 1
fi

# 一時ファイルのクリーンアップ
echo "Cleaning up temporary files..."
rm -f "$temp_filelist"

echo ""
echo "=== MERGE SUMMARY ==="
echo "  Input directory: $MP3_INPUT_DIR"
echo "  Input files: $mp3_count MP3 files"
echo "  Output file: $MERGED_OUTPUT_FILE"
echo "  Status: ✓ SUCCESS"
echo "====================="
