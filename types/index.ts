export interface Track {
  id: number;
  filename: string;
  section: string;
  duration: string;
}

export interface Skin {
  id: string;
  name: string;
  colors: {
    bg: string;
    bgSecondary: string;
    titleBar: string;
    accent: string;
    accentHover: string;
    text: string;
    textDim: string;
    border: string;
    buttonBg: string;
    buttonText: string;
    trackHighlight: string;
    visualizer: string[];
  };
}
