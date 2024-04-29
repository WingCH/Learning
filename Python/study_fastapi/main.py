from fastapi import FastAPI, HTTPException
from api.available_transcripts import AvailableTranscriptResponse, request_available_transcripts
from api.transcript import get_transcript, TranscriptResponse

app = FastAPI()


@app.get("/")
async def root():
    return {"message": "Hello World"}


@app.get("/youtube/{video_id}/available_transcripts", response_model=AvailableTranscriptResponse)
async def available_transcripts(video_id: str):
    return await request_available_transcripts(video_id)


@app.get("/youtube/{video_id}/transcript/{language}", response_model=TranscriptResponse)
async def transcript(video_id: str, language: str):
    return await get_transcript(video_id, language)


if __name__ == '__main__':
    import uvicorn

    uvicorn.run(app)
