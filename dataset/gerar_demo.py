"""
Gera 4 imagens placeholder para a pasta dataset/frames/demo/.
Uso: python dataset/gerar_demo.py
Requisito: pip install pillow
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).parent / "frames" / "demo"
OUT.mkdir(parents=True, exist_ok=True)

W, H = 720, 1280  # proporção tela de celular

PLACEHOLDERS = [
    {
        "filename": "alto.jpg",
        "bg":       "#1a0000",
        "border":   "#dc2626",
        "icon":     "🔴",
        "nivel":    "RISCO ALTO",
        "exemplo":  "grooming · conteúdo adulto · extremismo",
        "aviso":    "PLACEHOLDER — substituir antes do evento",
    },
    {
        "filename": "medio.jpg",
        "bg":       "#1a1000",
        "border":   "#d97706",
        "icon":     "🟡",
        "nivel":    "RISCO MÉDIO",
        "exemplo":  "violência · gambling · bullying",
        "aviso":    "PLACEHOLDER — substituir antes do evento",
    },
    {
        "filename": "baixo.jpg",
        "bg":       "#001a08",
        "border":   "#16a34a",
        "icon":     "🟢",
        "nivel":    "RISCO BAIXO",
        "exemplo":  "microtransação · fomo",
        "aviso":    "PLACEHOLDER — substituir antes do evento",
    },
    {
        "filename": "inofensivo.jpg",
        "bg":       "#0a0a14",
        "border":   "#4b5563",
        "icon":     "✅",
        "nivel":    "INOFENSIVO",
        "exemplo":  "nenhum risco detectado · sem alerta gerado",
        "aviso":    "PLACEHOLDER — substituir antes do evento",
    },
]


def hex_to_rgb(h: str) -> tuple:
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))


def gerar(p: dict):
    img = Image.new("RGB", (W, H), hex_to_rgb(p["bg"]))
    draw = ImageDraw.Draw(img)

    # Borda colorida
    bw = 12
    bc = hex_to_rgb(p["border"])
    draw.rectangle([bw, bw, W - bw, H - bw], outline=bc, width=bw)

    # Tenta carregar fonte, usa default se não tiver
    try:
        font_big   = ImageFont.truetype("arial.ttf", 72)
        font_med   = ImageFont.truetype("arial.ttf", 42)
        font_small = ImageFont.truetype("arial.ttf", 28)
        font_warn  = ImageFont.truetype("arial.ttf", 24)
    except Exception:
        font_big   = ImageFont.load_default()
        font_med   = font_big
        font_small = font_big
        font_warn  = font_big

    cx = W // 2

    # Ícone
    draw.text((cx, H // 2 - 200), p["icon"],  font=font_big,   fill="#ffffff", anchor="mm")
    # Nível
    draw.text((cx, H // 2 - 90),  p["nivel"], font=font_med,   fill=hex_to_rgb(p["border"]), anchor="mm")
    # Exemplo
    draw.text((cx, H // 2),       p["exemplo"], font=font_small, fill="#9ca3af", anchor="mm")

    # Linha separadora
    draw.rectangle([80, H // 2 + 50, W - 80, H // 2 + 52], fill="#2d2d50")

    # Aviso placeholder
    draw.text((cx, H // 2 + 100), p["aviso"], font=font_warn, fill="#374151", anchor="mm")

    # Nome do arquivo no canto
    draw.text((cx, H - 60), p["filename"], font=font_warn, fill="#1f2937", anchor="mm")

    path = OUT / p["filename"]
    img.save(path, "JPEG", quality=90)
    print(f"  OK {path}")


def main():
    print("=== Gerando imagens demo ===\n")
    for p in PLACEHOLDERS:
        gerar(p)
    print(f"\nSalvas em: {OUT}")


if __name__ == "__main__":
    main()
