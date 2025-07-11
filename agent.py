import os
from dotenv import load_dotenv

from google.adk.agents import Agent
from google.adk.tools import FunctionTool
from google.adk.tools.agent_tool import AgentTool

# Import LangChan and related components
from langchain_community.graphs import Neo4jGraph
from langchain.chains import GraphCypherQAChain
from langchain.prompts.prompt import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings

from .ticket_agent.agent import ticket_agent

from . import prompt

load_dotenv()

project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
location = os.getenv("GOOGLE_CLOUD_LOCATION")
api_key = os.getenv("GOOGLE_API_KEY")
url = "bolt:://localhost:7687"
username = "neo4j"
password = "#Warriors30."

print(url, username, password)

embeddings = GoogleGenerativeAIEmbeddings(model="models/text-embedding-004")
llm = ChatGoogleGenerativeAI(
            model="gemini-2.5-flash",
            google_api_key=api_key
        )


# --- 1. Connect to the Neo4j Knowledge Graph ---
graph = Neo4jGraph(
    url=url,
    username=username,
    password=password
)

graph.refresh_schema()

# --- 2. Create the LangChain QA Chain ---
CYPHER_GENERATION_TEMPLATE = prompt.CYPHER_GENERATION_TEMPLATE

CYPHER_GENERATION_PROMPT = PromptTemplate(
    input_variables=["schema", "question"], template=CYPHER_GENERATION_TEMPLATE
)

QA_TEMPLATE = prompt.QA_TEMPLATE

QA_PROMPT = PromptTemplate(
    input_variables=["context", "question"], template=QA_TEMPLATE
)

qa_chain = GraphCypherQAChain.from_llm(
    graph=graph,
    llm=ChatGoogleGenerativeAI(
            model="gemini-2.5-flash",
            google_api_key=api_key
        ),
    verbose=True,
    allow_dangerous_requests=True,
    cypher_prompt=CYPHER_GENERATION_PROMPT,
    qa_prompt=QA_PROMPT
)

# --- 3. Build the ADK FunctionTool ---
def query_knowledge_graph(query: str) -> str:

    print(f"Querying knowledge graph with: {query}")
    try:
        result = qa_chain.invoke({"query": query})

        return result.get('result', "No answer found.")
    except Exception as e:
        print(f"Error querying knowledge graph: {e}")
        return "Sorry, I encountered an error while trying to access the knowledge graph."

knowledge_graph_tool = FunctionTool(query_knowledge_graph)

# --- 4. Answer from Manuals ---
MANUALS_QA_TEMPLATE = prompt.MANUALS_QA_TEMPLATE

MANUALS_QA_PROMPT = PromptTemplate(
    input_variables=["context", "question"], template=MANUALS_QA_TEMPLATE
)

extract_equipment_prompt = PromptTemplate.from_template(
    "Extract the name of the equipment from the following user query. "
    "For example, from 'how do I fix the main chiller pump?', you should extract 'main chiller pump'. "
    "Only return the name of the equipment and nothing else.\n"
    "Query: {query}\n"
    "Equipment Name:"
)

equipment_extractor_chain = extract_equipment_prompt | llm | StrOutputParser()


def answer_from_manuals(query: str) -> str:
    """
    Use this tool to answer questions that can be found in technical manuals,
    datasheets, or other documents. It is best for "how-to" questions,
    troubleshooting, or finding specific technical specifications.
    """
    print(f"Searching manuals with vector search for: {query}")

    

    try:
        equipment_name = equipment_extractor_chain.invoke({"query": query})
        if not equipment_name:
            return "Could not identify a specific piece of equipment in the query."

        print(f"Hybrid Search: Identified equipment '{equipment_name}'")
        # This is a pure vector search query
        vector_search_query = """
            CALL db.index.fulltext.queryNodes('generic_names_and_descriptions', $equipment_name) YIELD node AS equipment, score
            WHERE 'Equipment' IN labels(equipment)
            WITH equipment ORDER BY score DESC LIMIT 1
            MATCH (equipment)-[:HAS_CHUNK]->(chunk)
            WITH chunk, gds.similarity.cosine(chunk.embedding, $question_embedding) AS similarity
            RETURN chunk.text AS text
            ORDER BY similarity DESC
            LIMIT 10
        """

        # Generate an embedding for the user's query
        query_embedding = embeddings.embed_query(query)

        # Run the vector search
        results = graph.query(vector_search_query, params={'equipment_name': equipment_name, 'question_embedding': query_embedding})
        
        # Extract the text from the results and collect unique sources
        context = "\\n\\n---\\n\\n".join([r['text'] for r in results])
        
        if not context:
            return "Sorry, I could not find any relevant information in the manuals."

        # Use the LLM to synthesize a final answer from the context
        qa_chain = MANUALS_QA_PROMPT | llm

        answer = qa_chain.invoke({
            "context": context,
            "question": query
        })

        return answer.content
        
    except Exception as e:
        print(f"Error in answer_from_manuals tool: {e}")
        return "Sorry, I encountered an error while searching the manuals."

manuals_tool = FunctionTool(answer_from_manuals)


# --- 5. Integrate the Tool into the ADK Agent ---
ROOT_AGENT_INSTRUCTIONS = prompt.ROOT_AGENT_INSTRUCTIONS

root_agent = Agent(
    model="gemini-2.5-flash",
    name='building_engineer_assistant',
    description='An intelligent assistant for building engineers that can answer complex questions by querying a knowledge graph of building assets.',
    tools=[knowledge_graph_tool, manuals_tool, AgentTool(agent=ticket_agent)],
    instruction=ROOT_AGENT_INSTRUCTIONS
)