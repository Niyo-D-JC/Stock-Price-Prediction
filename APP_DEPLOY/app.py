from dash import Dash, html, Input, Output, callback, dcc, State, dash_table, DiskcacheManager
import os
from datetime import datetime, timedelta
import dash
import dash_bootstrap_components as dbc
from multiprocessing import Pool


from components.menu import *
from components.analyse import Analyse
import plotly.express as px
import pandas as pd
from collections import Counter

import time



# Initialisation du chemin permettant le lancement de l'application
# Définition du chemin de base pour l'application Dash en utilisant une variable d'environnement pour l'utilisateur
path = f"/"
app = Dash(__name__, requests_pathname_prefix=path, external_stylesheets=[dbc.themes.BOOTSTRAP], suppress_callback_exceptions = True)

app.index_string = INDEX_CONFIG

# Initialisation des différentes sections de l'application via des objets personnalisés
analyse = Analyse()      

CONTENT_STYLE = {
        "margin-left": "18rem",
        "margin-right": "2rem",
        "padding": "2rem 1rem",
    }


sidebar = Menu(path).render()
content =  dbc.Spinner(html.Div(id="page-content", style=CONTENT_STYLE), spinner_style={"width": "3rem", "height": "3rem"})

app.layout = html.Div(
    [
        dcc.Location(id="url"), # Permet de gérer les URLs et la navigation au sein de l'application
        sidebar, # Ajout de la barre latérale
        content, # Contenu principal avec un Spinner
        html.Button(id='load-data-button-slide', style={"display": "none"}), # Bouton caché pour déclencher le chargement des données
        dcc.Store(id='selected-item', data='', storage_type='session'),  # Stockage temporaire de données sélectionnées en session
        html.Div(id="hidden-div", style={"display": "none"}), # Division cachée pour stocker d'autres informations ou déclencher des callbacks
    ])

# Callback pour mettre à jour le contenu de la page en fonction du chemin d'URL
@app.callback(Output("page-content", "children"), [Input("url", "pathname")])
def render_page_content(pathname):
    # Affiche le rendu correspondant à l'URL, sinon retourne l'analyse par défaut
    if pathname == f"{path}":
        return analyse.render() 
    elif pathname == f"{path}techn": 
        return analyse.render() 
    elif pathname == f"{path}model": 
        return analyse.render() 
    elif pathname == f"{path}calibration": 
        return analyse.render() 
    else:
        return analyse.render()             # Page par défaut (analyse) si le chemin n'est pas reconnu



############################ ANALYSE ########################################



if __name__ == '__main__':
    app.run(debug=True)
    
