from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"status": "healthy", "message": "Secure DevSecOps Pipeline API"})

@app.route('/api/data', methods=['POST'])
def handle_data():
    if not request.json or 'input' not in request.json:
        return jsonify({"error": "Bad Request", "message": "Missing input parameter"}), 400
    
    user_input = str(request.json['input'])
    if len(user_input) > 100:
        return jsonify({"error": "Unprocessable Entity", "message": "Input exceeds maximum allowed limits"}), 422
        
    return jsonify({"processed": True, "length": len(user_input)})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)