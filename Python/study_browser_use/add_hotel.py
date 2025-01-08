from langchain_openai import ChatOpenAI
from browser_use import Agent
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

llm = ChatOpenAI(model="gpt-4o", api_key=os.getenv("OPENAI_API_KEY"))

async def main():
    agent = Agent(
        task=f"""
        Go to xxxx
        Login with username: xxxx
        Password: xxxx
        Select "Hotels" from the menu.
        Click the "Add Hotel" button to navigate to the hotel creation page.
        Fill in all fields with dummy data.
        It's fine to set the "Hotel Detail Page" to `OFF`.
        Click "Save."
        View the list of all hotels in the table.
        """,
        llm=llm,
    )
    result = await agent.run()
    print(result)

asyncio.run(main())

# follow https://docs.browser-use.com/quickstart#set-up-your-llm-api-keys
# uv run agent.py
