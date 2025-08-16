from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task
from crewai_tools import SerperDevTool

# Ajuste o caminho para sua ferramenta de imagem
from .tools.img_search_tool import DDGImageSearchTool   

# Instancie as ferramentas que serão usadas pelos agentes
search_tool = SerperDevTool()
image_search_tool = DDGImageSearchTool()

@CrewBase
class SeedingCrew():
    """
    Define a equipe (crew) de 3 agentes para a criação robusta de posts.
    Esta classe é o modelo para nossa "linha de montagem".
    """
    agents_config = 'config/agents.yaml'
    tasks_config = 'config/tasks.yaml'

    # --- AGENTES ---
    @agent
    def redator_criativo(self) -> Agent:
        return Agent(
            config=self.agents_config['redator_criativo'],
            tools=[search_tool]
        )

    @agent
    def buscador_de_imagem(self) -> Agent:
        return Agent(
            config=self.agents_config['buscador_de_imagem'],
            tools=[image_search_tool]
        )
    
    @agent
    def verificador_final(self) -> Agent:
        return Agent(config=self.agents_config['verificador_final'])

    # --- TAREFAS ---
    @task
    def criacao_de_conteudo(self) -> Task:
        return Task(
            config=self.tasks_config['tasks']['criacao_de_conteudo'],
            agent=self.redator_criativo()
        )

    @task
    def busca_de_imagem_especifica(self) -> Task:
        return Task(
            config=self.tasks_config['tasks']['busca_de_imagem_especifica'],
            agent=self.buscador_de_imagem(),
            context=[self.criacao_de_conteudo()]
        )
        
    @task
    def verificacao_e_montagem_final(self) -> Task:
        return Task(
            config=self.tasks_config['tasks']['verificacao_e_montagem_final'],
            agent=self.verificador_final(),
            context=[self.criacao_de_conteudo(), self.busca_de_imagem_especifica()]
        )

    # --- DEFINIÇÃO DA CREW ---
    @crew
    def crew(self) -> Crew:
        """Cria e configura a equipe com os agentes e tarefas definidos."""
        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process=Process.sequential, # Garante a ordem: Criação -> Busca -> Verificação
            verbose=False
        )