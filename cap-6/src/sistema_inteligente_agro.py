# SISTEMA INTELIGENTE AGRO

import json
import datetime
from sklearn.linear_model import LinearRegression
import numpy as np



areas_json = json.loads("""
[
    {
        "id": 1,
        "nome": "Fazenda São João",
        "localizacao": "Minas Gerais",
        "tipo_cultivo": "Café",
        "hectares": 50,
        "previsao_safra_ton": 45,
        "inicio_colheita": "2025-07-01",
        "fim_colheita": "2025-09-01",
        "estado": "Disponível",
        "arrendador": "Sr. José"
    },
    {
        "id": 2,
        "nome": "Fazenda Boa Vista",
        "localizacao": "São Paulo",
        "tipo_cultivo": "Milho",
        "hectares": 80,
        "previsao_safra_ton": 100,
        "inicio_colheita": "2025-06-15",
        "fim_colheita": "2025-08-20",
        "estado": "Disponível",
        "arrendador": "Sra. Maria"
    },
    {
        "id": 3,
        "nome": "Fazenda Esperança",
        "localizacao": "Goiás",
        "tipo_cultivo": "Café",
        "hectares": 30,
        "previsao_safra_ton": 25,
        "inicio_colheita": "2025-07-10",
        "fim_colheita": "2025-09-05",
        "estado": "Disponível",
        "arrendador": "Sr. Paulo"
    }
]
""")

estoque_json = json.loads("""
[
    {
        "produto": "Café",
        "quantidade_ton": 20,
        "preco_unitario": 1800,
        "fornecedor": "Armazém Central",
        "disponivel_para_venda": true
    },
    {
        "produto": "Milho",
        "quantidade_ton": 50,
        "preco_unitario": 1200,
        "fornecedor": "Silo Norte",
        "disponivel_para_venda": true
    },
    {
        "produto": "Café",
        "quantidade_ton": 10,
        "preco_unitario": 1900,
        "fornecedor": "Armazém Sul",
        "disponivel_para_venda": true
    }
]
""")

historico_precos_json = json.loads("""
[
    {"produto": "Café", "preco_dolar_ton": 2000, "ano": 2022},
    {"produto": "Café", "preco_dolar_ton": 2100, "ano": 2023},
    {"produto": "Café", "preco_dolar_ton": 2200, "ano": 2024},
    {"produto": "Milho", "preco_dolar_ton": 1000, "ano": 2022},
    {"produto": "Milho", "preco_dolar_ton": 1100, "ano": 2023},
    {"produto": "Milho", "preco_dolar_ton": 1200, "ano": 2024}
]
""")



def listar_areas_disponiveis(areas):
    """Lista as áreas disponíveis para arrendamento"""
    print("\n🌱 ÁREAS DISPONÍVEIS PARA ARRENDAMENTO:")
    for area in areas:
        if area["estado"] == "Disponível":
            print(f"→ {area['nome']} ({area['tipo_cultivo']}) - {area['hectares']} ha - "
                  f"Previsão: {area['previsao_safra_ton']}t - Arrendador: {area['arrendador']}")

def listar_estoque_disponivel(estoque):
    """Lista os produtos disponíveis para venda"""
    print("\n🏪 PRODUTOS DISPONÍVEIS EM ESTOQUE:")
    for item in estoque:
        if item["disponivel_para_venda"]:
            print(f"→ {item['produto']} - {item['quantidade_ton']}t - "
                  f"R${item['preco_unitario']} por ton - Fornecedor: {item['fornecedor']}")

def prever_valorizacao(historico, produto):
    """Prevê a valorização de um produto com base em histórico"""
    dados_produto = [h for h in historico if h["produto"].lower() == produto.lower()]
    anos = np.array([h["ano"] for h in dados_produto]).reshape(-1,1)
    precos = np.array([h["preco_dolar_ton"] for h in dados_produto])

    modelo = LinearRegression()
    modelo.fit(anos, precos)

    proximo_ano = np.array([[max(anos.flatten()) + 1]])
    preco_previsto = modelo.predict(proximo_ano)[0]

    return preco_previsto

def recomendar_acao(areas, estoque, historico):
    """Sugere as melhores ações com base nas áreas, estoques e previsão de mercado"""
    print("\n📈 RECOMENDAÇÃO INTELIGENTE PARA O PRODUTOR:")

    hoje = datetime.date.today()

    # 1️⃣ Áreas com safra promissora
    print("\n➡️ Áreas sugeridas para arrendamento:")
    for area in areas:
        inicio = datetime.datetime.strptime(area["inicio_colheita"], "%Y-%m-%d").date()
        if area["estado"] == "Disponível" and area["previsao_safra_ton"] >= 30 and inicio > hoje:
            print(f"✅ {area['nome']} ({area['tipo_cultivo']}) - {area['previsao_safra_ton']}t "
                  f"(colheita prevista: {area['inicio_colheita']})")

    # 2️⃣ Produtos com previsão de valorização
    print("\n➡️ Commodities com previsão de alta no mercado:")
    for item in estoque:
        preco_prev = prever_valorizacao(historico, item["produto"])
        lucro_estimado = preco_prev - item["preco_unitario"]
        if lucro_estimado > 0:
            print(f"💰 {item['produto']} - Preço atual: R${item['preco_unitario']} "
                  f"| Previsto: ${int(preco_prev)} → Lucro potencial: ${int(lucro_estimado)} por ton")

#Menu

def main():
    areas = areas_json
    estoque = estoque_json
    historico = historico_precos_json

    while True:
        print("\n===============================")
        print("🌾 SISTEMA INTELIGENTE DO AGRONEGÓCIO 🌾")
        print("===============================")
        print("1 - Listar áreas para arrendamento")
        print("2 - Listar produtos em estoque")
        print("3 - Prever valorização de commodities")
        print("4 - Recomendação de ação inteligente")
        print("0 - Sair")
        print("===============================")

        opcao = input("Escolha uma opção: ")

        if opcao == "1":
            listar_areas_disponiveis(areas)
        elif opcao == "2":
            listar_estoque_disponivel(estoque)
        elif opcao == "3":
            produto = input("Digite o nome do produto (Café/Milho): ")
            preco = prever_valorizacao(historico, produto)
            print(f"📊 Preço previsto para {produto} no próximo ano: ${int(preco)} por tonelada")
        elif opcao == "4":
            recomendar_acao(areas, estoque, historico)
        elif opcao == "0":
            print("Encerrando o sistema... 🌻")
            break
        else:
            print("⚠️ Opção inválida! Tente novamente.")


if __name__ == "__main__":
    main()
