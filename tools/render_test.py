import sys
import os

# Garantir que o diretório pai (onde está app.py) esteja em sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from app import app

with app.test_request_context('/'):  # cria contexto de requisição para que url_for funcione
    t = app.jinja_env.get_template('index.html')
    r = t.render(preco='R$ 339.700,00', user='teste', tipo_imovel='Casa', cidade='Jacareí')
    print('---RENDERED START---')
    print(r[:1200])
    print('\n---RENDERED END---')
