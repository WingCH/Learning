from fastapi import HTTPException
from pydantic import BaseModel
from libs.youtube_transcript_api.youtube_transcript_api import YouTubeTranscriptApi
from typing import List, Optional


# class AvailableTranslationLanguage(BaseModel):
#     language: Optional[str] = None
#     language_code: Optional[str] = None

class AvailableTranscript(BaseModel):
    video_id: str = None
    language: Optional[str] = None
    language_code: Optional[str] = None
    is_generated: Optional[bool] = None
    is_translatable: Optional[bool] = None
    # translation_languages: Optional[List[TranslationLanguage]] = None


class AvailableTranscriptResponse(BaseModel):
    video_id: str
    available_transcripts: List[AvailableTranscript]


async def request_available_transcripts(video_id: str):
    try:
        transcripts = YouTubeTranscriptApi.list_transcripts(video_id)
        transcript_details = [
            AvailableTranscript(
                video_id=transcript.video_id,
                language=transcript.language,
                language_code=transcript.language_code,
                is_generated=transcript.is_generated,
                is_translatable=transcript.is_translatable,
                # translation_languages=[
                #     TranslationLanguage(language=lang.get('language'), language_code=lang.get('language_code'))
                #     for lang in transcript.translation_languages
                # ]
            ) for transcript in transcripts
        ]
        return AvailableTranscriptResponse(video_id=video_id, available_transcripts=transcript_details)
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))
