import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/hostname', methods=['GET'])
def get_hostname():
    return jsonify({'hostname': os.environ.get('HOSTNAME', 'Unknown Host')})

@app.route('/author', methods=['GET'])
def get_author():
    return jsonify({'author': os.environ.get('AUTHOR', 'Unknown Author')})

@app.route('/id', methods=['GET'])
def get_id():
    return jsonify({'uuid': os.environ.get('UUID', 'Unknown UUID')})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
