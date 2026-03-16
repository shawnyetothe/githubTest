"use client";

import { Track, Skin } from "@/types";

interface Props {
  tracks: Track[];
  activeTrack: Track;
  onSelect: (track: Track) => void;
  skin: Skin;
}

export default function Playlist({ tracks, activeTrack, onSelect, skin }: Props) {
  const c = skin.colors;

  return (
    <div
      className="flex flex-col"
      style={{
        background: c.bgSecondary,
        border: `1px solid ${c.border}`,
        borderTop: "none",
        fontFamily: "'Courier New', monospace",
      }}
    >
      {/* Playlist title bar */}
      <div
        className="flex items-center justify-between px-2 py-1 text-xs uppercase tracking-widest select-none"
        style={{ background: c.titleBar, color: c.accent }}
      >
        <span>★ Playlist Editor</span>
        <span className="opacity-60">{tracks.length} entries</span>
      </div>

      {/* Track list */}
      <div className="flex flex-col">
        {tracks.map((track) => {
          const isActive = track.id === activeTrack.id;
          return (
            <button
              key={track.id}
              onClick={() => onSelect(track)}
              className="flex items-center justify-between px-3 py-1.5 text-xs text-left transition-all duration-100 group"
              style={{
                background: isActive ? c.trackHighlight : "transparent",
                color: isActive ? c.accent : c.textDim,
                borderLeft: isActive ? `2px solid ${c.accent}` : "2px solid transparent",
              }}
              onMouseEnter={(e) => {
                if (!isActive) {
                  (e.currentTarget as HTMLButtonElement).style.background = c.trackHighlight;
                  (e.currentTarget as HTMLButtonElement).style.color = c.text;
                }
              }}
              onMouseLeave={(e) => {
                if (!isActive) {
                  (e.currentTarget as HTMLButtonElement).style.background = "transparent";
                  (e.currentTarget as HTMLButtonElement).style.color = c.textDim;
                }
              }}
            >
              <span className="flex items-center gap-2 overflow-hidden">
                <span className="opacity-40 shrink-0">
                  {String(track.id).padStart(2, "0")}
                </span>
                <span className="truncate">{track.filename}</span>
              </span>
              <span className="opacity-40 ml-2 shrink-0 tabular-nums">
                {track.duration}
              </span>
            </button>
          );
        })}
      </div>

      {/* Footer */}
      <div
        className="flex justify-between px-2 py-1 text-xs opacity-40 mt-auto border-t"
        style={{ borderColor: c.border, color: c.text }}
      >
        <span>
          {tracks.reduce((sum, t) => {
            const [m, s] = t.duration.split(":").map(Number);
            return sum + m * 60 + s;
          }, 0) / 60 | 0}:
          {String(tracks.reduce((sum, t) => {
            const [m, s] = t.duration.split(":").map(Number);
            return sum + m * 60 + s;
          }, 0) % 60).padStart(2, "0")} total
        </span>
        <span>SELECTED: {activeTrack.filename}</span>
      </div>
    </div>
  );
}
