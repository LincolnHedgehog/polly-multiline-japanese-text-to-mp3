#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import re
from replace_rules import replace_rules

def replace_targets(text, replace_rules):
    """
    テキスト内の特定のターゲットを置換する関数。
    
    :param text: 置換対象のテキスト
    :param replace_rules: 置換ルールのリスト
    :return: 置換後のテキスト
    """
    for rule in replace_rules:
        target = rule["target"]
        corrected = rule["corrected"]
        text = re.sub(rf'{target}', corrected, text, flags=re.IGNORECASE)
    return text

def update_item_001_ssml():
    """
    item_001のSSMLファイルのみを更新する関数。
    """
    try:
        # 元のJSONファイルを読み込み
        with open("examtopics-20250628-keyword.json", 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # item_001のコンテンツを取得
        item_001 = None
        for item in data:
            if item['id'] == 1:
                item_001 = item
                break
        
        if not item_001:
            print("エラー: item_001が見つかりません")
            return
        
        # コンテンツを変換
        original_content = item_001['content']
        converted_content = replace_targets(original_content, replace_rules)
        
        print("item_001のコンテンツ変換:")
        print(f"変換前: {original_content}")
        print(f"変換後: {converted_content}")
        print()
        
        # SSMLファイルを生成
        ssml_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="ja-JP">
<break time="1s"/>
{converted_content}
<break time="3s"/>
</speak>"""
        
        # SSMLファイルを保存
        ssml_file_path = "examtopics-20250628-keyword-converted/item_001.ssml"
        with open(ssml_file_path, 'w', encoding='utf-8') as f:
            f.write(ssml_content)
        
        print(f"item_001.ssmlファイルを更新しました: {ssml_file_path}")
        
    except FileNotFoundError as e:
        print(f"エラー: ファイルが見つかりません - {str(e)}")
    except Exception as e:
        print(f"エラーが発生しました: {str(e)}")

if __name__ == "__main__":
    print("item_001.ssmlファイルの更新を開始します...")
    update_item_001_ssml()
