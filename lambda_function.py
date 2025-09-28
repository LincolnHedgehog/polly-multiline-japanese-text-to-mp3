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

def generate_ssml_text(domainnumber, domainname, tasknumber, taskname, lesson, title, text):
    """
    SSMLテキストを生成する関数。
    
    :param domainnumber: ドメイン番号
    :param domainname: ドメイン名
    :param tasknumber: タスク番号
    :param taskname: タスク名
    :param lesson: レッスン番号
    :param title: タイトル
    :param text: テキスト
    :return: 生成されたSSMLテキスト
    """
    return (
        f"<speak> "
        f"<prosody rate=\"200%\"><break time=\"3s\"/>domain {domainnumber}<break time=\"1s\"/>{domainname}<break time=\"2s\"/>task {tasknumber}<break time=\"1s\"/>{taskname}<break time=\"2s\"/>lesson {lesson}<break time=\"1s\"/>{title}<break time=\"2s\"/>{text}<break time=\"3s\"/> "
        f"</prosody> "
        f"</speak>"
    )

def lambda_handler(event, context):
    """
    AWS Lambdaのハンドラー関数。
    
    :param event: イベントデータ
    :param context: コンテキストオブジェクト
    :return: レスポンスデータ
    """
    input_json = event
    
    # 入力データの取得
    domainnumber = input_json.get("domainnumber", 0)
    domainname = input_json.get("domainname", "")
    tasknumber = input_json.get("tasknumber", 0)
    taskname = input_json.get("taskname", "")
    script = input_json.get("script", {})
    lesson = script.get("lesson", 0)
    title = script.get("title", "")
    text = replace_targets(script.get("text", ""), replace_rules)

    # SSML名の生成
    ssmlname = f"domain{domainnumber:02}-task{tasknumber:02}-lesson{lesson:02}"

    # SSMLテキストの生成
    ssmltext = generate_ssml_text(domainnumber, domainname, tasknumber, taskname, lesson, title, text)

    # 出力JSONの作成
    output_ssml_json = {
        "ssmlname": ssmlname,
        "ssmltext": ssmltext
    }

    # デバッグ用の出力
    print('*** lambda_handler() output_ssml_json =', output_ssml_json)
    print('*** lambda_handler() json.dumps(output_ssml_json, indent=2) =', json.dumps(output_ssml_json, indent=2))

    # レスポンスの返却
    return {
        'statusCode': 200,
        "ssmlname": ssmlname,
        'body': output_ssml_json
    }