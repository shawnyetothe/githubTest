"use client";

import { Track, Skin } from "@/types";
import { content } from "@/data/content";

interface Props {
  track: Track;
  skin: Skin;
}

export default function ContentWindow({ track, skin }: Props) {
  const c = skin.colors;
  const sectionContent = content[track.section];

  return (
    <div
      className="flex flex-col"
      style={{
        background: c.bg,
        border: `1px solid ${c.border}`,
        borderTop: "none",
        fontFamily: "'Courier New', monospace",
        color: c.text,
        minHeight: "300px",
      }}
    >
      {/* Content title bar */}
      <div
        className="flex items-center justify-between px-2 py-1 text-xs uppercase tracking-widest select-none"
        style={{ background: c.titleBar, color: c.accent }}
      >
        <span>▶ Now Reading: {track.filename}</span>
        <span className="opacity-60">EOF</span>
      </div>

      {/* Scrollable content */}
      <div
        className="flex-1 p-4 overflow-y-auto text-sm leading-relaxed"
        style={{
          scrollbarWidth: "thin",
          scrollbarColor: `${c.accent} ${c.bgSecondary}`,
        }}
      >
        {sectionContent ?? (
          <p className="opacity-40">[ No content loaded ]</p>
        )}
      </div>

      {/* Status bar */}
      <div
        className="flex justify-between px-2 py-1 text-xs opacity-40 border-t"
        style={{ borderColor: c.border, color: c.text }}
      >
        <span>TRACK {String(track.id).padStart(2, "0")} / {track.section.toUpperCase().replace("_", " ")}</span>
        <span>{track.duration}</span>
      </div>
    </div>
  );
}
