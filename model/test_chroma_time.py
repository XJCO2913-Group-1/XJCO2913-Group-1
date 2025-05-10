import time
from langchain.embeddings import HuggingFaceEmbeddings
from langchain.vectorstores import Chroma
from config.config import *


# Instantiate the embedding model without cache_folder
embedding_model = HuggingFaceEmbeddings(
    model_name=EMBEDDING_MODEL_NAME,
    cache_folder=EMBEDDING_MODEL_PATH
)

# Initialize the vector store (Chroma) with the embedding function
vectorstore = Chroma(
    persist_directory=PERSIST_DIRECTORY, 
    embedding_function=embedding_model,
    collection_name=COLLECTION_NAME
)

# Define a query for testing
query ="单车有哪几种时间选择"

# Measure execution time for similarity search
start_time = time.time()

# Perform the similarity search with relevance scores
similarity = vectorstore.similarity_search_with_relevance_scores(query)

# Check if the relevance score meets the threshold

    # Perform the similarity search to get results
results = vectorstore.similarity_search(query, k=SEARCH_NUMBER)

# Measure elapsed time
elapsed_time = time.time() - start_time
print(f"Similarity search completed in {elapsed_time:.4f} seconds.")

# Output the search results
print("Search Results:", results)
