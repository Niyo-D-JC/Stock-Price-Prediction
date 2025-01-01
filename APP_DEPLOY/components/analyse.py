from datetime import datetime, timedelta

from dash import html, dcc
import dash_bootstrap_components as dbc
import pandas as pd
import numpy as np
import plotly.express as px

class Analyse:
    def __init__(self):
        # Composant pour sélectionner la mesure (Nombre ou Montant)
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
                
            )
        return row
