"""
Coleta frames de vídeos de gameplay para testar categorias de risco do Aura.
Uso: python dataset/collect.py
Requisitos: yt-dlp, ffmpeg
"""

import os
import subprocess
import glob

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "frames")
TMP_DIR = os.path.join(os.path.dirname(__file__), "_tmp")

DURACAO_SEGUNDOS = 60
INTERVALO_FRAMES = 5  # 1 frame a cada N segundos → ~12 frames por vídeo

# Termos de busca no YouTube por categoria
# conteudo_adulto e extremismo omitidos intencionalmente
CATEGORIAS = [
    {
        "categoria": "gambling",
        "busca": "free fire loot box opening gameplay mobile",
    },
    {
        "categoria": "violencia",
        "busca": "free fire battle gameplay shooting mobile",
    },
    {
        "categoria": "microtransacao",
        "busca": "mobile game shop offers limited time purchase",
    },
    {
        "categoria": "fomo",
        "busca": "mobile game daily reward login bonus gameplay",
    },
    {
        "categoria": "bullying",
        "busca": "roblox toxic chat gameplay kids",
    },
    {
        "categoria": "grooming",
        "busca": "roblox online safety chat stranger danger kids",
    },
    {
        "categoria": "privacidade",
        "busca": "mobile game asking personal information permissions",
    },
    {
        "categoria": "vicio",
        "busca": "mobile game addiction long session gameplay",
    },
    {
        "categoria": "seguro",
        "busca": "minecraft kids friendly gameplay peaceful",
    },
]


def coletar(item: dict):
    categoria = item["categoria"]
    busca = item["busca"]
    url = f"ytsearch1:{busca}"

    pasta_saida = os.path.join(OUTPUT_DIR, categoria)
    os.makedirs(pasta_saida, exist_ok=True)
    os.makedirs(TMP_DIR, exist_ok=True)

    tmp_path = os.path.join(TMP_DIR, f"{categoria}.%(ext)s")
    tmp_final = os.path.join(TMP_DIR, f"{categoria}.mp4")

    # Remove arquivo temporário anterior se existir
    for f in glob.glob(os.path.join(TMP_DIR, f"{categoria}.*")):
        os.remove(f)

    print(f"\n[{categoria.upper()}]")
    print(f"  Buscando: {busca}")

    # Download
    result = subprocess.run(
        [
            "yt-dlp",
            "--no-playlist",
            "--format", "bestvideo[ext=mp4][height<=480]+bestaudio[ext=m4a]/best[ext=mp4][height<=480]/best",
            "--download-sections", f"*0-{DURACAO_SEGUNDOS}",
            "--force-keyframes-at-cuts",
            "--merge-output-format", "mp4",
            "-o", tmp_path,
            url,
        ],
        capture_output=True,
        text=True,
    )

    # Encontra o arquivo baixado
    arquivos = glob.glob(os.path.join(TMP_DIR, f"{categoria}.*"))
    if not arquivos:
        print(f"  ERRO no download: {result.stderr[-300:]}")
        return

    arquivo_baixado = arquivos[0]
    print(f"  Baixado: {os.path.basename(arquivo_baixado)}")

    # Extrai frames
    pattern = os.path.join(pasta_saida, "frame_%04d.jpg")
    result = subprocess.run(
        [
            "ffmpeg", "-y",
            "-i", arquivo_baixado,
            "-vf", f"fps=1/{INTERVALO_FRAMES}",
            "-q:v", "2",
            pattern,
        ],
        capture_output=True,
        text=True,
    )

    frames = [f for f in os.listdir(pasta_saida) if f.endswith(".jpg")]
    if frames:
        print(f"  OK — {len(frames)} frames salvos em dataset/frames/{categoria}/")
    else:
        print(f"  ERRO ffmpeg: {result.stderr[-200:]}")

    # Limpa temporário
    os.remove(arquivo_baixado)


def main():
    print("=== Aura — Coleta de Dataset ===")
    print(f"Saída: {OUTPUT_DIR}")
    print(f"Categorias: {len(CATEGORIAS)}\n")

    for item in CATEGORIAS:
        coletar(item)

    # Remove tmp dir se vazio
    if os.path.exists(TMP_DIR) and not os.listdir(TMP_DIR):
        os.rmdir(TMP_DIR)

    print("\n=== Concluído ===")
    total = 0
    for d in sorted(os.listdir(OUTPUT_DIR)):
        pasta = os.path.join(OUTPUT_DIR, d)
        if os.path.isdir(pasta):
            n = len([f for f in os.listdir(pasta) if f.endswith(".jpg")])
            total += n
            print(f"  {d:<20} {n} frames")
    print(f"\n  Total: {total} frames")


if __name__ == "__main__":
    main()
