from fastapi import FastAPI
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
app = FastAPI()


@app.get("/embed")
def embed(q: str):
    return {"embedding": model.encode(q).tolist()}
