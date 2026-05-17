"""
Analisa todas as imagens da pasta dataset/frames/teste_bia via /api/analyze/.
Uso: python dataset/test_bia.py
"""

import os
import requests

PASTA      = os.path.join(os.path.dirname(__file__), "frames", "teste_bia")
URL        = "http://localhost:8000/api/analyze/"
DEVICE_TOKEN = "test123"
APP_PACKAGE  = "com.test.bia"

GREEN  = "\033[92m"
RED    = "\033[91m"
YELLOW = "\033[93m"
CYAN   = "\033[96m"
RESET  = "\033[0m"
BOLD   = "\033[1m"

NIVEL_COR = {
    "alto":     RED,
    "moderado": YELLOW,
    "baixo":    GREEN,
}


def analisar(caminho: str) -> dict:
    with open(caminho, "rb") as f:
        try:
            r = requests.post(
                URL,
                data={"device_token": DEVICE_TOKEN, "app_package": APP_PACKAGE},
                files={"image": (os.path.basename(caminho), f, "image/jpeg")},
                timeout=30,
            )
            return r.json() if r.status_code == 200 else {"erro": f"HTTP {r.status_code}"}
        except Exception as e:
            return {"erro": str(e)}


def main():
    imagens = sorted([
        f for f in os.listdir(PASTA)
        if f.lower().endswith((".jpg", ".jpeg", ".png"))
    ])

    if not imagens:
        print("Nenhuma imagem encontrada em dataset/frames/teste_bia/")
        print("Adicione imagens na pasta e rode novamente.")
        return

    print(f"\n{BOLD}=== Aura — Teste Bia ==={RESET}")
    print(f"Pasta:  {PASTA}")
    print(f"Imagens: {len(imagens)}\n")

    contagem = {"alto": 0, "moderado": 0, "baixo": 0, "erro": 0}

    for nome in imagens:
        caminho = os.path.join(PASTA, nome)
        resp = analisar(caminho)

        print(f"{CYAN}[{nome}]{RESET}")

        if "erro" in resp:
            print(f"  {RED}ERRO: {resp['erro']}{RESET}\n")
            contagem["erro"] += 1
            continue

        categoria = resp.get("categoria", "?")
        nivel     = resp.get("nivel", "?")
        descricao = resp.get("descricao", "")
        confianca = resp.get("confianca", 0)

        cor = NIVEL_COR.get(nivel, RESET)
        print(f"  detectado: {cor}{categoria} [{nivel}]{RESET}")
        print(f"  descrição: {descricao}")
        print(f"  confiança: {confianca:.0%}\n")

        contagem[nivel] = contagem.get(nivel, 0) + 1

    print(f"{BOLD}=== Resumo ==={RESET}")
    print(f"  Total testado: {len(imagens)}")
    print(f"  {RED}Alto:    {contagem.get('alto', 0)}{RESET}")
    print(f"  {YELLOW}Médio:   {contagem.get('moderado', 0)}{RESET}")
    print(f"  {GREEN}Baixo:   {contagem.get('baixo', 0)}{RESET}")
    if contagem["erro"]:
        print(f"  Erros:   {contagem['erro']}")


if __name__ == "__main__":
    main()
