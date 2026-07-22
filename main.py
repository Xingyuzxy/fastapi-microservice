from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/nihao")
def read_root():
    return {"Nihao": "Shijie"}