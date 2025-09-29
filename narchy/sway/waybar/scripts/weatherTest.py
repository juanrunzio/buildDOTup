#!/usr/bin/env python3
import json
import requests
from datetime import datetime

WEATHER_CODES = {
    '113': '☀️', '116': '⛅️', '119': '☁️', '122': '☁️', '143': '🌫',
    '176': '🌦', '179': '🌧', '182': '🌧', '185': '🌧', '200': '⛈',
    '227': '🌨', '230': '❄️', '248': '🌫', '260': '🌫', '263': '🌦',
    '266': '🌦', '281': '🌧', '284': '🌧', '293': '🌦', '296': '🌦',
    '299': '🌧', '302': '🌧', '305': '🌧', '308': '🌧', '311': '🌧',
    '314': '🌧', '317': '🌧', '320': '🌨', '323': '🌨', '326': '🌨',
    '329': '❄️', '332': '❄️', '335': '❄️', '338': '❄️', '350': '🌧',
    '353': '🌦', '356': '🌧', '359': '🌧', '362': '🌧', '365': '🌧',
    '368': '🌨', '371': '❄️', '374': '🌧', '377': '🌧', '386': '⛈',
    '389': '🌩', '392': '⛈', '395': '❄️'
}

try:
    url = "https://wttr.in/~-34.458,-58.913?format=j1"  # Coordenadas de Pilar, Buenos Aires
    #url = "https://wttr.in/?format=j1"  # Detecta ubicacion por IP
    headers = {'User-Agent': 'Mozilla/5.0'}
    response = requests.get(url, headers=headers, timeout=10)

    if not response.ok or not response.headers.get("Content-Type", "").startswith("application/json"):
        raise ValueError("Respuesta no válida o no es JSON")
    weather = response.json()

except Exception as e:
    print(json.dumps({
        "text": "⚠️",
        "tooltip": f"Error al obtener clima: {str(e)}"
    }))
    exit(0)

def format_time(time): return time.replace("00", "").zfill(2)
def format_temp(temp): return (temp + "°").ljust(3)
def format_chances(hour):
    chances = {
        "chanceoffog": "Fog", "chanceoffrost": "Frost", "chanceofovercast": "Overcast",
        "chanceofrain": "Rain", "chanceofsnow": "Snow", "chanceofsunshine": "Sunshine",
        "chanceofthunder": "Thunder", "chanceofwindy": "Wind"
    }
    return ", ".join([chances[k] + " " + hour[k] + "%" for k in chances if int(hour[k]) > 0])

data = {}
data['text'] = WEATHER_CODES.get(weather['current_condition'][0]['weatherCode'], "🌈") + \
    " " + weather['current_condition'][0]['FeelsLikeC'] + "°"

data['tooltip'] = f"<b>{weather['current_condition'][0]['weatherDesc'][0]['value']} {weather['current_condition'][0]['temp_C']}°</b>\n"
data['tooltip'] += f"Feels like: {weather['current_condition'][0]['FeelsLikeC']}°\n"
data['tooltip'] += f"Wind: {weather['current_condition'][0]['windspeedKmph']}Km/h\n"
data['tooltip'] += f"Humidity: {weather['current_condition'][0]['humidity']}%\n"

for i, day in enumerate(weather['weather']):
    data['tooltip'] += f"\n<b>{['Today', 'Tomorrow', day['date']][i if i < 2 else 2]}</b>\n"
    data['tooltip'] += f"⬆️ {day['maxtempC']}° ⬇️ {day['mintempC']}° "
    data['tooltip'] += f" {day['astronomy'][0]['sunrise']}  {day['astronomy'][0]['sunset']}\n"
    for hour in day['hourly']:
        if i == 0 and int(format_time(hour['time'])) < datetime.now().hour - 2:
            continue
        data['tooltip'] += f"{format_time(hour['time'])} {WEATHER_CODES.get(hour['weatherCode'], '🌈')} {format_temp(hour['FeelsLikeC'])} {hour['weatherDesc'][0]['value']}, {format_chances(hour)}\n"

print(json.dumps(data))

