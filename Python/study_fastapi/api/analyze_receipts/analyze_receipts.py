import os
from typing import Optional, List

from fastapi import FastAPI, HTTPException, Request
from openai.types.chat import ChatCompletion
from pydantic import BaseModel, Field, model_validator
from openai import OpenAI
from dotenv import load_dotenv
import json


class ImageRequest(BaseModel):
    base64_image: str


class ReceiptRecord(BaseModel):
    amount: float = Field(..., description="Amount Name"),
    currency: Optional[str] = Field(None, description="Currency", example="HKD", enum=["HKD", "USD", "CNY", "JPY"]),
    account: Optional[str] = Field(None, description="Account", enum=[
        "MPOWER", "錢包", "中信 Motion", "恒生", "TAP AND GO", "中國工商銀行",
        "DBS COMPASS visa", "HSBC Red Card", "HKBC", "WeLab", "MOX", "Citibank",
        "Payme", "Apple Watch 八達通", "Za Bank", "原味家作", "iPhone 八達通",
        "Fusion Bank 富融", "富途牛牛", "livi", "恒生mum", "AAX", "華盛", "SoFi",
        "Mox Credit", "幣安", "Crypto.com Visa", "livi PayLater", "長橋證券",
        "馬會", "Kikitrade", "微牛", "微信支付 內地", "渣打 Smart", "Samsung Pay Octopus",
        "Apple Gift card", "Deliveroo", "Foodpanda", "Q Credit Card", "HSBC Visa Signature",
        "八達通錢包", "Sim credit card", "中國工商(媽)", "漲樂金球通", "日元現金",
        "Suica", "杯", "老虎證券", "App Store", "Alipay PayLater", "中銀 Chill Card",
        "HSBC Pulse銀聯雙幣鑽石信用卡", "台幣", "Ant Bank", "OpenAI", "Anthropic Claude",
        "Wildcard", "Steam", "Pixel Octopus"
    ])
    subcategory: str = Field(..., description="Subcategory Name", enum=[
        "借款", "口罩", "餘額調整", "借入", "電影", "獎金", "市場", "轉帳", "晚餐", "午餐",
        "配件", "保險", "早餐", "衣物", "社交", "Apps 月費", "電子產品", "薪水", "信用卡繳款",
        "入八達通", "家用", "提款", "Apple news", "兌換", "夜店", "電話費", "美妝保養", "其他",
        "通話費", "美容美髮", "Apps", "精品", "點心", "計程車", "Apple Store", "飲料", "投資",
        "門診", "應用軟體", "公車", "日常用品", "鞋子", "禮物", "遊樂園",
        "Service", "消遣", "影音", "利息", "課程", "包包", "展覽", "尿袋", "彩券", "小巴",
        "遊戲", "興趣班", "二手", "政府", "Design", "未知", "火車", "書籍", "捷運", "手續費",
        "教材", "折扣", "博弈", "捐款", "醫療用品", "家電", "藥品", "電費", "代收", "租充電器",
        "訂金", "活動", "健康檢查", "運費", "水果", "學車", "扭蛋", "稅金",
        "汽車", "運動", "機票", "住宿", "洗衣費", "App Development", "旅行", "船票"
    ])

    store: Optional[str] = Field(None, description="Store Name", example="McDonald's"),
    note: Optional[str] = Field(None, description="Note", example="Big Mac"),
    date: Optional[str] = Field(None, description="YYYY.MM.dd"),
    time: Optional[str] = Field(None, description="HH:mm"),
    credibility: float = Field(..., ge=0, le=1, description="credibility score"),
    url: Optional[str] = Field(None, description="moze3 url scheme", example="moze3://new?amount=18.0&currency=HKD"
                                                                             "&subcategory=Apps&store=腾讯视频&note=《庆余年第二季》全网独播&date=2024.06.02&time=03:34")

    def __init__(self, **data):
        super().__init__(**data)
        amount_param = f"amount={self.amount}"
        currency_param = f"currency={self.currency}" if self.currency else ""
        subcategory_param = f"subcategory={self.subcategory}"
        store_param = f"store={self.store}" if self.store else ""
        note_param = f"note={self.note}" if self.note else ""
        date_param = f"date={self.date}" if self.date else ""
        time_param = f"time={self.time}" if self.time else ""

        self.url = f"""moze3://new?{amount_param}&{currency_param}&{subcategory_param}&{store_param}&{note_param}&{date_param}&{time_param}"""


class AnalyzeReceiptsResponse(BaseModel):
    detected_records: List[ReceiptRecord]
    raw_data: ChatCompletion


async def request_analyze_receipts(image_request: ImageRequest) -> AnalyzeReceiptsResponse:
    try:
        load_dotenv()
        client = OpenAI(
            # This is the default and can be omitted
            api_key=os.getenv('OPENAI_API_KEY')
        )
        current_directory = os.path.dirname(__file__)
        schema_file_path = os.path.join(current_directory, 'schema.json')
        with open(schema_file_path, 'r', encoding='utf-8') as f:
            schema_content = json.dumps(json.load(f), indent=4)
        system_prompt = f""" 
        I will provide you with transaction screenshots. Your task is to analyze the screenshots and generate at least one transaction record based on the following JSON schema. If the screenshots are too complex or ambiguous (e.g., multiple numbers appear, such as discounts), you can generate multiple possible transaction records for me to choose from. Ensure that if the transaction screenshot does not mention an account, leave the account field blank.

        Settings:
        1. Currency: If the screenshots do not explicitly mention the currency, infer the currency based on the language of the screenshots:
            - Traditional Chinese (繁體中文) = HKD
            - Simplified Chinese (简体中文) = CNY
            - Japanese (日本語) = JPY
            - English = USD

        2. Subcategory: Try to determine the subcategory based on the product name and store name mentioned in the screenshots.

        JSON Schema: {schema_content}

        Steps:
        1. Extract Transaction Details: Analyze the screenshot to extract the transaction date, description, amount, and any account information.
        2. Determine Currency: If the currency is not explicitly mentioned, infer it based on the language of the screenshot.
        3. Identify Subcategory: Use the product name and store name to infer the subcategory of the transaction.
        4. Handle Ambiguities: If the screenshot contains complex or ambiguous information (e.g., multiple amounts or unclear descriptions), generate multiple possible transaction records for selection.

        Provide the analyzed transaction records in the specified JSON format.
        """
        response: ChatCompletion = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                dict(role="system", content=system_prompt),
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": image_request.base64_image
                            }
                        },
                    ],
                }
            ],
            temperature=1,
            response_format={
                "type": "json_object"
            },
            stream=False
        )
        message_content = response.choices[0].message.content
        data = json.loads(message_content)
        detected_records = data.get('detected_records', [])
        return AnalyzeReceiptsResponse(
            detected_records=[ReceiptRecord(**record) for record in detected_records],
            raw_data=response
        )
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
