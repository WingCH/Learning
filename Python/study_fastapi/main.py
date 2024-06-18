from fastapi import FastAPI

from api.analyze_receipts.analyze_receipts import request_analyze_receipts, ImageRequest, AnalyzeReceiptsResponse
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


@app.post("/analyze_receipts", response_model=AnalyzeReceiptsResponse)
async def analyze_receipts(image_request: ImageRequest):
    return await request_analyze_receipts(image_request)


if __name__ == '__main__':
    import uvicorn

    uvicorn.run(app)
