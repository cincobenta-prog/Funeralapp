#!/usr/bin/env python3
"""
Digital Tribute - Master Memorial Video & Audio Compilation Pipeline
Automates the assembly of approved photo, audio, and video tributes into a unified 1080p master memorial presentation.
"""

import os
import json
import sys
import subprocess
from datetime import datetime

class MemorialCompilationEngine:
    def __init__(self, subject_data, tributes, output_dir="output"):
        self.subject = subject_data
        self.tributes = tributes
        self.output_dir = output_dir
        os.makedirs(output_dir, exist_ok=True)

    def generate_compilation_manifest(self):
        """Generates the timeline and transitions manifest for rendering."""
        manifest = {
            "title": f"In Loving Memory of {self.subject.get('first_name')} {self.subject.get('last_name')}",
            "dates": f"{self.subject.get('date_of_birth', '')} — {self.subject.get('date_of_death', '')}",
            "compiled_at": datetime.utcnow().isoformat(),
            "chapters": []
        }

        # Intro Card (5 seconds)
        manifest["chapters"].append({
            "type": "intro_card",
            "duration_seconds": 6,
            "title": manifest["title"],
            "dates": manifest["dates"],
            "photo_url": self.subject.get("photo_url")
        })

        # Group tributes by relationship intimacy
        relationship_order = [
            "spouse_partner", "son", "daughter", "father", "mother",
            "brother", "sister", "grandfather", "grandmother",
            "extended_family", "in_law", "chosen_family",
            "childhood_friend", "college_school_friend", "work_colleague_friend",
            "lifelong_friend", "travel_hobby_friend",
            "mentee_student", "neighbor", "community_faith_member", "admirer_acquaintance"
        ]

        for rel in relationship_order:
            rel_tributes = [t for t in self.tributes if t.get("relationship_type") == rel and t.get("status") == "approved"]
            for trib in rel_tributes:
                manifest["chapters"].append({
                    "type": "tribute_item",
                    "contributor_name": trib.get("contributor_name"),
                    "relationship": rel,
                    "media_type": trib.get("media_type"),
                    "media_url": trib.get("final_media_url") or trib.get("raw_media_url"),
                    "prompt": trib.get("prompt_text"),
                    "pillar": trib.get("pillar")
                })

        # Outro Card (5 seconds)
        manifest["chapters"].append({
            "type": "outro_card",
            "duration_seconds": 5,
            "text": "Forever Cherished in Our Hearts",
            "funeral_home": self.subject.get("funeral_home_name", "Evergreen Memorial Services")
        })

        manifest_path = os.path.join(self.output_dir, "compilation_manifest.json")
        with open(manifest_path, "w") as f:
            json.dump(manifest, f, indent=2)

        print(f"✓ Compilation manifest generated with {len(manifest['chapters'])} chapters: {manifest_path}")
        return manifest

if __name__ == "__main__":
    sample_subject = {
        "first_name": "Eleanor",
        "last_name": "Vance",
        "date_of_birth": "March 14, 1948",
        "date_of_death": "November 22, 2025",
        "photo_url": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&q=80",
        "funeral_home_name": "Evergreen Memorial Chapel"
    }

    sample_tributes = [
        {
            "contributor_name": "Robert Vance",
            "relationship_type": "spouse_partner",
            "media_type": "audio",
            "raw_media_url": "https://storage.supabase.co/raw/robert_audio.m4a",
            "prompt_text": "What's something she did every day that was a quiet act of devotion?",
            "pillar": "Help & Sacrifice",
            "status": "approved"
        },
        {
            "contributor_name": "Claire Vance-Miller",
            "relationship_type": "daughter",
            "media_type": "video",
            "raw_media_url": "https://storage.supabase.co/raw/claire_video.mp4",
            "prompt_text": "What's a moment she made you proud in a way that took your breath away?",
            "pillar": "Joy & Laughter",
            "status": "approved"
        },
        {
            "contributor_name": "Martha Hayes",
            "relationship_type": "childhood_friend",
            "media_type": "audio",
            "raw_media_url": "https://storage.supabase.co/raw/martha_audio.m4a",
            "prompt_text": "What was an adventure only the two of you knew about?",
            "pillar": "Witnessing in Action",
            "status": "approved"
        }
    ]

    engine = MemorialCompilationEngine(sample_subject, sample_tributes)
    engine.generate_compilation_manifest()
