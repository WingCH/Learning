from fastapi import HTTPException
from youtube_transcript_api import YouTubeTranscriptApi
from typing import List
from pydantic import BaseModel, Field


class TranscriptSegment(BaseModel):
    text: str = Field(..., description="The transcript text.", example="♪ Don't let me go ♪")
    start: float = Field(..., description="Start time of the transcript segment in seconds.", example=8.374)
    duration: float = Field(..., description="Duration of the transcript segment in seconds.", example=3.471)


class TranscriptResponse(BaseModel):
    video_id: str = Field(..., description="The unique identifier for the YouTube video.", example="bks2zGnssMY")
    language: str = Field(..., description="The language of the transcript.", example="en")
    transcript: List[TranscriptSegment] = Field(...,
                                                description="List of transcript segments containing text, start time, "
                                                            "and duration.")


async def get_transcript(video_id: str, language: str) -> TranscriptResponse:
    try:
        transcript_result = YouTubeTranscriptApi.get_transcript(video_id, languages=[language])
        segments = [TranscriptSegment(**segment) for segment in transcript_result]
        return TranscriptResponse(
            video_id=video_id,
            language=language,
            transcript=segments
        )
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
