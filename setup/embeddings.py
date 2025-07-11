import os
from dotenv import load_dotenv
from langchain_google_vertexai import VertexAIEmbeddings
from langchain_community.document_loaders import PyPDFLoader # Or any other suitable loader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_community.vectorstores.neo4j_vector import Neo4jVector

load_dotenv()

# --- Configuration ---
GCP_PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT")

# Neo4j connection details
NEO4J_URI = "bolt://localhost:7687"
NEO4J_USERNAME = "neo4j"
NEO4J_PASSWORD = "#Warriors30."

MANUALS_DIRECTORY = "./manuals"

# --- 1. Load Documents ---

all_docs = []
for filename in os.listdir(MANUALS_DIRECTORY):
    print(filename)
    if filename.endswith(".pdf"):
        loader = PyPDFLoader(os.path.join(MANUALS_DIRECTORY, filename))
        all_docs.extend(loader.load())


print(f"Loaded {len(all_docs)} documents.")

# --- 2. Initialize Components ---
embeddings = VertexAIEmbeddings(
    model_name="text-embedding-004",
    project=GCP_PROJECT_ID,
)

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=100)

docs_for_vectorstore = text_splitter.split_documents(all_docs)
print(f"Split documents into {len(docs_for_vectorstore)} chunks.")

# --- 3. Ingest into Neo4j using LangChain ---
print(f"Attempting to connect to Neo4j at: {NEO4J_URI}") # Add this line
print("Starting ingestion into Neo4j Vector Store...")
neo4j_vectorstore = Neo4jVector.from_documents(
    docs_for_vectorstore,
    embedding=embeddings,
    url=NEO4J_URI,
    username=NEO4J_USERNAME,
    password=NEO4J_PASSWORD,
    index_name="manual_chunks_langchain",  # Name for the vector index
    node_label="Chunk",                    # Label for the nodes created
    text_node_property="text",             # Property to store the chunk text
    embedding_node_property="embedding",   # Property to store the vector embedding
    create_id_index=True,                  # Creates an index on the node ID
)

