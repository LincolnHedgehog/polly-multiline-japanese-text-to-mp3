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

def convert_json_content(input_file, output_file):
    """
    JSONファイルのcontentフィールドを変換する関数。
    
    :param input_file: 入力JSONファイルのパス
    :param output_file: 出力JSONファイルのパス
    """
    try:
        # JSONファイルを読み込み
        with open(input_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # 各エントリのcontentを変換
        for item in data:
            if 'content' in item:
                original_content = item['content']
                converted_content = replace_targets(original_content, replace_rules)
                item['content'] = converted_content
                
                # 変換結果をログ出力（最初の5件のみ）
                if item['id'] <= 5:
                    print(f"ID {item['id']}:")
                    print(f"  変換前: {original_content[:100]}...")
                    print(f"  変換後: {converted_content[:100]}...")
                    print()
        
        # 変換後のJSONを保存
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        
        print(f"変換完了: {len(data)}件のエントリを処理しました")
        print(f"出力ファイル: {output_file}")
        
    except FileNotFoundError:
        print(f"エラー: ファイル '{input_file}' が見つかりません")
    except json.JSONDecodeError:
        print(f"エラー: '{input_file}' は有効なJSONファイルではありません")
    except Exception as e:
        print(f"エラーが発生しました: {str(e)}")

if __name__ == "__main__":
    input_file = "examtopics-20250628-keyword.json"
    output_file = "examtopics-20250628-keyword-converted.json"
    
    print("日本語テキスト変換を開始します...")
    print(f"入力ファイル: {input_file}")
    print(f"出力ファイル: {output_file}")
    print()
    
    convert_json_content(input_file, output_file)
