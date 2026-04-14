"use client";

import { useState, useEffect, useCallback } from "react";
import { Track, Skin } from "@/types";
import AudioVisualizer from "./AudioVisualizer";

interface Props {
  activeTrack: Track;
  tracks: Track[];
  onNext: () => void;
  onPrev: () => void;
  skin: Skin;
  onSkinChange: (id: string) => void;
  skinOptions: Skin[];
}

const KONAMI_SEQUENCE = ["ArrowUp","ArrowUp","ArrowDown","ArrowDown","ArrowLeft","ArrowRight","ArrowLeft","ArrowRight","b","a"];

export default function PlayerWindow({
  activeTrack,
  tracks,
  onNext,
  onPrev,
  skin,
  onSkinChange,
  skinOptions,
}: Props) {
  const [isPlaying, setIsPlaying] = useState(true);
  const [elapsed, setElapsed] = useState(0);
  const [showEasterEgg, setShowEasterEgg] = useState(false);
  const [konamiIndex, setKonamiIndex] = useState(0);
  const [volume, setVolume] = useState(75);
  const c = skin.colors;

  // Parse track duration to seconds
  const durationSec = (() => {
    const [m, s] = activeTrack.duration.split(":").map(Number);
    return m * 60 + s;
  })();

  // Elapsed counter
  useEffect(() => {
    setElapsed(0);
  }, [activeTrack]);

  useEffect(() => {
    if (!isPlaying) return;
    const id = setInterval(() => {
      setElapsed((e) => (e >= durationSec ? 0 : e + 1));
    }, 1000);
    return () => clearInterval(id);
  }, [isPlaying, durationSec]);

  const formatTime = (sec: number) => {
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`;
  };

  // Konami code handler
  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (e.key === KONAMI_SEQUENCE[konamiIndex]) {
        const next = konamiIndex + 1;
        if (next === KONAMI_SEQUENCE.length) {
          setShowEasterEgg(true);
          setKonamiIndex(0);
        } else {
          setKonamiIndex(next);
        }
      } else {
        setKonamiIndex(0);
      }
    },
    [konamiIndex]
  );

  useEffect(() => {
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [handleKeyDown]);

  const progressPct = durationSec > 0 ? (elapsed / durationSec) * 100 : 0;

  return (
    <>
      {/* Easter egg modal */}
      {showEasterEgg && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center"
          style={{ background: "rgba(0,0,0,0.85)" }}
          onClick={() => setShowEasterEgg(false)}
        >
          <div
            className="text-center p-8 border"
            style={{
              background: c.bg,
              border: `2px solid ${c.accent}`,
              fontFamily: "'Courier New', monospace",
              color: c.accent,
            }}
          >
            <p className="text-2xl font-bold mb-2 animate-bounce">
              🦙 IT REALLY WHIPS THE LLAMA&apos;S ASS! 🦙
            </p>
            <p className="text-xs opacity-60 mt-4">— Winamp 2.x startup sound, 1997</p>
            <p className="text-xs opacity-40 mt-2">(click to close)</p>
          </div>
        </div>
      )}

      <div
        className="flex flex-col select-none"
        style={{
          background: c.bg,
          border: `1px solid ${c.border}`,
          fontFamily: "'Courier New', monospace",
          color: c.text,
        }}
      >
        {/* Title bar */}
        <div
          className="flex items-center justify-between px-2 py-1 text-xs"
          style={{ background: c.titleBar, color: c.accent }}
        >
          <span className="uppercase tracking-widest font-bold">
            ◈ WINAMP 2.∞ — Personal Site
          </span>
          <div className="flex gap-1">
            <span className="opacity-40 hover:opacity-100 cursor-pointer">_</span>
            <span className="opacity-40 hover:opacity-100 cursor-pointer">□</span>
            <span className="opacity-40 hover:opacity-100 cursor-pointer text-red-400">×</span>
          </div>
        </div>

        {/* Now playing display */}
        <div className="px-3 pt-3 pb-1">
          <div
            className="flex items-center gap-2 px-2 py-1 text-xs"
            style={{
              background: c.bgSecondary,
              border: `1px inset ${c.border}`,
            }}
          >
            <span style={{ color: c.accent }}>▶</span>
            <div className="overflow-hidden whitespace-nowrap flex-1">
              <span
                className="inline-block"
                style={{
                  animation: "marquee 12s linear infinite",
                  color: c.accent,
                }}
              >
                {String(activeTrack.id).padStart(2, "0")}. {activeTrack.filename.toUpperCase()} &nbsp;&nbsp;&nbsp;
              </span>
            </div>
            <span className="opacity-40 tabular-nums shrink-0">
              {formatTime(elapsed)} / {activeTrack.duration}
            </span>
          </div>
        </div>

        {/* Visualizer */}
        <div className="px-3 py-2">
          <div
            style={{
              background: c.bgSecondary,
              border: `1px inset ${c.border}`,
              padding: "4px",
            }}
          >
            <AudioVisualizer skin={skin} isPlaying={isPlaying} />
          </div>
        </div>

        {/* Progress bar */}
        <div className="px-3 pb-2">
          <div
            className="h-2 w-full rounded-sm overflow-hidden cursor-pointer"
            style={{ background: c.bgSecondary, border: `1px solid ${c.border}` }}
            onClick={(e) => {
              const rect = e.currentTarget.getBoundingClientRect();
              const pct = (e.clientX - rect.left) / rect.width;
              setElapsed(Math.floor(pct * durationSec));
            }}
          >
            <div
              className="h-full transition-all duration-1000"
              style={{
                width: `${progressPct}%`,
                background: `linear-gradient(to right, ${c.accent}, ${c.accentHover})`,
              }}
            />
          </div>
        </div>

        {/* Controls row */}
        <div className="flex items-center justify-between px-3 pb-2 gap-2">
          {/* Transport buttons */}
          <div className="flex gap-1">
            {[
              { label: "⏮", title: "Previous", action: onPrev },
              { label: "⏪", title: "Rewind", action: () => setElapsed((e) => Math.max(0, e - 10)) },
              {
                label: isPlaying ? "⏸" : "▶",
                title: isPlaying ? "Pause" : "Play",
                action: () => setIsPlaying((p) => !p),
              },
              { label: "⏩", title: "Fast Forward", action: () => setElapsed((e) => Math.min(durationSec, e + 10)) },
              { label: "⏭", title: "Next", action: onNext },
            ].map((btn) => (
              <button
                key={btn.label}
                onClick={btn.action}
                title={btn.title}
                className="w-7 h-7 flex items-center justify-center text-xs transition-all duration-100"
                style={{
                  background: c.buttonBg,
                  color: c.buttonText,
                  border: `1px outset ${c.border}`,
                  borderRadius: "2px",
                }}
                onMouseDown={(e) =>
                  ((e.currentTarget as HTMLButtonElement).style.borderStyle = "inset")
                }
                onMouseUp={(e) =>
                  ((e.currentTarget as HTMLButtonElement).style.borderStyle = "outset")
                }
              >
                {btn.label}
              </button>
            ))}
          </div>

          {/* Volume slider */}
          <div className="flex items-center gap-1 text-xs opacity-60">
            <span>VOL</span>
            <input
              type="range"
              min={0}
              max={100}
              value={volume}
              onChange={(e) => setVolume(Number(e.target.value))}
              className="w-16 accent-current"
              style={{ accentColor: c.accent }}
            />
            <span className="tabular-nums w-6 text-right">{volume}</span>
          </div>
        </div>

        {/* Skin selector + info row */}
        <div
          className="flex items-center justify-between px-3 py-1 text-xs border-t"
          style={{ borderColor: c.border, color: c.textDim }}
        >
          <div className="flex items-center gap-2">
            <span>SKIN:</span>
            {skinOptions.map((s) => (
              <button
                key={s.id}
                onClick={() => onSkinChange(s.id)}
                className="px-1.5 py-0.5 transition-all"
                style={{
                  background: skin.id === s.id ? c.accent : c.buttonBg,
                  color: skin.id === s.id ? c.bg : c.textDim,
                  border: `1px solid ${c.border}`,
                  borderRadius: "2px",
                  fontSize: "10px",
                }}
              >
                {s.name}
              </button>
            ))}
          </div>
          <span className="opacity-40 text-right" style={{ fontSize: "10px" }}>
            ↑↑↓↓←→←→BA for easter egg
          </span>
        </div>
      </div>

      <style jsx global>{`
        @keyframes marquee {
          0% { transform: translateX(100%); }
          100% { transform: translateX(-100%); }
        }
      `}</style>
    </>
  );
}
