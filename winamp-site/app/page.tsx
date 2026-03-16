"use client";

import { useState } from "react";
import PlayerWindow from "@/components/PlayerWindow";
import Playlist from "@/components/Playlist";
import ContentWindow from "@/components/ContentWindow";
import { skins } from "@/data/skins";
import playlistData from "@/data/playlist.json";
import { Track } from "@/types";

const tracks: Track[] = playlistData as Track[];

export default function Home() {
  const [activeTrack, setActiveTrack] = useState<Track>(tracks[0]);
  const [activeSkinId, setActiveSkinId] = useState("classic");

  const skin = skins.find((s) => s.id === activeSkinId) ?? skins[0];
  const c = skin.colors;

  const handleNext = () => {
    const idx = tracks.findIndex((t) => t.id === activeTrack.id);
    setActiveTrack(tracks[(idx + 1) % tracks.length]);
  };

  const handlePrev = () => {
    const idx = tracks.findIndex((t) => t.id === activeTrack.id);
    setActiveTrack(tracks[(idx - 1 + tracks.length) % tracks.length]);
  };

  return (
    <main
      className="min-h-screen flex items-start justify-center p-4 md:p-8"
      style={{
        background: `radial-gradient(ellipse at top, ${c.titleBar}44, ${c.bg} 60%)`,
        backgroundColor: c.bg,
      }}
    >
      <div className="w-full max-w-2xl flex flex-col gap-0 mt-8">
        {/* Header / branding */}
        <div
          className="text-center py-3 mb-4 text-xs tracking-widest uppercase"
          style={{ color: c.textDim, fontFamily: "'Courier New', monospace" }}
        >
          <span>★ shawn.personal — winamp edition ★</span>
        </div>

        {/* Player window */}
        <PlayerWindow
          activeTrack={activeTrack}
          tracks={tracks}
          onNext={handleNext}
          onPrev={handlePrev}
          skin={skin}
          onSkinChange={setActiveSkinId}
          skinOptions={skins}
        />

        {/* Playlist */}
        <Playlist
          tracks={tracks}
          activeTrack={activeTrack}
          onSelect={setActiveTrack}
          skin={skin}
        />

        {/* Content window */}
        <div className="mt-4">
          <ContentWindow track={activeTrack} skin={skin} />
        </div>

        {/* Footer */}
        <div
          className="text-center py-4 mt-4 text-xs opacity-30"
          style={{ color: c.text, fontFamily: "'Courier New', monospace" }}
        >
          <p>Inspired by Winamp 2.x • &copy; {new Date().getFullYear()} Shawn</p>
          <p className="mt-1 opacity-60">Nullsoft never dies</p>
        </div>
      </div>
    </main>
  );
}
