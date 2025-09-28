#!/bin/bash

# Script to generate individual SSML files from converted JSON data
# Compatible with Amazon Polly limitations (no audio/voice tags)
# Each item gets its own SSML file with rotating voices managed by filename
# Uses replace_rules.py to improve Japanese pronunciation

# 使用方法を表示する関数
show_usage() {
    echo "使用方法:"
    echo "  環境変数を設定してスクリプトを実行してください。"
    echo ""
    echo "必須環境変数:"
    echo "  INPUT_JSON  - 入力JSONファイルのパス"
    echo "  INPUT_SSML  - 出力ディレクトリパス（SSMLファイルとVOICEファイルの両方を出力）"
    echo ""
    echo "例:"
    echo "  export INPUT_JSON=\"./json/data.json\""
    echo "  export INPUT_SSML=\"./ssml\""
    echo "  $0"
}

# 環境変数の確認
if [ -z "$INPUT_JSON" ] || [ -z "$INPUT_SSML" ]; then
    echo "エラー: 環境変数 INPUT_JSON, INPUT_SSML の両方を設定してください。"
    echo ""
    show_usage
    exit 1
fi

JSON_FILE="$INPUT_JSON"
SSML_OUTPUT_DIR="$INPUT_SSML"
VOICE_OUTPUT_DIR="$INPUT_SSML"

# Neural voices to rotate through (managed by filename, not SSML)
VOICES=("Kazuha" "Tomoko" "Takumi")

# 入力ファイルの存在確認
if [ ! -f "$JSON_FILE" ]; then
    echo "エラー: 入力ファイル '$JSON_FILE' が見つかりません。"
    exit 1
fi

# replace_rules.pyの存在確認
if [ ! -f "./replace_rules.py" ]; then
    echo "エラー: replace_rules.py が見つかりません。"
    exit 1
fi

# 出力ディレクトリの作成
mkdir -p "$SSML_OUTPUT_DIR"

echo "Creating SSML files from converted JSON data..."
echo "Input JSON: $JSON_FILE"
echo "Output directory: $SSML_OUTPUT_DIR (both SSML and voice files)"
echo "Note: Using replace_rules.py to improve Japanese pronunciation"

# Create a temporary Python script to process text using replace_rules
cat > /tmp/process_text.py << 'EOF'
#!/usr/bin/env python3
import sys
import os

# Add current directory to path to import replace_rules
sys.path.insert(0, os.getcwd())

try:
    from replace_rules import replace_rules
except ImportError:
    print("Error: Could not import replace_rules", file=sys.stderr)
    sys.exit(1)

def process_text(text):
    """Apply replacement rules to improve Japanese pronunciation"""
    processed_text = text
    for rule in replace_rules:
        processed_text = processed_text.replace(rule["target"], rule["corrected"])
    return processed_text

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 process_text.py 'text_to_process'", file=sys.stderr)
        sys.exit(1)
    
    input_text = sys.argv[1]
    processed_text = process_text(input_text)
    print(processed_text)
EOF

chmod +x /tmp/process_text.py

# Read JSON and extract content for each item
jq -r '.[] | "\(.id)|\(.content)"' "$JSON_FILE" | while IFS='|' read -r id content; do
    # Calculate voice index (rotate through 3 voices)
    voice_index=$(( (id - 1) % 3 ))
    voice_name="${VOICES[$voice_index]}"
    
    # Format item number with leading zeros
    item_num=$(printf "%03d" "$id")
    
    # Process content using replace_rules.py to improve pronunciation
    processed_content=$(python3 /tmp/process_text.py "$content")
    
    # Create SSML file with processed content
    cat > "$SSML_OUTPUT_DIR/item_${item_num}.ssml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="ja-JP">
<break time="1s"/>
$processed_content
<break time="3s"/>
</speak>
EOF
    
    # Create a voice mapping file for reference
    echo "$voice_name" > "$VOICE_OUTPUT_DIR/item_${item_num}.voice"
    
    echo "Created item_${item_num}.ssml (voice: $voice_name) - Text processed for better pronunciation"
done

# Clean up temporary file
rm -f /tmp/process_text.py

echo ""
echo "All SSML files have been created in: $SSML_OUTPUT_DIR"
echo "All voice files have been created in: $SSML_OUTPUT_DIR"
echo "Total SSML files created: $(ls -1 "$SSML_OUTPUT_DIR"/*.ssml 2>/dev/null | wc -l)"
echo "Total voice files created: $(ls -1 "$SSML_OUTPUT_DIR"/*.voice 2>/dev/null | wc -l)"
echo ""
echo "Voice mapping files (.voice) created for reference:"
echo "- Use these files to determine which voice to use with Amazon Polly"
echo "- Example: aws polly synthesize-speech --voice-id \$(cat $SSML_OUTPUT_DIR/item_001.voice) ..."
echo ""
echo "Text processing completed using replace_rules.py for improved Japanese pronunciation"
