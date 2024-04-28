from fastapi import FastAPI, HTTPException
from api.available_transcripts import AvailableTranscriptResponse, request_available_transcripts

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/youtube/{video_id}/available_transcripts", response_model=AvailableTranscriptResponse)
async def available_transcripts(video_id: str):
    return await request_available_transcripts(video_id)
