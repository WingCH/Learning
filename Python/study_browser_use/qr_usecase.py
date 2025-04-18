from langchain_openai import ChatOpenAI
from browser_use import Agent
import asyncio
from dotenv import load_dotenv
load_dotenv()

async def main():
    agent = Agent(
        task=(
            "打開 https://qr.wingch.site/，"
            "找到頁面中唯一的文字輸入框（或 placeholder 為 '請輸入內容'），"
            "輸入 'hello world'，"
            "點擊生成 QR code 的按鈕，"
            "然後對頁面進行截圖並保存。"
        ),
        llm=ChatOpenAI(model="gpt-4o"),
    )
    await agent.run()

asyncio.run(main())
