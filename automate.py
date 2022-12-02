from flask import Flask, jsonify, request, session
import time
import datetime



app = Flask(__name__)


def get_time():
    ct = datetime.datetime.now()
    ts = str(int(ct.timestamp()))
    return ts


@app.route('/automate')
def get_message():
    message = [
    { 'message': 'Automate all the things!', 'timestamp': get_time() }
    ]
    return jsonify(message)
