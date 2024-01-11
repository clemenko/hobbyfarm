from flask import Flask, render_template, request, jsonify, redirect, url_for
from redis import Redis

import os

version = "0.4"
app = Flask(__name__)
app.config['JSONIFY_PRETTYPRINT_REGULAR'] = False
redis = Redis(host='redis', port=6379)
server_name = os.getenv('HOSTNAME')


@app.route('/healthz')
def health_check():
    return jsonify({'redis': 'up', 'storage': 'up'}), 200

@app.route('/hits')
def hits():
    redis.incr('hits')
    return redis.get('hits')

@app.route('/info')
def info(server_name=None):
    return jsonify({'hostname': os.getenv('HOSTNAME'), 'version': version}), 200

@app.route('/')
def index(server_name=None):
    redis.incr('hits')
    server_name = os.getenv('HOSTNAME')
    return render_template('index.html', hits=redis.get('hits').decode('utf-8'), server_name=server_name)

if __name__ == '__main__':
    app.run(host='0.0.0.0',debug=True)
