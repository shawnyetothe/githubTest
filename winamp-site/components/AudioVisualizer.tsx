"use client";

import { useEffect, useRef } from "react";
import { Skin } from "@/types";

interface Props {
  skin: Skin;
  isPlaying: boolean;
}

export default function AudioVisualizer({ skin, isPlaying }: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const animRef = useRef<number>(0);
  const barsRef = useRef<number[]>([]);
  const targetBarsRef = useRef<number[]>([]);

  const BAR_COUNT = 20;

  useEffect(() => {
    const bars = Array.from({ length: BAR_COUNT }, () => 2);
    const targets = Array.from({ length: BAR_COUNT }, () => 2);
    barsRef.current = bars;
    targetBarsRef.current = targets;
  }, []);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const W = canvas.width;
    const H = canvas.height;
    const barW = Math.floor(W / BAR_COUNT) - 1;
    const colors = skin.colors.visualizer;

    const animate = () => {
      ctx.clearRect(0, 0, W, H);

      // Update bar targets
      targetBarsRef.current = targetBarsRef.current.map((t, i) => {
        if (!isPlaying) {
          return Math.max(2, t * 0.85);
        }
        // Simulate audio with randomized peaks
        const base = Math.random();
        const shaped =
          i < BAR_COUNT * 0.3
            ? base * 0.9
            : i < BAR_COUNT * 0.6
            ? base * 1.0
            : base * 0.7;
        return Math.max(2, shaped * (H - 2));
      });

      // Smooth bars toward targets
      barsRef.current = barsRef.current.map((b, i) => {
        const t = targetBarsRef.current[i];
        return b + (t - b) * 0.25;
      });

      barsRef.current.forEach((h, i) => {
        const x = i * (barW + 1);
        const y = H - h;

        // Gradient per bar
        const grad = ctx.createLinearGradient(x, y, x, H);
        grad.addColorStop(0, colors[0]);
        grad.addColorStop(0.5, colors[1]);
        grad.addColorStop(1, colors[2] ?? colors[1]);
        ctx.fillStyle = grad;
        ctx.fillRect(x, y, barW, h);

        // Peak dot
        ctx.fillStyle = colors[0];
        ctx.fillRect(x, y - 2, barW, 2);
      });

      animRef.current = requestAnimationFrame(animate);
    };

    animRef.current = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(animRef.current);
  }, [skin, isPlaying]);

  return (
    <canvas
      ref={canvasRef}
      width={200}
      height={40}
      className="w-full"
      style={{ imageRendering: "pixelated" }}
    />
  );
}
