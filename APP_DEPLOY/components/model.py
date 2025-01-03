from datetime import datetime, timedelta

from dash import html, dcc, dash_table
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

        self.tab_group =  dbc.ListGroup([
                                    dbc.ListGroupItem("Financial Performance", active=True),
                                    dbc.ListGroupItem("Revenue Growth: 12%"),
                                    dbc.ListGroupItem("Profit Margins: 30.51%"),
                                    dbc.ListGroupItem("EPS: $14.25"),
                                    dbc.ListGroupItem("FCF: $6.8B"),
                                    dbc.ListGroupItem("ROE: 29%"),
                                    dbc.ListGroupItem("P/E Ratio: 35.57"),
                                    dbc.ListGroupItem("Total Assets: $29.83B"),
                                    dbc.ListGroupItem("Dividend Yield: N/A"),
                                ])
        
        
    def render(self):
        row = html.Div(
                [
                    dbc.Row(dbc.Col(html.H4("Model Adobe Deployed", className="display-7", style={'font-weight':'bold', 'color':'#d10737'}))),
                    dbc.Row(
                        [
                            # Colonne de gauche avec le RangeSlider et un graphique
                            dbc.Col([dcc.Graph(id='predict-graph')], width=9),
                            dbc.Col([html.Br(), self.tab_group], width=3),
                        ]
                    ),
                    dbc.Row(
                        [
                            # Colonne de gauche avec le RangeSlider et un graphique
                            dbc.Col([html.Br(), dash_table.DataTable(id="predict-table", filter_action="native", filter_options={"placeholder_text": "Filtrer..."}, page_size=10)], width=9),
                        ]
                    )
                ]
            )
        return row
