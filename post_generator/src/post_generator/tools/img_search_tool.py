from typing import Type
from pydantic import BaseModel, Field
from crewai.tools import BaseTool
from ddgs import DDGS

class DDGImageSearchInput(BaseModel):
    """Input schema for the DuckDuckGo Image Search tool."""
    search_query: str = Field(..., description="The search query for finding a relevant image.")

class DDGImageSearchTool(BaseTool):
    name: str = "DuckDuckGo Image Search"
    description: str = (
        "Searches DuckDuckGo for a relevant, high-quality, and royalty-free image "
        "based on a search query and returns its URL."
    )
    args_schema: Type[BaseModel] = DDGImageSearchInput

    def _run(self, search_query: str) -> str:
        """
        Executes the image search using the duckduckgo_search library.
        """
        try:
            # O 'max_results=1' garante que pegamos apenas o melhor resultado
            results = DDGS().images(
                query=search_query,
                region="wt-wt",
                safesearch="moderate",
                size=None,
                color=None,
                type_image=None,
                layout=None,
                license_image=None,
                max_results=1
            )

            if results:
                # Retorna a URL da imagem do primeiro resultado
                return results[0]["image"]
            else:
                return f"Nenhuma imagem encontrada para a busca: '{search_query}'."

        except Exception as e:
            return f"Erro ao acessar a busca de imagens do DuckDuckGo: {e}"