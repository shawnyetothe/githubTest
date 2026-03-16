export const content: Record<string, React.ReactNode> = {
  about: (
    <div className="space-y-4">
      <h2 className="text-lg font-bold uppercase tracking-widest mb-4">
        ── ABOUT_SHAWN.TXT ──
      </h2>
      <p className="leading-relaxed">
        Hey, I&apos;m <span className="font-bold">Shawn</span> — investor, builder, and chronic over-thinker of systems.
      </p>
      <p className="leading-relaxed">
        I spend my days hunting for companies that bend the curve of what&apos;s possible — the kind of teams that see the world as it could be rather than how it is.
      </p>
      <p className="leading-relaxed">
        When I&apos;m not deep in cap tables or pitch decks, you&apos;ll find me writing about technology, markets, and the strange feedback loops that shape both.
      </p>
      <p className="leading-relaxed">
        I believe the most important work happens at the intersection of deep technical insight and contrarian conviction.
      </p>
      <div className="mt-6 pt-4 border-t border-current border-opacity-20">
        <p className="text-sm opacity-60">
          Based in: <span className="opacity-100">San Francisco, CA</span>
        </p>
        <p className="text-sm opacity-60 mt-1">
          Currently: <span className="opacity-100">Early-stage investing &amp; writing</span>
        </p>
      </div>
    </div>
  ),

  essays: (
    <div className="space-y-4">
      <h2 className="text-lg font-bold uppercase tracking-widest mb-4">
        ── ESSAYS.TXT ──
      </h2>
      <div className="space-y-3">
        {[
          {
            date: "2024-03",
            title: "The Quiet Collapse of Attention",
            tag: "culture",
          },
          {
            date: "2024-01",
            title: "Why Founders Lie to Themselves First",
            tag: "startups",
          },
          {
            date: "2023-11",
            title: "Infrastructure as Destiny",
            tag: "tech",
          },
          {
            date: "2023-09",
            title: "The Liquidity Illusion in Private Markets",
            tag: "finance",
          },
          {
            date: "2023-07",
            title: "On Contrarianism Done Wrong",
            tag: "investing",
          },
          {
            date: "2023-04",
            title: "Models That Eat the World",
            tag: "AI",
          },
        ].map((essay) => (
          <div
            key={essay.title}
            className="flex justify-between items-start py-2 border-b border-current border-opacity-10 hover:opacity-80 cursor-pointer group"
          >
            <div>
              <span className="text-xs opacity-40 mr-3">{essay.date}</span>
              <span className="group-hover:underline">{essay.title}</span>
            </div>
            <span className="text-xs opacity-40 ml-2 shrink-0">[{essay.tag}]</span>
          </div>
        ))}
      </div>
      <p className="text-xs opacity-40 mt-4">* Full posts coming soon. Subscribe for updates.</p>
    </div>
  ),

  systemic_thesis: (
    <div className="space-y-4">
      <h2 className="text-lg font-bold uppercase tracking-widest mb-4">
        ── SYSTEMIC_THESIS.TXT ──
      </h2>
      <p className="leading-relaxed opacity-80 text-sm">
        My investment philosophy is rooted in identifying systemic shifts — moments when the underlying substrate of an industry changes and creates asymmetric opportunity.
      </p>
      <div className="space-y-4 mt-4">
        {[
          {
            theme: "Cognitive Augmentation",
            desc: "Tools that extend human reasoning, not replace it. The augmented knowledge worker is a decade-long trend still in early innings.",
          },
          {
            theme: "Infrastructure Compounding",
            desc: "Every new compute paradigm creates a land-rush for the picks-and-shovels layer. We are in one now.",
          },
          {
            theme: "Biological Software",
            desc: "Biology is becoming programmable. The companies that treat cells as compilers will define the next century of medicine.",
          },
          {
            theme: "Decentralized Trust",
            desc: "When institutions fail to scale trust, cryptographic primitives step in. This is a longer arc than any single cycle suggests.",
          },
        ].map((item) => (
          <div key={item.theme} className="border-l-2 border-current border-opacity-40 pl-4">
            <p className="font-bold text-sm">{item.theme}</p>
            <p className="text-sm opacity-60 mt-1">{item.desc}</p>
          </div>
        ))}
      </div>
    </div>
  ),

  portfolio: (
    <div className="space-y-4">
      <h2 className="text-lg font-bold uppercase tracking-widest mb-4">
        ── PORTFOLIO.TXT ──
      </h2>
      <p className="text-sm opacity-60 mb-4">A selection of companies I&apos;ve backed.</p>
      <div className="grid grid-cols-1 gap-3">
        {[
          { name: "Axiom Systems", stage: "Seed", domain: "AI Infrastructure" },
          { name: "Verdant Bio", stage: "Series A", domain: "Synthetic Biology" },
          { name: "Lattice Protocol", stage: "Seed", domain: "Decentralized Finance" },
          { name: "Meridian AI", stage: "Pre-Seed", domain: "Cognitive Tools" },
          { name: "Stratum Health", stage: "Series A", domain: "Digital Health" },
          { name: "Covalent Data", stage: "Seed", domain: "Data Infrastructure" },
        ].map((co) => (
          <div
            key={co.name}
            className="flex justify-between items-center py-2 border-b border-current border-opacity-10"
          >
            <span className="font-bold">{co.name}</span>
            <div className="flex gap-3 text-xs opacity-60">
              <span>{co.domain}</span>
              <span className="opacity-40">|</span>
              <span>{co.stage}</span>
            </div>
          </div>
        ))}
      </div>
      <p className="text-xs opacity-30 mt-4">* Names are illustrative placeholders.</p>
    </div>
  ),

  projects: (
    <div className="space-y-4">
      <h2 className="text-lg font-bold uppercase tracking-widest mb-4">
        ── PROJECTS.TXT ──
      </h2>
      <div className="space-y-4">
        {[
          {
            name: "dealflow.io",
            desc: "A lightweight CRM built for solo investors to track deal flow without enterprise bloat.",
            tags: ["Next.js", "Supabase"],
            status: "active",
          },
          {
            name: "thesis-mapper",
            desc: "Visual tool for mapping investment theses to market signals. Built for personal use.",
            tags: ["React", "D3.js"],
            status: "active",
          },
          {
            name: "signal-digest",
            desc: "Weekly auto-digest of curated links across AI, bio, and markets, assembled by a custom LLM pipeline.",
            tags: ["Python", "Claude API"],
            status: "beta",
          },
          {
            name: "this website",
            desc: "A nostalgic Winamp-inspired personal site. Because why not.",
            tags: ["Next.js", "Tailwind"],
            status: "live",
          },
        ].map((proj) => (
          <div key={proj.name} className="border border-current border-opacity-20 p-3 rounded">
            <div className="flex justify-between items-start">
              <span className="font-bold">{proj.name}</span>
              <span className="text-xs opacity-40">[{proj.status}]</span>
            </div>
            <p className="text-sm opacity-60 mt-1">{proj.desc}</p>
            <div className="flex gap-2 mt-2 flex-wrap">
              {proj.tags.map((t) => (
                <span key={t} className="text-xs border border-current border-opacity-30 px-2 py-0.5 rounded">
                  {t}
                </span>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  ),

  contact: (
    <div className="space-y-4">
      <h2 className="text-lg font-bold uppercase tracking-widest mb-4">
        ── CONTACT.TXT ──
      </h2>
      <p className="leading-relaxed opacity-80">
        I&apos;m always open to conversations about interesting companies, ideas, and collaborations.
      </p>
      <div className="space-y-3 mt-6">
        {[
          { label: "Email", value: "shawn@example.com", href: "mailto:shawn@example.com" },
          { label: "Twitter / X", value: "@shawnyetothe", href: "#" },
          { label: "LinkedIn", value: "/in/shawnyetothe", href: "#" },
          { label: "GitHub", value: "github.com/shawnyetothe", href: "#" },
        ].map((item) => (
          <div key={item.label} className="flex gap-4 items-center py-2 border-b border-current border-opacity-10">
            <span className="text-sm opacity-40 w-24 shrink-0">{item.label}</span>
            <a href={item.href} className="hover:underline font-mono text-sm">
              {item.value}
            </a>
          </div>
        ))}
      </div>
      <p className="text-xs opacity-40 mt-6">
        Response time: usually within 48 hours.
      </p>
    </div>
  ),
};
