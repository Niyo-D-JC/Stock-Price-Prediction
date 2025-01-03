from datetime import datetime, timedelta

from dash import html, dcc
import dash_bootstrap_components as dbc
import pandas as pd
import numpy as np
import plotly.express as px

class Model:
    def __init__(self):
        
        self.button_mesure = html.Div(
                [
                    dbc.RadioItems(
                        id="radios_mesure-analyse",
                        className="btn-group",
                        inputClassName="btn-check",
                        labelClassName="btn btn-outline-primary",
                        labelCheckedClassName="active",
                        options=[
                            {"label": "Nombre", "value": 'count'},
                            {"label": "Montant", "value": 'volume'},
                        ],
                        value='count',
                    )
                ],
                className="radio-group",
            )
        
        
    def render(self):
        row = html.Div(
                [
                    dbc.Row(dbc.Col(html.H4("Model Adobe Deployed", className="display-7", style={'font-weight':'bold', 'color':'#d10737'}))),
                    dbc.Row(
                        [
                            # Colonne de gauche avec le RangeSlider et un graphique
                            dbc.Col([dcc.Graph(id='predict-graph')], width=9),
                            dbc.Col([html.Br()], width=3),
                        ]
                    )
                ]
            )
        return row
