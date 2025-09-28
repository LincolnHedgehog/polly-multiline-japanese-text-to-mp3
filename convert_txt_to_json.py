#!/usr/bin/env python3
"""
テキストファイルをJSON形式に変換するスクリプト
各行を個別のオブジェクトとして、IDとcontentを持つJSON配列に変換します。
"""

import json
import sys
import os

def convert_txt_to_json(input_file, output_file):
    """
    テキストファイルをJSON形式に変換する
    
    Args:
        input_file (str): 入力テキストファイルのパス
        output_file (str): 出力JSONファイルのパス
    """
    
    # 入力ファイルの存在確認
    if not os.path.exists(input_file):
        print(f"エラー: 入力ファイル '{input_file}' が見つかりません。")
        return False
    
    try:
        # テキストファイルを読み込み
        with open(input_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # 空行を除去し、改行文字を削除
        lines = [line.strip() for line in lines if line.strip()]
        
        # JSON形式のデータを作成
        json_data = []
        for i, line in enumerate(lines, 1):
            json_data.append({
                "id": i,
                "content": line
            })
        
        # JSONファイルに書き出し
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, ensure_ascii=False, indent=2)
        
        print(f"変換完了: {len(lines)} 行のデータを '{output_file}' に保存しました。")
        return True
        
    except Exception as e:
        print(f"エラーが発生しました: {e}")
        return False

def main():
    """メイン関数"""
    
    # デフォルトのファイル名
    default_input = "examtopics-20250628-keyword.txt"
    default_output = "examtopics-20250628-keyword.json"
    
    # コマンドライン引数の処理
    if len(sys.argv) == 1:
        # 引数なしの場合はデフォルトファイルを使用
        input_file = default_input
        output_file = default_output
    elif len(sys.argv) == 2:
        # 入力ファイルのみ指定された場合
        input_file = sys.argv[1]
        # 出力ファイル名を自動生成（拡張子を.jsonに変更）
        base_name = os.path.splitext(input_file)[0]
        output_file = f"{base_name}.json"
    elif len(sys.argv) == 3:
        # 入力と出力ファイルの両方が指定された場合
        input_file = sys.argv[1]
        output_file = sys.argv[2]
    else:
        print("使用方法:")
        print("  python convert_txt_to_json.py")
        print("  python convert_txt_to_json.py <入力ファイル>")
        print("  python convert_txt_to_json.py <入力ファイル> <出力ファイル>")
        print()
        print("例:")
        print("  python convert_txt_to_json.py")
        print("  python convert_txt_to_json.py data.txt")
        print("  python convert_txt_to_json.py data.txt output.json")
        return
    
    print(f"入力ファイル: {input_file}")
    print(f"出力ファイル: {output_file}")
    print()
    
    # 変換実行
    success = convert_txt_to_json(input_file, output_file)
    
    if success:
        print("変換が正常に完了しました。")
    else:
        print("変換に失敗しました。")
        sys.exit(1)

if __name__ == "__main__":
    main()
