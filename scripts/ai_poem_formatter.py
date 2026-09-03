#!/usr/bin/env python3
"""
Digital Tribute - AI Memorial Stanza & Poem Formatter
Converts spoken audio transcripts or conversational memories into elegant,
editorial poetic stanzas suited for the Keepsake Coffee Table Book.
"""

import sys
import json
import re

def format_into_poetic_stanza(raw_transcript, author_name, relationship):
    """
    Cleans spoken pauses, organizes rhythm, and breaks thoughts into elegant 4-line stanzas.
    """
    # Clean filler words
    cleaned = re.sub(r'\b(um|uh|like|you know|sort of)\b', '', raw_transcript, flags=re.IGNORECASE)
    cleaned = re.sub(r'\s+', ' ', cleaned).strip()

    sentences = [s.strip() for s in re.split(r'[.!?]+', cleaned) if len(s.strip()) > 5]

    stanzas = []
    current_lines = []
    for s in sentences:
        # Break longer sentences into natural poetic cadences
        words = s.split(' ')
        if len(words) > 8:
            mid = len(words) // 2
            current_lines.append(' '.join(words[:mid]))
            current_lines.append(' '.join(words[mid:]))
        else:
            current_lines.append(s)

        if len(current_lines) >= 4:
            stanzas.append('\n'.join(current_lines[:4]))
            current_lines = current_lines[4:]

    if current_lines:
        stanzas.append('\n'.join(current_lines))

    formatted_poem = '\n\n'.join(stanzas)
    signature = f"— {author_name}, {relationship}"

    return {
        "poem_body": formatted_poem,
        "signature": signature,
        "status": "formatted"
    }

if __name__ == "__main__":
    sample_text = (
        "Every morning began with quiet grace and a warm cup of chamomile tea on the counter. "
        "She left notes upon the kitchen island, nineteen thousand notes over fifty years of marriage. "
        "They were words of steady courage that held our house upright through every storm. "
        "She never asked for gratitude, only that we met the morning with hope."
    )

    result = format_into_poetic_stanza(sample_text, "Robert Vance", "Husband of 52 Years")
    print(json.dumps(result, indent=2))
