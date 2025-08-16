import os
import yaml
from .crew import SeedingCrew
from datetime import datetime

# --- CONFIGURAÇÃO DE CAMINHOS ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PERSONAS_FILE = os.path.join(BASE_DIR, 'knowledge', 'personas.yaml')
OUTPUT_DIR = os.path.join(BASE_DIR, 'posts')

def carregar_personas():
    """Carrega as personas do arquivo YAML. Esta é a única vez que usamos o parser."""
    try:
        with open(PERSONAS_FILE, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Erro: O arquivo de personas não foi encontrado em '{PERSONAS_FILE}'")
        return None
    except Exception as e:
        print(f"Ocorreu um erro ao ler o arquivo de personas: {e}")
        return None

def run():
    """
    Orquestra a criação de posts, recebendo blocos de Markdown prontos dos agentes.
    """
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    personas = carregar_personas()
    if not personas:
        return

    seeding_crew = SeedingCrew()
    print(f"Iniciando a geração de posts para {len(personas)} personas.")

    for persona in personas:
        print(f"\n--- Gerando 5 posts para a persona: {persona['nome']} ---")
        posts_markdown_da_persona = []
        
        for i in range(5):
            print(f"  -> Criando post {i+1}/5...")
            
            try:
                inputs = {
                    "persona_nome": persona['nome'],
                    "categoria_escolhida": persona['categorias_primarias'][0],
                    "persona_id": persona['id'],
                    "data_atual": datetime.now().isoformat(),
                    "ano_atual": datetime.now().year
                }
                
                # A crew agora retorna o Markdown formatado diretamente.
                resultado_crew = seeding_crew.crew().kickoff(inputs=inputs)
                
                if resultado_crew:
                    # Não precisamos mais de parsers, apenas convertemos para string.
                    markdown_do_post = str(resultado_crew).strip()
                    posts_markdown_da_persona.append(markdown_do_post)
                    print(f"  -> Post {i+1} formatado em Markdown recebido.")
                else:
                    print(f"  -> Falha ao gerar post {i+1}. Nenhum resultado retornado.")

            except Exception as e:
                print(f"  -> Ocorreu um erro ao gerar o post {i+1}: {e}")

        if posts_markdown_da_persona:
            nome_arquivo = f"{persona['nome'].replace(' ', '_').lower()}.md"
            caminho_arquivo = os.path.join(OUTPUT_DIR, nome_arquivo)
            
            print(f"  => Salvando arquivo Markdown com {len(posts_markdown_da_persona)} posts...")
            
            # Junta os blocos de markdown com um separador
            conteudo_final = f"# Posts Gerados para: {persona['nome']}\n\n---\n\n"
            conteudo_final += "\n\n---\n\n".join(posts_markdown_da_persona)
            
            with open(caminho_arquivo, 'w', encoding='utf-8') as f:
                f.write(conteudo_final)
            
            print(f"  => Arquivo salvo em: {caminho_arquivo}")

    print("\nProcesso de seeding concluído.")

if __name__ == "__main__":
    run()