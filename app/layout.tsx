import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Shawn — Personal Site",
  description: "Investor, builder, writer. A Winamp-inspired personal site.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
