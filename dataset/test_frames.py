"""
Testa cada frame coletado contra o endpoint /api/analyze/ e mostra resultado.
Uso: python dataset/test_frames.py
"""

import os
import random
import requests

FRAMES_DIR   = os.path.join(os.path.dirname(__file__), "frames")
TESTE_BIA    = os.path.join(os.path.dirname(__file__), "teste_bia")
ANALYZE_URL  = "http://localhost:8000/api/analyze/"
DEVICE_TOKEN = "test123"
APP_PACKAGE  = "com.test.dataset"

# Cores para terminal
GREEN  = "\033[92m"
RED    = "\033[91m"
YELLOW = "\033[93m"
CYAN   = "\033[96m"
RESET  = "\033[0m"
BOLD   = "\033[1m"


def testar_frame(caminho: str, categoria_esperada: str) -> dict:
    with open(caminho, "rb") as f:
        try:
            r = requests.post(
                ANALYZE_URL,
                data={"device_token": DEVICE_TOKEN, "app_package": APP_PACKAGE},
                files={"image": (os.path.basename(caminho), f, "image/jpeg")},
                timeout=30,
            )
            if r.status_code != 200:
                return {"erro": f"HTTP {r.status_code}"}
            return r.json()
        except Exception as e:
            return {"erro": str(e)}


def main():
    print(f"\n{BOLD}=== Aura — Teste de Frames ==={RESET}")
    print(f"Endpoint: {ANALYZE_URL}")
    print(f"Device:   {DEVICE_TOKEN}\n")

    categorias = sorted([
        d for d in os.listdir(FRAMES_DIR)
        if os.path.isdir(os.path.join(FRAMES_DIR, d))
    ])

    if not categorias:
        print("Nenhuma categoria encontrada em dataset/frames/")
        return

    resultados = []

    for categoria_esperada in categorias:
        pasta = os.path.join(FRAMES_DIR, categoria_esperada)
        frames = sorted([f for f in os.listdir(pasta) if f.endswith(".jpg")])

        if not frames:
            print(f"[{categoria_esperada}] sem frames — pulando\n")
            continue

        frame_escolhido = random.choice(frames)
        print(f"{BOLD}[{categoria_esperada.upper()}]{RESET} — {len(frames)} frames disponíveis → testando 1 aleatório")

        for frame in [frame_escolhido]:
            caminho = os.path.join(pasta, frame)
            resp = testar_frame(caminho, categoria_esperada)

            if "erro" in resp:
                print(f"  {RED}✗ {frame} → ERRO: {resp['erro']}{RESET}")
                resultados.append({"esperado": categoria_esperada, "detectado": None, "acerto": False})
                continue

            detectado = resp.get("categoria", "?")
            nivel     = resp.get("nivel", "?")
            descricao = resp.get("descricao", "")[:60]
            acerto    = detectado == categoria_esperada

            cor = GREEN if acerto else (YELLOW if detectado != "seguro" else RED)
            icone = "✓" if acerto else "✗"

            print(f"  {cor}{icone} {frame}{RESET}")
            print(f"      esperado:  {categoria_esperada}")
            print(f"      detectado: {detectado} [{nivel}]")
            print(f"      descrição: {descricao}")

            resultados.append({
                "esperado":  categoria_esperada,
                "detectado": detectado,
                "acerto":    acerto,
            })

        print()

    # Resumo
    total   = len(resultados)
    acertos = sum(1 for r in resultados if r["acerto"])
    erros   = sum(1 for r in resultados if not r["acerto"])

    print(f"{BOLD}=== Resumo ==={RESET}")
    print(f"  Total testado: {total}")
    print(f"  {GREEN}Acertos: {acertos}{RESET}")
    print(f"  {RED}Erros:   {erros}{RESET}")

    if total > 0:
        pct = acertos / total * 100
        cor = GREEN if pct >= 70 else (YELLOW if pct >= 50 else RED)
        print(f"  {cor}Precisão: {pct:.0f}%{RESET}\n")

    # Erros detalhados
    erros_lista = [r for r in resultados if not r["acerto"]]
    if erros_lista:
        print(f"{BOLD}Classificações incorretas:{RESET}")
        for r in erros_lista:
            print(f"  esperado {r['esperado']:<20} → detectado {r['detectado']}")

    # Teste das imagens da Bia (sem categoria esperada — só mostra o que a IA detecta)
    imagens_bia = sorted([
        f for f in os.listdir(TESTE_BIA)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    ])

    if imagens_bia:
        print(f"\n{BOLD}=== Imagens da Bia ==={RESET} — {len(imagens_bia)} imagem(ns)\n")
        for nome in imagens_bia:
            caminho = os.path.join(TESTE_BIA, nome)
            resp = testar_frame(caminho, "")

            if "erro" in resp:
                print(f"  {RED}✗ {nome} → ERRO: {resp['erro']}{RESET}")
                continue

            detectado = resp.get("categoria", "?")
            nivel     = resp.get("nivel", "?")
            descricao = resp.get("descricao", "")[:80]

            cor = RED if nivel == "alto" else (YELLOW if nivel == "moderado" else GREEN)
            print(f"  {CYAN}{nome}{RESET}")
            print(f"      detectado: {cor}{detectado} [{nivel}]{RESET}")
            print(f"      descrição: {descricao}\n")


if __name__ == "__main__":
    main()
