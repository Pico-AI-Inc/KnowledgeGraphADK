from google.adk.agents import Agent
from . import prompt

import datetime

ticket_agent = Agent(
    name="ticket_agent",
    description="This agent guides a user through the process of creating a work order ticket.",
    model="gemini-2.5-flash", # Or your preferred model
    tools=[],
    instruction=prompt.TICKET_AGENT_INSTRUCTIONS,
)