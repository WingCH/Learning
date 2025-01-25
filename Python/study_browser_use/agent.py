from langchain_openai import ChatOpenAI
from browser_use import Agent
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

llm = ChatOpenAI(model="gpt-4o", api_key=os.getenv("OPENAI_API_KEY"))

async def main():
    agent = Agent(
        task="Find a one-way flight from Bali to Oman on 12 January 2025 on Google Flights. Return me the cheapest option.",
        llm=llm,
    )
    result = await agent.run()
    print(result)

asyncio.run(main())

# follow https://docs.browser-use.com/quickstart#set-up-your-llm-api-keys
# uv run agent.py
