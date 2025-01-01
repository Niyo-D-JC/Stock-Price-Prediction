from dash import html
import dash_bootstrap_components as dbc
from datetime import datetime

INDEX_CONFIG = '''
<!DOCTYPE html>
<html>
    <head>
        <title>Open Bank Monitor</title>
        <link rel="icon" type="image/png" href="https://www.credit-conso.org/wp-content/uploads/2023/07/ogo_Cofidis.png">  <!-- Référence à votre favicon -->
        {%metas%}
        {%css%}
    </head>
    <body>
        <!--[if IE]><script>
        alert("Dash v2.7+ does not support Internet Explorer. Please use a newer browser.");
        </script><![endif]-->
        {%app_entry%}
        <footer>
            {%config%}
            {%scripts%}
            {%renderer%}
        </footer>
    </body>
</html>
'''

class Menu:
    def __init__(self, path):
        self.path = path
        self.SIDEBAR_STYLE = {
                "position": "fixed",
                "top": 0,
                "left": 0,
                "bottom": 0,
                "width": "16rem",
                "padding": "2rem 1rem",
                "background-color": "#f8f9fa",
            }
    def get_current_year(self):
        return datetime.now().year
    
    def render(self):
        return html.Div(
                [   dbc.CardImg(src="https://www.credit-conso.org/wp-content/uploads/2023/07/ogo_Cofidis.png", top=True),
                 
                    html.H4("Open Bank", className="display-6", style={'font-weight':'bold'}),
                    html.Hr(),
                    html.P(
                        "Monitoring SyHo", className="lead", style={'text-align':'center'}
                    ),
                    html.Br(),
                    dbc.Nav(
                        [
                            dbc.NavLink("Analyse", href=f"{self.path}", active="exact"),
                            dbc.NavLink("Banque", href=f"{self.path}bank", active="exact"),
                            dbc.NavLink("Mots Clés", href=f"{self.path}motscles", active="exact"),
                            dbc.NavLink("Type d'Opération", href=f"{self.path}type", active="exact"),
                            dbc.NavLink("Catégorie", href=f"{self.path}categorie", active="exact"),
                            dbc.NavLink("Non Catégorisées", href=f"{self.path}noncategorie", active="exact"),
                            dbc.NavLink("Contrôle", href=f"{self.path}controle", active="exact"),
                        ],
                        vertical=True,
                        pills=True,
                    ),
                     html.Footer(f"© {self.get_current_year()} A3 ENSAI", style={'text-align': 'center', 'position': 'absolute', 'color':'#d10737', 'font-weight':'bold',
                                                                                 'bottom': '20px', 'left': '50%', 'transform': 'translateX(-50%)', 
                                                                                 'width': '100%', 'margin': 'auto'})
                ],
                style=self.SIDEBAR_STYLE,
            )
